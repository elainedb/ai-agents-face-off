package dev.elainedb.ytdash_android_gemini

import android.content.ActivityNotFoundException
import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.preference.PreferenceManager
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.viewinterop.AndroidView
import coil.compose.AsyncImage
import dev.elainedb.ytdash_android_gemini.database.VideoDatabase
import dev.elainedb.ytdash_android_gemini.database.VideoEntity
import dev.elainedb.ytdash_android_gemini.ui.theme.YTDashAGeminiTheme
import org.osmdroid.config.Configuration
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

        val prefs = PreferenceManager.getDefaultSharedPreferences(this)
        Configuration.getInstance().load(this, prefs)

        val videoDao = VideoDatabase.getDatabase(this).videoDao()

        setContent {
            YTDashAGeminiTheme {
                var videos by remember { mutableStateOf<List<VideoEntity>>(emptyList()) }
                var selectedVideo by remember { mutableStateOf<VideoEntity?>(null) }
                val sheetState = rememberModalBottomSheetState(skipPartiallyExpanded = false)
                val context = LocalContext.current

                LaunchedEffect(Unit) {
                    videos = videoDao.getVideosWithLocation()
                }

                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    Box(modifier = Modifier.fillMaxSize()) {
                        AndroidView(
                            factory = { ctx ->
                                MapView(ctx).apply {
                                    setMultiTouchControls(true)
                                }
                            },
                            modifier = Modifier.fillMaxSize(),
                            update = { mapView ->
                                mapView.onResume()
                                mapView.overlays.clear()
                                if (videos.isNotEmpty()) {
                                    val points = mutableListOf<GeoPoint>()
                                    videos.forEach { video ->
                                        val lat = video.locationLatitude
                                        val lon = video.locationLongitude
                                        if (lat != null && lon != null) {
                                            val point = GeoPoint(lat, lon)
                                            points.add(point)
                                            val marker = Marker(mapView)
                                            marker.position = point
                                            marker.setAnchor(Marker.ANCHOR_CENTER, Marker.ANCHOR_BOTTOM)
                                            marker.title = video.title
                                            marker.setOnMarkerClickListener { _, _ ->
                                                selectedVideo = video
                                                true
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
                                }
                                mapView.invalidate()
                            }
                        )

                        if (selectedVideo != null) {
                            ModalBottomSheet(
                                onDismissRequest = { selectedVideo = null },
                                sheetState = sheetState
                            ) {
                                val video = selectedVideo!!
                                Column(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .clickable {
                                            val intentApp = Intent(Intent.ACTION_VIEW, Uri.parse("vnd.youtube:${video.id}"))
                                            val intentBrowser = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=${video.id}"))
                                            try {
                                                context.startActivity(intentApp)
                                            } catch (e: ActivityNotFoundException) {
                                                context.startActivity(intentBrowser)
                                            }
                                        }
                                        .padding(16.dp)
                                ) {
                                    AsyncImage(
                                        model = video.thumbnailUrl,
                                        contentDescription = "Video Thumbnail",
                                        modifier = Modifier
                                            .fillMaxWidth()
                                            .aspectRatio(16f / 9f),
                                        contentScale = ContentScale.Crop
                                    )
                                    Spacer(modifier = Modifier.height(8.dp))
                                    Text(
                                        text = video.title,
                                        style = MaterialTheme.typography.titleMedium,
                                        maxLines = 2,
                                        overflow = TextOverflow.Ellipsis
                                    )
                                    Spacer(modifier = Modifier.height(8.dp))
                                    Row(
                                        modifier = Modifier.fillMaxWidth(),
                                        horizontalArrangement = Arrangement.SpaceBetween
                                    ) {
                                        Text(
                                            text = video.channelName,
                                            style = MaterialTheme.typography.bodyMedium,
                                            color = MaterialTheme.colorScheme.onSurfaceVariant
                                        )
                                        Text(
                                            text = video.publishedAt,
                                            style = MaterialTheme.typography.bodySmall,
                                            color = MaterialTheme.colorScheme.onSurfaceVariant
                                        )
                                    }
                                    Spacer(modifier = Modifier.height(8.dp))
                                    LazyRow(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                                        if (!video.locationCity.isNullOrEmpty() || !video.locationCountry.isNullOrEmpty()) {
                                            val location = listOfNotNull(video.locationCity?.takeIf { it.isNotBlank() }, video.locationCountry?.takeIf { it.isNotBlank() }).joinToString(", ")
                                            if (location.isNotEmpty()) {
                                                item {
                                                    SuggestionChip(onClick = {}, label = { Text(location) })
                                                }
                                            }
                                        }
                                        if (!video.recordingDate.isNullOrEmpty()) {
                                            item {
                                                SuggestionChip(onClick = {}, label = { Text("Rec: ${video.recordingDate}") })
                                            }
                                        }
                                        val tags = if (video.tags.isEmpty()) emptyList() else video.tags.split(",")
                                        items(tags) { tag ->
                                            if (tag.isNotBlank()) {
                                                SuggestionChip(onClick = {}, label = { Text(tag.trim()) })
                                            }
                                        }
                                    }
                                    Spacer(modifier = Modifier.height(32.dp))
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}
