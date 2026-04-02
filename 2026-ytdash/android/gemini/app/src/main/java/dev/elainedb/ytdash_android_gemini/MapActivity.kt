package dev.elainedb.ytdash_android_gemini

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import coil.compose.AsyncImage
import dev.elainedb.ytdash_android_gemini.database.VideoDatabase
import dev.elainedb.ytdash_android_gemini.model.Video
import dev.elainedb.ytdash_android_gemini.repository.YouTubeRepository
import dev.elainedb.ytdash_android_gemini.ui.FlowRow
import dev.elainedb.ytdash_android_gemini.ui.theme.YTDashAGeminiTheme
import dev.elainedb.ytdash_android_gemini.utils.ConfigHelper
import dev.elainedb.ytdash_android_gemini.network.YouTubeApiService
import okhttp3.OkHttpClient
import okhttp3.MediaType.Companion.toMediaType
import retrofit2.Retrofit
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import kotlinx.serialization.json.Json
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.BoundingBox
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker

class MapActivity : ComponentActivity() {

    private lateinit var repository: YouTubeRepository

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // osmdroid configuration
        Configuration.getInstance().load(this, getSharedPreferences("osmdroid", MODE_PRIVATE))

        ConfigHelper.init(this)

        val json = Json { ignoreUnknownKeys = true }
        val client = OkHttpClient.Builder().build()
        val retrofit = Retrofit.Builder()
            .baseUrl("https://www.googleapis.com/youtube/v3/")
            .client(client)
            .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
            .build()
        val apiService = retrofit.create(YouTubeApiService::class.java)
        val database = VideoDatabase.getDatabase(this)
        repository = YouTubeRepository(apiService, database.videoDao(), this)

        setContent {
            YTDashAGeminiTheme {
                MapScreen(repository)
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MapScreen(repository: YouTubeRepository) {
    val context = LocalContext.current
    var videosWithLocation by remember { mutableStateOf<List<Video>>(emptyList()) }
    var selectedVideo by remember { mutableStateOf<Video?>(null) }
    val sheetState = rememberModalBottomSheetState()
    var showBottomSheet by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        videosWithLocation = repository.getVideosWithLocation()
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Video Map") },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = Color.White
                )
            )
        }
    ) { innerPadding ->
        Box(modifier = Modifier.padding(innerPadding)) {
            AndroidView(
                factory = { ctx ->
                    MapView(ctx).apply {
                        setTileSource(TileSourceFactory.MAPNIK)
                        setMultiTouchControls(true)
                    }
                },
                update = { mapView ->
                    mapView.overlays.clear()
                    val points = mutableListOf<GeoPoint>()
                    videosWithLocation.forEach { video ->
                        val lat = video.locationLatitude ?: return@forEach
                        val lon = video.locationLongitude ?: return@forEach
                        val point = GeoPoint(lat, lon)
                        points.add(point)
                        
                        val marker = Marker(mapView)
                        marker.position = point
                        marker.title = video.title
                        marker.setAnchor(Marker.ANCHOR_CENTER, Marker.ANCHOR_BOTTOM)
                        marker.setOnMarkerClickListener { m, _ ->
                            selectedVideo = video
                            showBottomSheet = true
                            m.showInfoWindow()
                            true
                        }
                        mapView.overlays.add(marker)
                    }

                    if (points.isNotEmpty()) {
                        mapView.post {
                            val box = BoundingBox.fromGeoPoints(points)
                            mapView.zoomToBoundingBox(box, true, 100)
                        }
                    }
                    mapView.invalidate()
                },
                modifier = Modifier.fillMaxSize()
            )

            if (showBottomSheet && selectedVideo != null) {
                ModalBottomSheet(
                    onDismissRequest = { showBottomSheet = false },
                    sheetState = sheetState
                ) {
                    VideoDetailsBottomSheet(selectedVideo!!)
                }
            }
        }
    }
}

@Composable
fun VideoDetailsBottomSheet(video: Video) {
    val context = LocalContext.current
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
            .clickable {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("vnd.youtube:${video.id}"))
                if (intent.resolveActivity(context.packageManager) == null) {
                    context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=${video.id}")))
                } else {
                    context.startActivity(intent)
                }
            }
    ) {
        AsyncImage(
            model = video.thumbnailUrl,
            contentDescription = null,
            modifier = Modifier
                .fillMaxWidth()
                .height(150.dp),
            contentScale = ContentScale.Crop
        )
        Spacer(modifier = Modifier.height(12.dp))
        Text(text = video.title, fontWeight = FontWeight.Bold, fontSize = 18.sp)
        Text(text = video.channelName, style = MaterialTheme.typography.bodyMedium, color = Color.Gray)
        Text(text = video.publishedAt.take(10), style = MaterialTheme.typography.bodySmall)
        
        if (video.tags.isNotEmpty()) {
            Spacer(modifier = Modifier.height(8.dp))
            FlowRow(mainAxisSpacing = 4.dp, crossAxisSpacing = 4.dp) {
                video.tags.take(5).forEach { tag ->
                    SuggestionChip(onClick = {}, label = { Text(tag) })
                }
            }
        }

        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = "📍 ${listOfNotNull(video.locationCity, video.locationCountry).joinToString(", ")}",
            style = MaterialTheme.typography.bodySmall
        )
        Text(
            text = "GPS: ${video.locationLatitude}, ${video.locationLongitude}",
            style = MaterialTheme.typography.bodySmall
        )
        
        if (video.recordingDate != null) {
            Text(
                text = "🎥 Recorded: ${video.recordingDate.take(10)}",
                style = MaterialTheme.typography.bodySmall
            )
        }
        Spacer(modifier = Modifier.height(24.dp))
    }
}
