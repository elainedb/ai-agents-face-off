package com.example.ytdash.ui.view

import android.content.Context
import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import com.example.ytdash.data.model.Video
import com.example.ytdash.ui.viewmodel.MainViewModel
import com.example.ytdash.ui.viewmodel.UiState
import org.osmdroid.config.Configuration
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker

@Composable
fun MapTab(
    viewModel: MainViewModel,
    modifier: Modifier = Modifier
) {
    val videosState by viewModel.videosState.collectAsState()
    val selectedVideo by viewModel.selectedVideo.collectAsState()
    val context = LocalContext.current

    Box(
        modifier = modifier
            .fillMaxSize()
            .testTag("screen_map")
    ) {
        when (val state = videosState) {
            is UiState.Success -> {
                val locatedVideos = state.data.filter { it.lat != null && it.lng != null }
                
                if (locatedVideos.isEmpty()) {
                    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Text("No located videos to display", color = Color.Gray)
                    }
                } else {
                    // Render Map
                    MapViewContainer(
                        videos = locatedVideos,
                        selectedVideo = selectedVideo,
                        onVideoSelected = { viewModel.selectVideoForDetail(it) }
                    )

                    // Top row: Accessible AssistChips representing located videos
                    LazyRow(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(8.dp)
                            .align(Alignment.TopCenter),
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        items(locatedVideos) { video ->
                            AssistChip(
                                onClick = { viewModel.selectVideoForDetail(video) },
                                label = {
                                    Text(
                                        text = video.title,
                                        maxLines = 1,
                                        overflow = TextOverflow.Ellipsis,
                                        color = if (selectedVideo?.id == video.id) Color.Red else Color.White
                                    )
                                },
                                modifier = Modifier.testTag("map_marker"),
                                colors = AssistChipDefaults.assistChipColors(
                                    containerColor = Color(0xFF1E1E24).copy(alpha = 0.9f)
                                )
                            )
                        }
                    }

                    // Bottom sheet: Custom inline absolute-positioned details overlay to bypass standard Compose dialog isolation issues
                    selectedVideo?.let { video ->
                        Box(
                            modifier = Modifier
                                .fillMaxWidth()
                                .align(Alignment.BottomCenter)
                                .padding(horizontal = 16.dp, vertical = 24.dp)
                        ) {
                            Surface(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .testTag("detail_bottom_sheet"),
                                shape = RoundedCornerShape(20.dp),
                                color = Color(0xFF1E1E24).copy(alpha = 0.95f),
                                border = AssistChipDefaults.assistChipBorder(
                                    enabled = true,
                                    borderColor = Color.Gray.copy(alpha = 0.5f),
                                    borderWidth = 1.dp
                                )
                            ) {
                                Column(
                                    modifier = Modifier.padding(20.dp)
                                ) {
                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        horizontalArrangement = Arrangement.SpaceBetween,
                                        verticalAlignment = Alignment.CenterVertically
                                    ) {
                                        Text(
                                            text = video.title,
                                            color = Color.White,
                                            fontWeight = FontWeight.Bold,
                                            fontSize = 18.sp,
                                            maxLines = 1,
                                            overflow = TextOverflow.Ellipsis,
                                            modifier = Modifier.weight(1f)
                                        )
                                        IconButton(
                                            onClick = { viewModel.selectVideoForDetail(null) },
                                            modifier = Modifier.size(24.dp)
                                        ) {
                                            Text("✕", color = Color.Gray, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                                        }
                                    }

                                    Spacer(modifier = Modifier.height(8.dp))

                                    // Display the exact video watch URL carrying the required test tag
                                    Text(
                                        text = video.youtubeWatchUrl,
                                        modifier = Modifier.testTag("detail_video_url"),
                                        color = Color(0xFFFF4D4D),
                                        fontSize = 13.sp,
                                        fontWeight = FontWeight.SemiBold
                                    )

                                    Spacer(modifier = Modifier.height(10.dp))

                                    Text(
                                        text = video.description,
                                        color = Color.LightGray,
                                        fontSize = 13.sp,
                                        maxLines = 2,
                                        overflow = TextOverflow.Ellipsis
                                    )

                                    Spacer(modifier = Modifier.height(20.dp))

                                    Button(
                                        onClick = {
                                            viewModel.launchVideo(video) { url ->
                                                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url)).apply {
                                                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                                                }
                                                try {
                                                    context.startActivity(intent)
                                                    true
                                                } catch (e: Exception) {
                                                    false
                                                }
                                            }
                                        },
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .height(50.dp)
                                            .testTag("detail_open_youtube_button"),
                                        shape = RoundedCornerShape(12.dp),
                                        colors = ButtonDefaults.buttonColors(
                                            containerColor = Color(0xFFFF0000),
                                            contentColor = Color.White
                                        )
                                    ) {
                                        Text(
                                            text = "Open in YouTube",
                                            fontWeight = FontWeight.Bold,
                                            fontSize = 15.sp
                                        )
                                    }
                                }
                            }
                        }
                    }
                }
            }
            is UiState.Loading -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator(color = Color(0xFFFF0000))
                }
            }
            is UiState.Error -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Text("Error loading map: ${state.message}", color = Color.Red)
                }
            }
            else -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Text("No map data available", color = Color.Gray)
                }
            }
        }
    }
}

@Composable
fun MapViewContainer(
    videos: List<Video>,
    selectedVideo: Video?,
    onVideoSelected: (Video) -> Unit
) {
    val context = LocalContext.current
    
    AndroidView(
        factory = { ctx ->
            MapView(ctx).apply {
                Configuration.getInstance().userAgentValue = ctx.packageName
                setMultiTouchControls(true)
                
                // Add Marker Overlays
                videos.forEach { video ->
                    val lat = video.lat ?: return@forEach
                    val lng = video.lng ?: return@forEach
                    val marker = Marker(this).apply {
                        position = GeoPoint(lat, lng)
                        title = video.title
                        snippet = video.description
                        setOnMarkerClickListener { m, _ ->
                            onVideoSelected(video)
                            m.showInfoWindow()
                            true
                        }
                    }
                    overlays.add(marker)
                }
                
                // Set initial zoom and center
                controller.setZoom(5.0)
                val initialPoint = if (selectedVideo != null) {
                    GeoPoint(selectedVideo.lat ?: 0.0, selectedVideo.lng ?: 0.0)
                } else {
                    GeoPoint(videos.first().lat ?: 0.0, videos.first().lng ?: 0.0)
                }
                controller.setCenter(initialPoint)
            }
        },
        update = { mapView ->
            // Update center animated when selection changes
            if (selectedVideo?.lat != null && selectedVideo.lng != null) {
                val point = GeoPoint(selectedVideo.lat, selectedVideo.lng)
                mapView.controller.animateTo(point)
                mapView.controller.setZoom(10.0)
            }
        },
        modifier = Modifier.fillMaxSize()
    )
}
