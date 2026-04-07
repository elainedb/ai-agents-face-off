package dev.elainedb.ytdash_android_gemini.ui

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.os.Bundle
import android.view.View
import android.widget.TextView
import androidx.appcompat.app.AppCompatActivity
import androidx.lifecycle.lifecycleScope
import com.google.android.material.bottomsheet.BottomSheetBehavior
import dagger.hilt.android.AndroidEntryPoint
import dev.elainedb.ytdash_android_gemini.R
import dev.elainedb.ytdash_android_gemini.data.database.VideoDao
import dev.elainedb.ytdash_android_gemini.domain.model.Video
import dev.elainedb.ytdash_android_gemini.data.database.toVideo
import kotlinx.coroutines.flow.first
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

    private lateinit var map: MapView
    private lateinit var bottomSheetBehavior: BottomSheetBehavior<View>
    private lateinit var bsTitle: TextView
    private lateinit var bsChannel: TextView
    private lateinit var bsDate: TextView
    private lateinit var bsLocation: TextView
    private var currentVideoId: String? = null

    companion object {
        fun newIntent(context: Context): Intent {
            return Intent(context, MapActivity::class.java)
        }
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        Configuration.getInstance().userAgentValue = "dev.elainedb.ytdash_android_gemini/1.0"
        
        val layout = android.widget.FrameLayout(this).apply {
            id = View.generateViewId()
        }
        setContentView(layout)

        map = MapView(this)
        map.setMultiTouchControls(true)
        layout.addView(map)

        val bottomSheet = android.widget.LinearLayout(this).apply {
            orientation = android.widget.LinearLayout.VERTICAL
            setBackgroundColor(android.graphics.Color.WHITE)
            setPadding(32, 32, 32, 32)
            elevation = 16f
            layoutParams = androidx.coordinatorlayout.widget.CoordinatorLayout.LayoutParams(
                androidx.coordinatorlayout.widget.CoordinatorLayout.LayoutParams.MATCH_PARENT,
                resources.displayMetrics.heightPixels / 4
            ).apply {
                behavior = BottomSheetBehavior<android.widget.LinearLayout>()
            }
        }
        
        bsTitle = TextView(this).apply { textSize = 18f; setTypeface(null, android.graphics.Typeface.BOLD) }
        bsChannel = TextView(this)
        bsDate = TextView(this)
        bsLocation = TextView(this)
        
        bottomSheet.addView(bsTitle)
        bottomSheet.addView(bsChannel)
        bottomSheet.addView(bsDate)
        bottomSheet.addView(bsLocation)

        val coordinatorLayout = androidx.coordinatorlayout.widget.CoordinatorLayout(this)
        coordinatorLayout.addView(bottomSheet)
        layout.addView(coordinatorLayout)

        bottomSheetBehavior = BottomSheetBehavior.from(bottomSheet)
        bottomSheetBehavior.state = BottomSheetBehavior.STATE_HIDDEN
        
        bottomSheet.setOnClickListener {
            currentVideoId?.let { vid ->
                val appIntent = Intent(Intent.ACTION_VIEW, Uri.parse("vnd.youtube:$vid"))
                val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=$vid"))
                try {
                    startActivity(appIntent)
                } catch (ex: Exception) {
                    startActivity(webIntent)
                }
            }
        }

        lifecycleScope.launch {
            val videosEntities = videoDao.getVideosWithLocation().first()
            val videos = videosEntities.map { it.toVideo() }
            val geoPoints = mutableListOf<GeoPoint>()

            videos.forEach { video ->
                if (video.locationLatitude != null && video.locationLongitude != null) {
                    val point = GeoPoint(video.locationLatitude, video.locationLongitude)
                    geoPoints.add(point)
                    
                    val marker = Marker(map)
                    marker.position = point
                    marker.title = video.title
                    marker.setOnMarkerClickListener { _, _ ->
                        showBottomSheet(video)
                        true
                    }
                    map.overlays.add(marker)
                }
            }
            
            if (geoPoints.isNotEmpty()) {
                val boundingBox = BoundingBox.fromGeoPoints(geoPoints)
                map.post {
                    map.zoomToBoundingBox(boundingBox, true, 100)
                }
            }
        }
    }

    private fun showBottomSheet(video: Video) {
        currentVideoId = video.id
        bsTitle.text = video.title
        bsChannel.text = video.channelName
        bsDate.text = "Published: ${video.publishedAt.take(10)}"
        bsLocation.text = "Location: ${video.locationCity ?: ""} ${video.locationCountry ?: ""}"
        bottomSheetBehavior.state = BottomSheetBehavior.STATE_EXPANDED
    }

    override fun onResume() {
        super.onResume()
        map.onResume()
    }

    override fun onPause() {
        super.onPause()
        map.onPause()
    }
}
