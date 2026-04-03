package dev.elainedb.ytdash_android_gemini

import android.content.Context
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
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import coil.compose.AsyncImage
import dev.elainedb.ytdash_android_gemini.database.VideoDatabase
import dev.elainedb.ytdash_android_gemini.database.toVideo
import dev.elainedb.ytdash_android_gemini.model.Video
import dev.elainedb.ytdash_android_gemini.ui.theme.YTDashAGeminiTheme
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.BoundingBox
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker

class MapActivity : ComponentActivity() {

    companion object {
        fun newIntent(context: Context): Intent {
            return Intent(context, MapActivity::class.java)
        }
    }

    @OptIn(ExperimentalMaterial3Api::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize osmdroid configuration
        Configuration.getInstance().load(applicationContext, android.preference.PreferenceManager.getDefaultSharedPreferences(applicationContext))

        setContent {
            YTDashAGeminiTheme {
                var selectedVideo by remember { mutableStateOf<Video?>(null) }
                val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = false)
                val scope = rememberCoroutineScope()
                var videosWithLocation by remember { mutableStateOf<List<Video>>(emptyList()) }

                LaunchedEffect(Unit) {
                    val dao = VideoDatabase.getDatabase(applicationContext).videoDao()
                    val entities = dao.getVideosWithLocation()
                    videosWithLocation = entities.map { it.toVideo() }
                }

                Scaffold(
                    topBar = {
                        TopAppBar(
                            title = { Text("Map View") }
                        )
                    }
                ) { paddingValues ->
                    Box(modifier = Modifier.padding(paddingValues).fillMaxSize()) {
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
                                    if (video.locationLatitude != null && video.locationLongitude != null) {
                                        val point = GeoPoint(video.locationLatitude, video.locationLongitude)
                                        points.add(point)
                                        
                                        val marker = Marker(mapView)
                                        marker.position = point
                                        marker.title = video.title
                                        marker.setOnMarkerClickListener { _, _ ->
                                            selectedVideo = video
                                            scope.launch { sheetState.show() }
                                            true
                                        }
                                        mapView.overlays.add(marker)
                                    }
                                }

                                if (points.isNotEmpty()) {
                                    val boundingBox = BoundingBox.fromGeoPoints(points)
                                    // Add a slight delay to ensure the map is laid out before zooming
                                    mapView.post {
                                        mapView.zoomToBoundingBox(boundingBox, true, 100)
                                    }
                                }
                            }
                        )
                    }

                    selectedVideo?.let { video ->
                        ModalBottomSheet(
                            onDismissRequest = { selectedVideo = null },
                            sheetState = sheetState
                        ) {
                            MapBottomSheetContent(video)
                        }
                    }
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        Configuration.getInstance().load(applicationContext, android.preference.PreferenceManager.getDefaultSharedPreferences(applicationContext))
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun MapBottomSheetContent(video: Video) {
    val context = LocalContext.current
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clickable {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("vnd.youtube:${video.id}"))
                intent.putExtra("force_fullscreen", true)
                try {
                    context.startActivity(intent)
                } catch (e: Exception) {
                    val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=${video.id}"))
                    context.startActivity(webIntent)
                }
            }
            .padding(16.dp)
    ) {
        Row(horizontalArrangement = Arrangement.spacedBy(16.dp)) {
            AsyncImage(
                model = video.thumbnailUrl,
                contentDescription = video.title,
                modifier = Modifier
                    .size(120.dp, 90.dp),
                contentScale = ContentScale.Crop
            )
            Column {
                Text(
                    text = video.title,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                Text(text = "Channel: ${video.channelName}", style = MaterialTheme.typography.bodyMedium)
                Text(text = "Published: ${video.publishedAt.take(10)}", style = MaterialTheme.typography.bodySmall)
            }
        }

        Spacer(modifier = Modifier.height(8.dp))

        if (video.recordingDate != null) {
            Text(text = "Recorded: ${video.recordingDate.take(10)}", style = MaterialTheme.typography.bodySmall)
        }

        if (video.locationCity != null || video.locationCountry != null) {
            val loc = listOfNotNull(video.locationCity, video.locationCountry).joinToString(", ")
            val gps = if (video.locationLatitude != null && video.locationLongitude != null) {
                " (%.4f, %.4f)".format(video.locationLatitude, video.locationLongitude)
            } else ""
            Text(text = "Location: $loc$gps", style = MaterialTheme.typography.bodySmall)
        }

        if (video.tags.isNotEmpty()) {
            Spacer(modifier = Modifier.height(8.dp))
            FlowRow(
                horizontalArrangement = Arrangement.spacedBy(4.dp),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                video.tags.take(5).forEach { tag ->
                    SuggestionChip(
                        onClick = {},
                        label = { Text(tag, style = MaterialTheme.typography.labelSmall) }
                    )
                }
            }
        }
        Spacer(modifier = Modifier.height(16.dp))
    }
}
