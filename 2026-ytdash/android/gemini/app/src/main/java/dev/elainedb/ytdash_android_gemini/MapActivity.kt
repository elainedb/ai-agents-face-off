package dev.elainedb.ytdash_android_gemini

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.widget.FrameLayout
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.setViewTreeLifecycleOwner
import androidx.lifecycle.setViewTreeViewModelStoreOwner
import androidx.savedstate.setViewTreeSavedStateRegistryOwner
import com.google.android.material.bottomsheet.BottomSheetDialog
import dagger.hilt.android.AndroidEntryPoint
import dev.elainedb.ytdash_android_gemini.domain.model.Video
import dev.elainedb.ytdash_android_gemini.domain.repository.YouTubeRepository
import kotlinx.coroutines.launch
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.BoundingBox
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker
import javax.inject.Inject
import androidx.compose.ui.platform.ComposeView
import androidx.compose.foundation.layout.*
import androidx.compose.material3.*
import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage

@AndroidEntryPoint
class MapActivity : AppCompatActivity() {

    @Inject
    lateinit var repository: YouTubeRepository

    private lateinit var map: MapView

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        Configuration.getInstance().userAgentValue = "dev.elainedb.ytdash_android_gemini/1.0"
        
        map = MapView(this)
        map.setTileSource(TileSourceFactory.MAPNIK)
        map.setMultiTouchControls(true)
        
        setContentView(map)

        lifecycleScope.launch {
            val videos = repository.getVideosWithLocation()
            if (videos.isNotEmpty()) {
                val points = mutableListOf<GeoPoint>()
                for (video in videos) {
                    val lat = video.locationLatitude ?: continue
                    val lng = video.locationLongitude ?: continue
                    val point = GeoPoint(lat, lng)
                    points.add(point)
                    
                    val marker = Marker(map)
                    marker.position = point
                    marker.title = video.title
                    marker.setOnMarkerClickListener { _, _ ->
                        showBottomSheet(video)
                        true
                    }
                    map.overlays.add(marker)
                }
                
                if (points.isNotEmpty()) {
                    val boundingBox = BoundingBox.fromGeoPoints(points)
                    map.post {
                        map.zoomToBoundingBox(boundingBox, true, 100)
                    }
                }
            }
        }
    }

    override fun onResume() {
        super.onResume()
        map.onResume()
    }

    override fun onPause() {
        super.onPause()
        map.onPause()
    }
    
    private fun showBottomSheet(video: Video) {
        val bottomSheetDialog = BottomSheetDialog(this)
        val composeView = ComposeView(this).apply {
            setContent {
                MaterialTheme {
                    Surface(
                        modifier = Modifier.fillMaxWidth(),
                        color = MaterialTheme.colorScheme.surface
                    ) {
                        Column(modifier = Modifier.padding(16.dp)) {
                            AsyncImage(
                                model = video.thumbnailUrl,
                                contentDescription = "Thumbnail",
                                modifier = Modifier.fillMaxWidth().height(150.dp)
                            )
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(video.title, style = MaterialTheme.typography.titleMedium)
                            Text(video.channelName, style = MaterialTheme.typography.bodyMedium)
                            Text("Published: ${video.publishedAt.take(10)}", style = MaterialTheme.typography.bodySmall)
                            
                            if (video.recordingDate != null) {
                                Text("Recorded: ${video.recordingDate.take(10)}", style = MaterialTheme.typography.bodySmall)
                            }
                            if (video.locationCity != null || video.locationCountry != null) {
                                val loc = listOfNotNull(video.locationCity, video.locationCountry).joinToString(", ")
                                Text("Location: $loc", style = MaterialTheme.typography.bodySmall)
                            }
                            if (video.tags.isNotEmpty()) {
                                Text("Tags: ${video.tags.take(3).joinToString()}", style = MaterialTheme.typography.bodySmall, maxLines = 1)
                            }
                            Spacer(modifier = Modifier.height(16.dp))
                            Button(
                                onClick = {
                                    val intentApp = Intent(Intent.ACTION_VIEW, Uri.parse("vnd.youtube:" + video.id))
                                    val intentBrowser = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=" + video.id))
                                    try {
                                        startActivity(intentApp)
                                    } catch (e: Exception) {
                                        startActivity(intentBrowser)
                                    }
                                    bottomSheetDialog.dismiss()
                                },
                                modifier = Modifier.fillMaxWidth()
                            ) {
                                Text("Open in YouTube")
                            }
                        }
                    }
                }
            }
        }
        bottomSheetDialog.setContentView(composeView)
        bottomSheetDialog.window?.decorView?.let { decorView ->
            decorView.setViewTreeLifecycleOwner(this@MapActivity)
            decorView.setViewTreeViewModelStoreOwner(this@MapActivity)
            decorView.setViewTreeSavedStateRegistryOwner(this@MapActivity)
        }
        bottomSheetDialog.show()
    }
}
