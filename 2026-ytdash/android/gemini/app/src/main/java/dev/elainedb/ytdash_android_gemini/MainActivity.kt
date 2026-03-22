package dev.elainedb.ytdash_android_gemini

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.activity.viewModels
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInClient
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import dev.elainedb.ytdash_android_gemini.data.repository.YouTubeRepository
import dev.elainedb.ytdash_android_gemini.ui.screen.VideoListScreen
import dev.elainedb.ytdash_android_gemini.ui.theme.YTDashAGeminiTheme
import dev.elainedb.ytdash_android_gemini.ui.viewmodel.VideoListViewModel

class MainActivity : ComponentActivity() {
    
    private lateinit var googleSignInClient: GoogleSignInClient
    private lateinit var repository: YouTubeRepository
    
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        
        ConfigHelper.init(this)
        
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN)
            .requestEmail()
            .build()
        googleSignInClient = GoogleSignIn.getClient(this, gso)
        
        repository = YouTubeRepository(this)
        
        val viewModel: VideoListViewModel by viewModels {
            VideoListViewModel.Factory(repository)
        }
        
        setContent {
            YTDashAGeminiTheme {
                VideoListScreen(
                    viewModel = viewModel,
                    onLogoutClick = {
                        logout()
                    }
                )
            }
        }
    }
    
    private fun logout() {
        googleSignInClient.signOut().addOnCompleteListener(this) {
            val intent = Intent(this, LoginActivity::class.java)
            intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            startActivity(intent)
            finish()
        }
    }
}
