package com.example.ytdash.ui.map

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.preference.PreferenceManager
import androidx.compose.foundation.clickable
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
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import com.example.ytdash.LocalTestConfig
import com.example.ytdash.ui.home.HomeUiState
import com.example.ytdash.ui.home.HomeViewModel
import org.osmdroid.config.Configuration
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MapScreen(
    onNavigateBack: () -> Unit,
    viewModel: HomeViewModel
) {
    val uiState by viewModel.uiState.collectAsState()
    val testConfig = LocalTestConfig.current
    val context = LocalContext.current

    var capturedUrl by remember { mutableStateOf<String?>(null) }
    var openError by remember { mutableStateOf(false) }

    val handleOpenVideo = { id: String ->
        val url = "https://www.youtube.com/watch?v=$id"
        if (testConfig.captureExternalLinks) {
            capturedUrl = url
        } else {
            try {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                context.startActivity(intent)
            } catch (e: ActivityNotFoundException) {
                openError = true
            }
        }
    }

    Scaffold(
        modifier = Modifier.fillMaxSize().testTag("screen_map"),
        topBar = {
            TopAppBar(
                title = { Text("Map") },
                navigationIcon = {
                    IconButton(onClick = onNavigateBack) {
                        Text("Back")
                    }
                }
            )
        }
    ) { paddingValues ->
        Box(modifier = Modifier.padding(paddingValues).fillMaxSize()) {
            Column(modifier = Modifier.fillMaxSize()) {
                if (capturedUrl != null) {
                    Surface(color = MaterialTheme.colorScheme.tertiaryContainer, modifier = Modifier.fillMaxWidth()) {
                        Text(
                            text = capturedUrl!!,
                            modifier = Modifier.padding(16.dp).testTag("external_open_url"),
                            color = MaterialTheme.colorScheme.onTertiaryContainer
                        )
                    }
                }
                if (openError) {
                    Surface(color = MaterialTheme.colorScheme.errorContainer, modifier = Modifier.fillMaxWidth()) {
                        Text(
                            text = "Error opening YouTube",
                            modifier = Modifier.padding(16.dp).testTag("external_open_error"),
                            color = MaterialTheme.colorScheme.onErrorContainer
                        )
                    }
                }

                Box(modifier = Modifier.fillMaxSize()) {
                    val videosWithLoc = if (uiState is HomeUiState.Content) {
                        (uiState as HomeUiState.Content).videos.filter { it.lat != null && it.lng != null }
                    } else emptyList()

                    AndroidView(
                        factory = { ctx ->
                            Configuration.getInstance().load(ctx, PreferenceManager.getDefaultSharedPreferences(ctx))
                            Configuration.getInstance().userAgentValue = ctx.packageName
                            MapView(ctx).apply {
                                setMultiTouchControls(true)
                                controller.setZoom(2.0)
                                controller.setCenter(GeoPoint(0.0, 0.0))
                            }
                        },
                        update = { mapView ->
                            mapView.overlays.clear()
                            videosWithLoc.forEach { video ->
                                val marker = Marker(mapView)
                                marker.position = GeoPoint(video.lat!!, video.lng!!)
                                marker.title = video.title
                                marker.setAnchor(Marker.ANCHOR_CENTER, Marker.ANCHOR_BOTTOM)
                                mapView.overlays.add(marker)
                            }
                            mapView.invalidate()
                        },
                        modifier = Modifier.fillMaxSize().testTag("map_view")
                    )

                    // Native markers overlay at the bottom
                    if (videosWithLoc.isNotEmpty()) {
                        LazyRow(
                            modifier = Modifier
                                .align(Alignment.BottomCenter)
                                .fillMaxWidth()
                                .padding(16.dp),
                            horizontalArrangement = Arrangement.spacedBy(8.dp)
                        ) {
                            items(videosWithLoc, key = { it.id }) { video ->
                                Surface(
                                    modifier = Modifier
                                        .clickable { handleOpenVideo(video.id) }
                                        .testTag("map_marker"),
                                    color = MaterialTheme.colorScheme.surfaceVariant,
                                    shape = MaterialTheme.shapes.small
                                ) {
                                    Text(
                                        text = video.title,
                                        modifier = Modifier.padding(horizontal = 12.dp, vertical = 8.dp).testTag("map_marker_title"),
                                        style = MaterialTheme.typography.labelLarge
                                    )
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
