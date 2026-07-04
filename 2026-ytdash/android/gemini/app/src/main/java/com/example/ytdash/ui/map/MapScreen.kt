package com.example.ytdash.ui.map

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.testTagsAsResourceId
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import com.example.ytdash.TestConfig
import com.example.ytdash.domain.models.Video
import org.osmdroid.config.Configuration
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MapScreen(
    videos: List<Video>,
    testConfig: TestConfig,
    onBack: () -> Unit
) {
    val context = LocalContext.current
    var selectedVideo by remember { mutableStateOf<Video?>(null) }
    var externalUrl by remember { mutableStateOf<String?>(null) }
    var externalError by remember { mutableStateOf<String?>(null) }

    val locatedVideos = videos.filter { it.lat != null && it.lng != null }

    LaunchedEffect(Unit) {
        Configuration.getInstance().userAgentValue = context.packageName
    }

    Scaffold(
        modifier = Modifier.testTag("screen_map"),
        topBar = {
            TopAppBar(
                title = { Text("Map") },
                navigationIcon = {
                    Button(onClick = onBack) { Text("Back") }
                }
            )
        }
    ) { padding ->
        Box(modifier = Modifier.padding(padding).fillMaxSize()) {
            AndroidView(
                factory = { ctx ->
                    MapView(ctx).apply {
                        setMultiTouchControls(true)
                        controller.setZoom(2.0)
                        
                        locatedVideos.forEach { video ->
                            val marker = Marker(this)
                            marker.position = GeoPoint(video.lat!!, video.lng!!)
                            marker.title = video.title
                            marker.setOnMarkerClickListener { _, _ ->
                                selectedVideo = video
                                true
                            }
                            overlays.add(marker)
                        }
                    }
                },
                modifier = Modifier.fillMaxSize()
            )

            // Fallback accessible markers for UI tests
            LazyRow(
                modifier = Modifier
                    .align(Alignment.TopCenter)
                    .fillMaxWidth()
                    .padding(8.dp)
            ) {
                items(locatedVideos) { video ->
                    AssistChip(
                        onClick = { selectedVideo = video },
                        label = { Text(video.title) },
                        modifier = Modifier.testTag("map_marker").padding(horizontal = 4.dp)
                    )
                }
            }

            // Bottom sheet for selected video
            if (selectedVideo != null) {
                Surface(
                    modifier = Modifier
                        .align(Alignment.BottomCenter)
                        .fillMaxWidth()
                        .testTag("detail_bottom_sheet")
                        .semantics { testTagsAsResourceId = true },
                    color = MaterialTheme.colorScheme.surfaceVariant,
                    shadowElevation = 8.dp
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(selectedVideo!!.title, style = MaterialTheme.typography.titleLarge)
                        Text(selectedVideo!!.youtubeUrl, modifier = Modifier.testTag("detail_video_url"))
                        
                        Spacer(modifier = Modifier.height(16.dp))
                        
                        Row {
                            Button(
                                onClick = {
                                    if (testConfig.captureExternalLinks) {
                                        externalUrl = selectedVideo!!.youtubeUrl
                                    } else {
                                        try {
                                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(selectedVideo!!.youtubeUrl))
                                            context.startActivity(intent)
                                        } catch (e: Exception) {
                                            externalError = "Failed to open YouTube"
                                        }
                                    }
                                },
                                modifier = Modifier.testTag("detail_open_youtube_button")
                            ) {
                                Text("Open in YouTube")
                            }
                            
                            Spacer(modifier = Modifier.width(8.dp))
                            
                            Button(onClick = { selectedVideo = null }) {
                                Text("Close")
                            }
                        }
                    }
                }
            }

            // External link banners
            if (externalUrl != null) {
                Surface(color = MaterialTheme.colorScheme.primaryContainer, modifier = Modifier.align(Alignment.TopCenter).fillMaxWidth()) {
                    Text(externalUrl!!, modifier = Modifier.testTag("external_open_url").padding(16.dp))
                }
            }
            if (externalError != null) {
                Surface(color = MaterialTheme.colorScheme.errorContainer, modifier = Modifier.align(Alignment.TopCenter).fillMaxWidth()) {
                    Text(externalError!!, modifier = Modifier.testTag("external_open_error").padding(16.dp))
                }
            }
        }
    }
}
