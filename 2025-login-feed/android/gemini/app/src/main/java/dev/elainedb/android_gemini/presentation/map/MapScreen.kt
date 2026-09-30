package dev.elainedb.android_gemini.presentation.map

import android.content.Context
import android.content.Intent
import android.graphics.drawable.Drawable
import android.net.Uri
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.size
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.Card
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.ExperimentalMaterial3Api
import androidx.compose.material3.Icon
import androidx.compose.material3.IconButton
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Scaffold
import androidx.compose.material3.Text
import androidx.compose.material3.TopAppBar
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.rememberCoroutineScope
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.res.painterResource
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import coil.compose.rememberAsyncImagePainter
import dev.elainedb.android_gemini.R
import dev.elainedb.android_gemini.data.database.YoutubeVideoWithTagsAndLocation
import kotlinx.coroutines.launch
import org.koin.androidx.compose.koinViewModel
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.BoundingBox
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker
import androidx.compose.material3.rememberModalBottomSheetState
import androidx.compose.material3.ModalBottomSheet

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MapScreen(onBack: () -> Unit) {
    val viewModel: MapViewModel = koinViewModel()
    val videos by viewModel.videosWithLocation.collectAsState()
    var selectedVideo by remember { mutableStateOf<YoutubeVideoWithTagsAndLocation?>(null) }
    val sheetState = rememberModalBottomSheetState()
    val scope = rememberCoroutineScope()
    var showBottomSheet by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            MapTopBar(onBack)
        }
    ) { paddingValues ->
        Box(modifier = Modifier.padding(paddingValues)) {
            if (videos.isEmpty()) {
                CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
            } else {
                MapView(videos = videos, onMarkerClick = {
                    selectedVideo = it
                    showBottomSheet = true
                })
            }
        }
    }

    if (showBottomSheet) {
        ModalBottomSheet(
            onDismissRequest = {
                showBottomSheet = false
            },
            sheetState = sheetState
        ) {
            selectedVideo?.let { video ->
                VideoDetailsBottomSheet(video)
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MapTopBar(onBack: () -> Unit) {
    TopAppBar(
        title = { Text("Videos Map") },
        navigationIcon = {
            IconButton(onClick = onBack) {
                Icon(Icons.Default.ArrowBack, contentDescription = "Back")
            }
        }
    )
}

@Composable
fun MapView(
    videos: List<YoutubeVideoWithTagsAndLocation>,
    onMarkerClick: (YoutubeVideoWithTagsAndLocation) -> Unit
) {
    val context = LocalContext.current
    val mapView = remember {
        MapView(context).apply {
            setTileSource(TileSourceFactory.MAPNIK)
            setMultiTouchControls(true)
        }
    }

    AndroidView({ mapView }) {
        mapView.overlays.clear()
        val validVideos = videos.filter {
            it.location != null && it.location.latitude in -85.0511..85.0511
        }
        val markers = validVideos.mapNotNull { video ->
            video.location?.let { location ->
                val marker = Marker(mapView)
                marker.position = GeoPoint(location.latitude, location.longitude)
                marker.setAnchor(Marker.ANCHOR_CENTER, Marker.ANCHOR_BOTTOM)
                marker.title = video.video.title
                marker.setOnMarkerClickListener { _, _ ->
                    onMarkerClick(video)
                    true
                }
                marker
            }
        }
        mapView.overlays.addAll(markers)
        mapView.invalidate()

        if (markers.isNotEmpty()) {
            if (markers.size > 1) {
                // Zoom to bounding box for multiple markers
                val boundingBox = BoundingBox.fromGeoPoints(markers.map { it.position })
                mapView.post {
                    mapView.zoomToBoundingBox(boundingBox, true, 100)
                }
            } else {
                // Center and zoom on a single marker
                mapView.controller.setZoom(15.0)
                mapView.controller.setCenter(markers.first().position)
            }
        }
    }
}

@Composable
fun VideoDetailsBottomSheet(video: YoutubeVideoWithTagsAndLocation) {
    val context = LocalContext.current
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp)
            .clickable {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=${video.video.videoId}"))
                context.startActivity(intent)
            }
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Row {
                Image(
                    painter = rememberAsyncImagePainter(video.video.thumbnailUrl),
                    contentDescription = "Video Thumbnail",
                    modifier = Modifier.size(120.dp)
                )
                Column(modifier = Modifier.padding(start = 16.dp)) {
                    Text(text = video.video.title, style = MaterialTheme.typography.titleMedium)
                    Text(text = video.video.channelTitle, style = MaterialTheme.typography.bodyMedium)
                    Text(text = video.video.publishedAt, style = MaterialTheme.typography.bodySmall)
                }
            }
            Spacer(modifier = Modifier.height(16.dp))
            Text(text = "Tags: ${video.tags.joinToString(", ") { it.tag }}")
            video.location?.let {
                Text(text = "Location: ${it.city}, ${it.country} (${it.latitude}, ${it.longitude})")
            }
            video.video.recordingDate?.let {
                Text(text = "Recorded on: $it")
            }
        }
    }
}
