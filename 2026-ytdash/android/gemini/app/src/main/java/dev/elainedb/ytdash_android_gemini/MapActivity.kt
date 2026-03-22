package dev.elainedb.ytdash_android_gemini

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.lifecycleScope
import coil.compose.AsyncImage
import dev.elainedb.ytdash_android_gemini.data.local.VideoDatabase
import dev.elainedb.ytdash_android_gemini.data.local.VideoEntity
import dev.elainedb.ytdash_android_gemini.ui.theme.YTDashAGeminiTheme
import kotlinx.coroutines.flow.first
import kotlinx.coroutines.launch
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
        enableEdgeToEdge()

        // Initialize osmdroid configuration
        Configuration.getInstance().load(applicationContext, getSharedPreferences("osmdroid", MODE_PRIVATE))

        val db = VideoDatabase.getDatabase(this)
        val videoDao = db.videoDao()

        setContent {
            YTDashAGeminiTheme {
                var videos by remember { mutableStateOf<List<VideoEntity>>(emptyList()) }
                var selectedVideo by remember { mutableStateOf<VideoEntity?>(null) }
                val sheetState = rememberModalBottomSheetState()
                var isSheetOpen by remember { mutableStateOf(false) }

                LaunchedEffect(Unit) {
                    videos = videoDao.getVideosWithLocation().first()
                }

                Scaffold(
                    topBar = {
                        TopAppBar(
                            title = { Text("Map View") },
                            colors = TopAppBarDefaults.topAppBarColors(
                                containerColor = MaterialTheme.colorScheme.primary,
                                titleContentColor = MaterialTheme.colorScheme.onPrimary
                            )
                        )
                    }
                ) { paddingValues ->
                    Box(modifier = Modifier.padding(paddingValues).fillMaxSize()) {
                        AndroidView(
                            factory = { context ->
                                MapView(context).apply {
                                    setTileSource(TileSourceFactory.MAPNIK)
                                    setMultiTouchControls(true)
                                }
                            },
                            update = { mapView ->
                                mapView.overlays.clear()
                                val points = mutableListOf<GeoPoint>()
                                videos.forEach { video ->
                                    val lat = video.locationLatitude
                                    val lon = video.locationLongitude
                                    if (lat != null && lon != null) {
                                        val geoPoint = GeoPoint(lat, lon)
                                        points.add(geoPoint)
                                        val marker = Marker(mapView).apply {
                                            position = geoPoint
                                            title = video.title
                                            setOnMarkerClickListener { _, _ ->
                                                selectedVideo = video
                                                isSheetOpen = true
                                                true
                                            }
                                        }
                                        mapView.overlays.add(marker)
                                    }
                                }
                                if (points.isNotEmpty()) {
                                    val boundingBox = BoundingBox.fromGeoPoints(points)
                                    mapView.post {
                                        mapView.zoomToBoundingBox(boundingBox, true, 100)
                                    }
                                }
                                mapView.invalidate()
                            },
                            modifier = Modifier.fillMaxSize()
                        )

                        if (isSheetOpen && selectedVideo != null) {
                            ModalBottomSheet(
                                onDismissRequest = { isSheetOpen = false },
                                sheetState = sheetState,
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                VideoBottomSheetContent(video = selectedVideo!!)
                            }
                        }
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun VideoBottomSheetContent(video: VideoEntity) {
    val context = LocalContext.current
    Column(
        modifier = Modifier
            .fillMaxWidth()
            .clickable {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("vnd.youtube:${video.id}"))
                try {
                    context.startActivity(intent)
                } catch (e: ActivityNotFoundException) {
                    val browserIntent = Intent(
                        Intent.ACTION_VIEW,
                        Uri.parse("https://www.youtube.com/watch?v=${video.id}")
                    )
                    context.startActivity(browserIntent)
                }
            }
            .padding(16.dp)
            .padding(bottom = 32.dp)
    ) {
        AsyncImage(
            model = video.thumbnailUrl,
            contentDescription = "Thumbnail for ${video.title}",
            modifier = Modifier
                .fillMaxWidth()
                .aspectRatio(16f / 9f)
                .clip(RoundedCornerShape(8.dp))
        )
        Spacer(modifier = Modifier.height(16.dp))
        Text(
            text = video.title,
            style = MaterialTheme.typography.titleMedium,
            maxLines = 2
        )
        Spacer(modifier = Modifier.height(8.dp))
        Text(
            text = video.channelName,
            style = MaterialTheme.typography.bodyMedium
        )
        Spacer(modifier = Modifier.height(4.dp))

        val formattedDate = video.publishedAt.substringBefore("T")
        Text(
            text = "Published: $formattedDate",
            style = MaterialTheme.typography.bodySmall
        )

        if (video.recordingDate != null) {
            Text(
                text = "Recorded: ${video.recordingDate.substringBefore("T")}",
                style = MaterialTheme.typography.bodySmall
            )
        }

        if (video.locationCity != null || video.locationCountry != null) {
            val locationStr = listOfNotNull(video.locationCity, video.locationCountry).joinToString(", ")
            val gpsStr = if (video.locationLatitude != null && video.locationLongitude != null) {
                " (${video.locationLatitude}, ${video.locationLongitude})"
            } else ""
            Text(
                text = "Location: $locationStr$gpsStr",
                style = MaterialTheme.typography.bodySmall
            )
        }

        if (video.tags.isNotBlank()) {
            Spacer(modifier = Modifier.height(8.dp))
            val tagsList = video.tags.split(",").map { it.trim() }.filter { it.isNotEmpty() }
            FlowRow(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(4.dp),
                verticalArrangement = Arrangement.spacedBy(4.dp)
            ) {
                tagsList.take(5).forEach { tag ->
                    Box(
                        modifier = Modifier
                            .clip(RoundedCornerShape(8.dp))
                            .background(MaterialTheme.colorScheme.secondaryContainer)
                            .padding(horizontal = 8.dp, vertical = 4.dp)
                    ) {
                        Text(
                            text = tag,
                            style = MaterialTheme.typography.labelSmall,
                            color = MaterialTheme.colorScheme.onSecondaryContainer
                        )
                    }
                }
            }
        }
    }
}
