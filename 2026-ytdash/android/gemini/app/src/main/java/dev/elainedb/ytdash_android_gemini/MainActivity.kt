package dev.elainedb.ytdash_android_gemini

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import dev.elainedb.ytdash_android_gemini.repository.YouTubeRepository
import dev.elainedb.ytdash_android_gemini.ui.screens.VideoListScreen
import dev.elainedb.ytdash_android_gemini.ui.theme.YTDashAGeminiTheme
import dev.elainedb.ytdash_android_gemini.viewmodel.VideoListViewModel
import dev.elainedb.ytdash_android_gemini.viewmodel.VideoListViewModelFactory

class MainActivity : ComponentActivity() {

    private val viewModel: VideoListViewModel by viewModels {
        VideoListViewModelFactory(YouTubeRepository(applicationContext))
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            YTDashAGeminiTheme {
                VideoListScreen(
                    viewModel = viewModel,
                    onLogoutClick = { logout() },
                    onMapClick = { openMap() }
                )
            }
        }
    }

    private fun logout() {
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .build()
        GoogleSignIn.getClient(this, gso).signOut().addOnCompleteListener {
            startActivity(Intent(this, LoginActivity::class.java))
            finish()
        }
    }

    private fun openMap() {
        startActivity(Intent(this, MapActivity::class.java))
    }
}