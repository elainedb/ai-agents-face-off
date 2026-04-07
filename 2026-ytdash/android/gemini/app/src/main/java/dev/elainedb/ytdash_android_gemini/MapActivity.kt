package dev.elainedb.ytdash_android_gemini

import android.content.Context
import android.content.Intent
import android.os.Bundle
import androidx.appcompat.app.AppCompatActivity
import androidx.compose.ui.platform.ComposeView
import androidx.lifecycle.lifecycleScope
import androidx.lifecycle.setViewTreeLifecycleOwner
import androidx.lifecycle.setViewTreeViewModelStoreOwner
import androidx.savedstate.setViewTreeSavedStateRegistryOwner
import com.google.android.material.bottomsheet.BottomSheetDialog
import dagger.hilt.android.AndroidEntryPoint
import dev.elainedb.ytdash_android_gemini.database.VideoDao
import dev.elainedb.ytdash_android_gemini.database.toVideo
import dev.elainedb.ytdash_android_gemini.ui.VideoItem
import dev.elainedb.ytdash_android_gemini.ui.theme.YTDashAGeminiTheme
import kotlinx.coroutines.launch
import org.osmdroid.config.Configuration
import org.osmdroid.util.BoundingBox
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker
import javax.inject.Inject

@AndroidEntryPoint
class MapActivity : AppCompatActivity() {

    @Inject
    lateinit var videoDao: VideoDao

    private lateinit var mapView: MapView

    companion object {
        fun newIntent(context: Context): Intent {
            return Intent(context, MapActivity::class.java)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // OSMDroid configuration
        Configuration.getInstance().userAgentValue = "dev.elainedb.ytdash_android_gemini/1.0"
        
        setContentView(R.layout.activity_map)
        
        mapView = findViewById(R.id.mapView)
        mapView.setMultiTouchControls(true)

        lifecycleScope.launch {
            val videos = videoDao.getVideosWithLocation()
            val points = mutableListOf<GeoPoint>()

            videos.forEach { videoEntity ->
                val lat = videoEntity.locationLatitude
                val lon = videoEntity.locationLongitude
                if (lat != null && lon != null) {
                    val point = GeoPoint(lat, lon)
                    points.add(point)
                    
                    val marker = Marker(mapView)
                    marker.position = point
                    marker.title = videoEntity.title
                    marker.setAnchor(Marker.ANCHOR_CENTER, Marker.ANCHOR_BOTTOM)
                    marker.setOnMarkerClickListener { _, _ ->
                        showBottomSheet(videoEntity.toVideo())
                        true
                    }
                    mapView.overlays.add(marker)
                }
            }

            if (points.isNotEmpty()) {
                mapView.post {
                    val boundingBox = BoundingBox.fromGeoPoints(points)
                    mapView.zoomToBoundingBox(boundingBox, true, 100)
                }
            }
        }
    }

    private fun showBottomSheet(video: dev.elainedb.ytdash_android_gemini.model.Video) {
        val bottomSheetDialog = BottomSheetDialog(this)
        val composeView = ComposeView(this).apply {
            setContent {
                YTDashAGeminiTheme {
                    VideoItem(video = video)
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

    override fun onResume() {
        super.onResume()
        mapView.onResume()
    }

    override fun onPause() {
        super.onPause()
        mapView.onPause()
    }
}
