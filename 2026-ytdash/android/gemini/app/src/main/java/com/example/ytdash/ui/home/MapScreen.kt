package com.example.ytdash.ui.home

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.LocalLifecycleOwner
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.testTagsAsResourceId
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.Lifecycle
import androidx.lifecycle.LifecycleEventObserver
import com.example.ytdash.data.model.VideoEntity
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MapScreen(
    viewModel: HomeViewModel,
    onBack: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current
    val config = viewModel.getConfig()
    
    // Bottom Sheet state
    var selectedVideo by remember { mutableStateOf<VideoEntity?>(null) }
    var capturedUrl by remember { mutableStateOf<String?>(null) }
    var externalError by remember { mutableStateOf<String?>(null) }

    val handleOpenYoutube = { videoId: String ->
        val url = "https://www.youtube.com/watch?v=$videoId"
        if (config.captureExternalLinks) {
            capturedUrl = url
        } else {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            try {
                context.startActivity(intent)
            } catch (e: Exception) {
                externalError = "Could not open video: ${e.message}"
            }
        }
    }

    Scaffold(
        modifier = Modifier
            .testTag("screen_map")
            .semantics { testTagsAsResourceId = true },
        topBar = {
            TopAppBar(
                title = { Text("Map") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Text("Back")
                    }
                }
            )
        }
    ) { padding ->
        Box(modifier = Modifier.fillMaxSize().padding(padding)) {
            // MapView requires UserAgent configuration
            Configuration.getInstance().userAgentValue = context.packageName

            val lifecycleOwner = LocalLifecycleOwner.current

            AndroidView(
                modifier = Modifier.fillMaxSize(),
                factory = { ctx ->
                    MapView(ctx).apply {
                        setTileSource(TileSourceFactory.MAPNIK)
                        setMultiTouchControls(true)
                        controller.setZoom(2.0)
                        controller.setCenter(GeoPoint(0.0, 0.0))
                    }
                },
                update = { mapView ->
                    mapView.overlays.clear()
                    
                    uiState.videos.filter { it.lat != null && it.lng != null }.forEach { video ->
                        val marker = Marker(mapView)
                        marker.position = GeoPoint(video.lat!!, video.lng!!)
                        marker.title = video.title
                        // Assigning id for semantic purposes, but osmdroid markers don't automatically expose testTags.
                        // Wait, per spec, we might need a fallback if markers aren't accessible.
                        marker.setOnMarkerClickListener { _, _ ->
                            selectedVideo = video
                            capturedUrl = null
                            externalError = null
                            true
                        }
                        mapView.overlays.add(marker)
                    }
                    mapView.invalidate()
                }
            )

            // Fallback for markers accessibility if Osmdroid markers are invisible to Maestro:
            // "Therefore every build MUST expose map_marker on a native, accessible affordance - an overlay button or a markers list row per located video"
            // Let's just overlay an invisible column of buttons? Or just a visible column of buttons at the bottom.
            Column(
                modifier = Modifier
                    .align(Alignment.BottomStart)
                    .padding(16.dp)
            ) {
                uiState.videos.filter { it.lat != null && it.lng != null }.forEach { video ->
                    Button(
                        onClick = { 
                            selectedVideo = video 
                            capturedUrl = null
                            externalError = null
                        },
                        modifier = Modifier.testTag("map_marker")
                    ) {
                        Text(video.title)
                    }
                }
            }

            if (selectedVideo != null) {
                ModalBottomSheet(
                    onDismissRequest = { selectedVideo = null },
                    modifier = Modifier.semantics { testTagsAsResourceId = true }.testTag("detail_bottom_sheet")
                ) {
                    Column(modifier = Modifier.padding(16.dp)) {
                        Text(text = selectedVideo!!.title, style = MaterialTheme.typography.titleLarge)
                        Spacer(modifier = Modifier.height(8.dp))
                        Text(
                            text = "https://www.youtube.com/watch?v=${selectedVideo!!.id}",
                            modifier = Modifier.testTag("detail_video_url")
                        )
                        Spacer(modifier = Modifier.height(16.dp))
                        Button(
                            onClick = { handleOpenYoutube(selectedVideo!!.id) },
                            modifier = Modifier.testTag("detail_open_youtube_button")
                        ) {
                            Text("Open in YouTube")
                        }
                        
                        if (capturedUrl != null) {
                            Text(
                                text = capturedUrl!!,
                                modifier = Modifier.testTag("external_open_url"),
                                color = MaterialTheme.colorScheme.primary
                            )
                        }
                        if (externalError != null) {
                            Text(
                                text = externalError!!,
                                modifier = Modifier.testTag("external_open_error"),
                                color = MaterialTheme.colorScheme.error
                            )
                        }
                        Spacer(modifier = Modifier.height(32.dp))
                    }
                }
            }
        }
    }
}
