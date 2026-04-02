package dev.elainedb.ytdash_android_gemini

import android.content.Context
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.*
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ArrowBack
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import dev.elainedb.ytdash_android_gemini.models.Video
import dev.elainedb.ytdash_android_gemini.repository.YouTubeRepository
import dev.elainedb.ytdash_android_gemini.ui.screens.VideoItem
import dev.elainedb.ytdash_android_gemini.ui.theme.YTDashAGeminiTheme
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.BoundingBox
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker

class MapActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        Configuration.getInstance().load(applicationContext, applicationContext.getSharedPreferences("osmdroid", Context.MODE_PRIVATE))
        enableEdgeToEdge()
        setContent {
            YTDashAGeminiTheme {
                MapScreen(
                    onBack = { finish() },
                    repository = YouTubeRepository(applicationContext)
                )
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MapScreen(onBack: () -> Unit, repository: YouTubeRepository) {
    var videos by remember { mutableStateOf<List<Video>>(emptyList()) }
    var selectedVideo by remember { mutableStateOf<Video?>(null) }
    val context = LocalContext.current

    LaunchedEffect(Unit) {
        videos = repository.getVideosWithLocation()
    }

    val mapView = remember {
        MapView(context).apply {
            setTileSource(TileSourceFactory.MAPNIK)
            setMultiTouchControls(true)
            controller.setZoom(2.0)
        }
    }

    DisposableEffect(Unit) {
        mapView.onResume()
        onDispose {
            mapView.onPause()
        }
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("Map View") },
                navigationIcon = {
                    IconButton(onClick = onBack) {
                        Icon(Icons.Filled.ArrowBack, contentDescription = "Back")
                    }
                }
            )
        }
    ) { paddingValues ->
        Box(modifier = Modifier.fillMaxSize().padding(paddingValues)) {
            AndroidView(
                factory = { mapView },
                update = { view ->
                    view.overlays.clear()
                    if (videos.isNotEmpty()) {
                        var minLat = Double.MAX_VALUE
                        var minLon = Double.MAX_VALUE
                        var maxLat = -Double.MAX_VALUE
                        var maxLon = -Double.MAX_VALUE

                        videos.forEach { video ->
                            val lat = video.locationLatitude
                            val lon = video.locationLongitude
                            if (lat != null && lon != null) {
                                minLat = minOf(minLat, lat)
                                minLon = minOf(minLon, lon)
                                maxLat = maxOf(maxLat, lat)
                                maxLon = maxOf(maxLon, lon)

                                val marker = Marker(view)
                                marker.position = GeoPoint(lat, lon)
                                marker.title = video.title
                                marker.setOnMarkerClickListener { _, _ ->
                                    selectedVideo = video
                                    true
                                }
                                view.overlays.add(marker)
                            }
                        }

                        if (minLat != Double.MAX_VALUE) {
                            val padLat = if (maxLat == minLat) 0.1 else (maxLat - minLat) * 0.1
                            val padLon = if (maxLon == minLon) 0.1 else (maxLon - minLon) * 0.1
                            val expandedBoundingBox = BoundingBox(
                                maxLat + padLat,
                                maxLon + padLon,
                                minLat - padLat,
                                minLon - padLon
                            )
                            view.post {
                                view.zoomToBoundingBox(expandedBoundingBox, true)
                            }
                        }
                    }
                    view.invalidate()
                },
                modifier = Modifier.fillMaxSize()
            )
        }

        if (selectedVideo != null) {
            ModalBottomSheet(
                onDismissRequest = { selectedVideo = null }
            ) {
                Column(modifier = Modifier.padding(16.dp)) {
                    VideoItem(video = selectedVideo!!, onClick = {
                        dev.elainedb.ytdash_android_gemini.utils.YouTubeUtils.openYouTubeVideo(context, selectedVideo!!.id)
                    })
                    Spacer(modifier = Modifier.height(32.dp))
                }
            }
        }
    }
}
