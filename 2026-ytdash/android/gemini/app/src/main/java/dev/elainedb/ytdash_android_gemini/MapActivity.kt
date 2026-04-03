package dev.elainedb.ytdash_android_gemini

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.preference.PreferenceManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.lifecycleScope
import coil.compose.AsyncImage
import dev.elainedb.ytdash_android_gemini.database.VideoDatabase
import dev.elainedb.ytdash_android_gemini.database.VideoEntity
import dev.elainedb.ytdash_android_gemini.database.toVideo
import dev.elainedb.ytdash_android_gemini.model.Video
import dev.elainedb.ytdash_android_gemini.ui.theme.YTDashAGeminiTheme
import kotlinx.coroutines.launch
import org.osmdroid.config.Configuration
import org.osmdroid.util.BoundingBox
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker

@OptIn(ExperimentalMaterial3Api::class)
class MapActivity : ComponentActivity() {

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Initialize osmdroid configuration
        val ctx = applicationContext
        Configuration.getInstance().load(ctx, PreferenceManager.getDefaultSharedPreferences(ctx))
        Configuration.getInstance().userAgentValue = packageName

        val db = VideoDatabase.getDatabase(this)
        
        setContent {
            YTDashAGeminiTheme {
                var videos by remember { mutableStateOf<List<Video>>(emptyList()) }
                var selectedVideo by remember { mutableStateOf<Video?>(null) }
                val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = false)

                LaunchedEffect(Unit) {
                    val entities = db.videoDao().getVideosWithLocation()
                    videos = entities.map { it.toVideo() }
                }

                Scaffold(
                    topBar = {
                        TopAppBar(
                            title = { Text("Map View") },
                            colors = TopAppBarDefaults.topAppBarColors(
                                containerColor = MaterialTheme.colorScheme.primaryContainer,
                                titleContentColor = MaterialTheme.colorScheme.onPrimaryContainer
                            )
                        )
                    }
                ) { innerPadding ->
                    Box(modifier = Modifier.padding(innerPadding).fillMaxSize()) {
                        AndroidView(
                            factory = { context ->
                                MapView(context).apply {
                                    setMultiTouchControls(true)
                                }
                            },
                            update = { mapView ->
                                mapView.overlays.clear()
                                if (videos.isNotEmpty()) {
                                    val points = mutableListOf<GeoPoint>()
                                    videos.forEach { video ->
                                        if (video.locationLatitude != null && video.locationLongitude != null) {
                                            val point = GeoPoint(video.locationLatitude, video.locationLongitude)
                                            points.add(point)
                                            val marker = Marker(mapView)
                                            marker.position = point
                                            marker.title = video.title
                                            marker.setAnchor(Marker.ANCHOR_CENTER, Marker.ANCHOR_BOTTOM)
                                            marker.setOnMarkerClickListener { _, _ ->
                                                selectedVideo = video
                                                true
                                            }
                                            mapView.overlays.add(marker)
                                        }
                                    }
                                    
                                    if (points.isNotEmpty()) {
                                        val boundingBox = BoundingBox.fromGeoPoints(points)
                                        // Wait until map is laid out to zoom to bounding box
                                        mapView.post {
                                            mapView.zoomToBoundingBox(boundingBox, true, 100)
                                        }
                                    }
                                }
                                mapView.invalidate()
                            },
                            modifier = Modifier.fillMaxSize()
                        )
                    }
                }

                if (selectedVideo != null) {
                    val configuration = androidx.compose.ui.platform.LocalConfiguration.current
                    val maxSheetHeight = (configuration.screenHeightDp * 0.25).dp
                    
                    ModalBottomSheet(
                        onDismissRequest = { selectedVideo = null },
                        sheetState = sheetState,
                        modifier = Modifier.heightIn(max = maxSheetHeight)
                    ) {
                        VideoBottomSheetContent(
                            video = selectedVideo!!,
                            onClick = {
                                openYouTube(selectedVideo!!)
                            }
                        )
                    }
                }
            }
        }
    }

    private fun openYouTube(video: Video) {
        val intent = Intent(Intent.ACTION_VIEW, Uri.parse("vnd.youtube:${video.id}"))
        intent.addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
        try {
            startActivity(intent)
        } catch (e: Exception) {
            val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=${video.id}"))
            startActivity(webIntent)
        }
    }

    override fun onResume() {
        super.onResume()
        Configuration.getInstance().load(applicationContext, PreferenceManager.getDefaultSharedPreferences(applicationContext))
    }

    companion object {
        fun newIntent(context: Context): Intent {
            return Intent(context, MapActivity::class.java)
        }
    }
}

@Composable
fun VideoBottomSheetContent(video: Video, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxSize()
            .clickable(onClick = onClick)
            .padding(horizontal = 16.dp, vertical = 8.dp)
    ) {
        AsyncImage(
            model = video.thumbnailUrl,
            contentDescription = "Video Thumbnail",
            contentScale = ContentScale.Crop,
            modifier = Modifier
                .size(120.dp, 90.dp)
                .padding(end = 12.dp)
        )
        Column(modifier = Modifier.fillMaxWidth()) {
            Text(
                text = video.title,
                style = MaterialTheme.typography.titleMedium,
                maxLines = 2,
                overflow = TextOverflow.Ellipsis
            )
            Text(
                text = video.channelName,
                style = MaterialTheme.typography.bodyMedium,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Text(
                text = "Published: ${video.publishedAt}",
                style = MaterialTheme.typography.bodySmall
            )
            if (video.recordingDate != null) {
                Text(
                    text = "Recorded: ${video.recordingDate}",
                    style = MaterialTheme.typography.bodySmall
                )
            }
            if (video.locationCity != null || video.locationCountry != null) {
                val loc = listOfNotNull(video.locationCity, video.locationCountry).joinToString(", ")
                Text(
                    text = "Location: $loc",
                    style = MaterialTheme.typography.bodySmall
                )
            }
            if (video.tags.isNotEmpty()) {
                Text(
                    text = "Tags: ${video.tags.take(3).joinToString(", ")}",
                    style = MaterialTheme.typography.bodySmall,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )
            }
        }
    }
}