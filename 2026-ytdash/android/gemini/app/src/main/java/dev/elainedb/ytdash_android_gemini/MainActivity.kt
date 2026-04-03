package dev.elainedb.ytdash_android_gemini

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.viewModels
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import dev.elainedb.ytdash_android_gemini.database.VideoDatabase
import dev.elainedb.ytdash_android_gemini.network.RetrofitClient
import dev.elainedb.ytdash_android_gemini.repository.YouTubeRepository
import dev.elainedb.ytdash_android_gemini.ui.VideoListScreen
import dev.elainedb.ytdash_android_gemini.ui.theme.YTDashAGeminiTheme
import dev.elainedb.ytdash_android_gemini.viewmodel.VideoListViewModel
import dev.elainedb.ytdash_android_gemini.viewmodel.VideoListViewModelFactory

class MainActivity : ComponentActivity() {

    private val viewModel: VideoListViewModel by viewModels {
        val database = VideoDatabase.getDatabase(applicationContext)
        val repository = YouTubeRepository(
            apiService = RetrofitClient.apiService,
            videoDao = database.videoDao(),
            context = applicationContext
        )
        VideoListViewModelFactory(repository)
    }

    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        
        // Ensure user is signed in
        val account = GoogleSignIn.getLastSignedInAccount(this)
        if (account == null) {
            navigateToLogin()
            return
        }

        setContent {
            YTDashAGeminiTheme {
                Surface(
                    modifier = Modifier.fillMaxSize(),
                    color = MaterialTheme.colorScheme.background
                ) {
                    VideoListScreen(
                        viewModel = viewModel,
                        onLogoutClick = { logout() },
                        onViewMapClick = {
                            val intent = Intent(this, MapActivity::class.java)
                            startActivity(intent)
                        }
                    )
                }
            }
        }
    }

    private fun logout() {
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .build()
        val googleSignInClient = GoogleSignIn.getClient(this, gso)
        googleSignInClient.signOut().addOnCompleteListener(this) {
            navigateToLogin()
        }
    }

    private fun navigateToLogin() {
        val intent = Intent(this, LoginActivity::class.java)
        intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
        startActivity(intent)
        finish()
    }
}
