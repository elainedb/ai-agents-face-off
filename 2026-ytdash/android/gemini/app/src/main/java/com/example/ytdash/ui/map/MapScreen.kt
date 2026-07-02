package com.example.ytdash.ui.map

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material.icons.filled.Close
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.testTagsAsResourceId
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import com.example.ytdash.TestConfig
import com.example.ytdash.data.DefaultDataRepository
import com.example.ytdash.data.Video
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MapScreen(
    onBack: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current.applicationContext
    val repository = remember { DefaultDataRepository(context) }
    val videosState by repository.videos.collectAsState(initial = emptyList())

    // Filter videos with location
    val locatedVideos = remember(videosState) {
        videosState.filter { it.location != null }
    }

    var selectedVideo by remember { mutableStateOf<Video?>(null) }
    var externalOpenError by remember { mutableStateOf<String?>(null) }
    var capturedUrl by remember { mutableStateOf<String?>(null) }

    val handleVideoClick = { video: Video ->
        Log.d("MapScreen", "Tapped video: '${video.title}' with URL: ${video.youtubeUrl}")
        if (TestConfig.captureExternalLinks) {
            capturedUrl = video.youtubeUrl
            TestConfig.lastCapturedUrl = video.youtubeUrl
            Log.d("MapScreen", "Captured external URL: ${TestConfig.lastCapturedUrl}")
        } else {
            try {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(video.youtubeUrl)).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
                externalOpenError = null
            } catch (e: Exception) {
                Log.e("MapScreen", "Failed to launch external YouTube experience", e)
                externalOpenError = "Failed to open video in YouTube."
            }
        }
    }

    Box(
        modifier = modifier
            .fillMaxSize()
            .testTag("screen_map")
            .semantics { testTagsAsResourceId = true }
    ) {
        // 1. Map View
        AndroidView(
            modifier = Modifier.fillMaxSize(),
            factory = { ctx ->
                Configuration.getInstance().userAgentValue = ctx.packageName
                MapView(ctx).apply {
                    setTileSource(TileSourceFactory.MAPNIK)
                    setMultiTouchControls(true)
                    controller.setZoom(3.5)
                    // Center on a default general location (e.g. Europe/Atlantic)
                    controller.setCenter(GeoPoint(35.0, -10.0))
                }
            },
            update = { mapView ->
                mapView.overlays.clear()
                locatedVideos.forEach { video ->
                    val loc = video.location ?: return@forEach
                    val marker = Marker(mapView).apply {
                        position = GeoPoint(loc.lat, loc.lng)
                        title = video.title
                        snippet = video.category
                        setAnchor(Marker.ANCHOR_CENTER, Marker.ANCHOR_BOTTOM)
                        setOnMarkerClickListener { m, _ ->
                            m.showInfoWindow()
                            selectedVideo = video
                            true
                        }
                    }
                    mapView.overlays.add(marker)
                }
                mapView.invalidate()
            }
        )

        // 2. Top Bar
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .align(Alignment.TopCenter),
            color = MaterialTheme.colorScheme.surface.copy(alpha = 0.9f),
            shadowElevation = 4.dp
        ) {
            Row(
                modifier = Modifier
                    .statusBarsPadding()
                    .fillMaxWidth()
                    .padding(horizontal = 8.dp, vertical = 12.dp),
                verticalAlignment = Alignment.CenterVertically
            ) {
                IconButton(onClick = onBack) {
                    Icon(imageVector = Icons.Default.ArrowBack, contentDescription = "Back")
                }
                Spacer(modifier = Modifier.width(8.dp))
                Text(
                    text = "Video Map",
                    fontSize = 20.sp,
                    fontWeight = FontWeight.Bold,
                    color = MaterialTheme.colorScheme.onSurface
                )
                Spacer(modifier = Modifier.weight(1f))
                Text(
                    text = "${locatedVideos.size} located",
                    fontSize = 14.sp,
                    color = MaterialTheme.colorScheme.primary,
                    fontWeight = FontWeight.SemiBold,
                    modifier = Modifier.padding(end = 12.dp)
                )
            }
        }

        // 3. Floating Horizontal AssistChips Overlay (MANDATORY map_marker tags)
        if (locatedVideos.isNotEmpty()) {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .align(Alignment.BottomCenter)
                    .padding(bottom = if (selectedVideo != null) 250.dp else 16.dp)
                    .background(Color.Transparent)
            ) {
                LazyRow(
                    modifier = Modifier.fillMaxWidth(),
                    contentPadding = PaddingValues(horizontal = 16.dp),
                    horizontalArrangement = Arrangement.spacedBy(8.dp)
                ) {
                    items(locatedVideos) { video ->
                        AssistChip(
                            onClick = {
                                selectedVideo = video
                            },
                            label = {
                                Text(
                                    text = video.title,
                                    maxLines = 1,
                                    overflow = TextOverflow.Ellipsis,
                                    fontSize = 12.sp,
                                    fontWeight = FontWeight.Medium
                                )
                            },
                            leadingIcon = {
                                Icon(
                                    imageVector = Icons.Default.LocationOn,
                                    contentDescription = "Marker",
                                    tint = MaterialTheme.colorScheme.primary,
                                    modifier = Modifier.size(16.dp)
                                )
                            },
                            modifier = Modifier.testTag("map_marker"),
                            colors = AssistChipDefaults.assistChipColors(
                                containerColor = if (selectedVideo?.id == video.id) {
                                    MaterialTheme.colorScheme.primaryContainer
                                } else {
                                    MaterialTheme.colorScheme.surface.copy(alpha = 0.9f)
                                }
                            )
                        )
                    }
                }
            }
        }

        // 4. Detail Bottom Sheet (MANDATORY detail_bottom_sheet, detail_video_url, detail_open_youtube_button)
        val currentVideo = selectedVideo
        if (currentVideo != null) {
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(230.dp)
                    .align(Alignment.BottomCenter)
                    .testTag("detail_bottom_sheet")
                    .clickable { /* consume clicks */ },
                shape = RoundedCornerShape(topStart = 16.dp, topEnd = 16.dp),
                colors = CardDefaults.cardColors(
                    containerColor = MaterialTheme.colorScheme.surfaceColorAtElevation(8.dp)
                ),
                elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
            ) {
                Column(
                    modifier = Modifier
                        .fillMaxSize()
                        .padding(16.dp)
                ) {
                    Row(
                        modifier = Modifier.fillMaxWidth(),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = currentVideo.category.uppercase(),
                            fontSize = 11.sp,
                            fontWeight = FontWeight.Bold,
                            color = MaterialTheme.colorScheme.primary,
                            modifier = Modifier
                                .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.15f), RoundedCornerShape(4.dp))
                                .padding(horizontal = 6.dp, vertical = 2.dp)
                        )
                        IconButton(
                            onClick = { selectedVideo = null },
                            modifier = Modifier.size(24.dp)
                        ) {
                            Icon(
                                imageVector = Icons.Default.Close,
                                contentDescription = "Close",
                                tint = MaterialTheme.colorScheme.onSurfaceVariant
                            )
                        }
                    }

                    Spacer(modifier = Modifier.height(8.dp))

                    Text(
                        text = currentVideo.title,
                        fontSize = 16.sp,
                        fontWeight = FontWeight.Bold,
                        color = MaterialTheme.colorScheme.onSurface,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )

                    Spacer(modifier = Modifier.height(4.dp))

                    Text(
                        text = currentVideo.description,
                        fontSize = 12.sp,
                        color = MaterialTheme.colorScheme.onSurfaceVariant,
                        maxLines = 2,
                        overflow = TextOverflow.Ellipsis,
                        modifier = Modifier.weight(1f)
                    )

                    Spacer(modifier = Modifier.height(4.dp))

                    // Exactly formatted URL (copyable)
                    Text(
                        text = currentVideo.youtubeUrl,
                        modifier = Modifier.testTag("detail_video_url"),
                        fontSize = 11.sp,
                        color = MaterialTheme.colorScheme.primary,
                        maxLines = 1,
                        overflow = TextOverflow.Ellipsis
                    )

                    Spacer(modifier = Modifier.height(8.dp))

                    Button(
                        onClick = { handleVideoClick(currentVideo) },
                        modifier = Modifier
                            .fillMaxWidth()
                            .testTag("detail_open_youtube_button"),
                        shape = RoundedCornerShape(8.dp)
                    ) {
                        Text(text = "Open in YouTube", fontWeight = FontWeight.Bold)
                    }
                }
            }
        }

        // 5. Overlay for captured external links (MANDATORY external_open_url)
        if (capturedUrl != null) {
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .align(Alignment.BottomCenter)
                    .padding(16.dp)
                    .clickable { /* consume clicks */ },
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(text = "Test Link Captured", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.onPrimaryContainer)
                        Text(
                            text = capturedUrl!!,
                            modifier = Modifier.testTag("external_open_url"),
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onPrimaryContainer
                        )
                    }
                    IconButton(onClick = { capturedUrl = null }) {
                        Icon(imageVector = Icons.Default.Close, contentDescription = "Close", tint = MaterialTheme.colorScheme.onPrimaryContainer)
                    }
                }
            }
        }

        // 6. Overlay for external open failures (MANDATORY external_open_error)
        if (externalOpenError != null) {
            Card(
                modifier = Modifier
                    .fillMaxWidth()
                    .align(Alignment.BottomCenter)
                    .padding(16.dp)
                    .clickable { /* consume clicks */ },
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.errorContainer)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        text = externalOpenError!!,
                        modifier = Modifier.testTag("external_open_error"),
                        fontSize = 14.sp,
                        color = MaterialTheme.colorScheme.onErrorContainer
                    )
                    IconButton(onClick = { externalOpenError = null }) {
                        Icon(imageVector = Icons.Default.Close, contentDescription = "Close", tint = MaterialTheme.colorScheme.onErrorContainer)
                    }
                }
            }
        }
    }
}
