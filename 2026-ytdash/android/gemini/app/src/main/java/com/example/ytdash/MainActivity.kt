package com.example.ytdash

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.background
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.testTagsAsResourceId
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.ViewModelProvider
import com.example.ytdash.data.model.TestConfig
import com.example.ytdash.theme.YtdashTheme
import com.example.ytdash.ui.view.HomeScreen
import com.example.ytdash.ui.view.LoginScreen
import com.example.ytdash.ui.viewmodel.MainViewModel
import com.example.ytdash.ui.viewmodel.MainViewModelFactory
import com.example.ytdash.ui.viewmodel.Screen

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)

        // Parse test configuration from intent extras
        val testConfig = TestConfig.fromIntent(intent)
        val app = application as MainApplication
        app.initializeDependencies(testConfig)

        // Instantiate ViewModel with manual Dependency Injection
        val viewModel: MainViewModel = ViewModelProvider(
            this,
            MainViewModelFactory(app.authRepository, app.videoRepository, app.testConfig)
        )[MainViewModel::class.java]

        enableEdgeToEdge()
        setContent {
            YtdashTheme {
                Surface(
                    modifier = Modifier
                        .fillMaxSize()
                        .semantics { testTagsAsResourceId = true },
                    color = MaterialTheme.colorScheme.background
                ) {
                    AppContent(viewModel)
                }
            }
        }
    }
}

@Composable
fun AppContent(viewModel: MainViewModel) {
    val currentScreen by viewModel.currentScreen.collectAsState()
    val capturedUrl by viewModel.capturedExternalUrl.collectAsState()
    val externalOpenError by viewModel.externalOpenError.collectAsState()

    Box(modifier = Modifier.fillMaxSize()) {
        // Render current screen
        when (currentScreen) {
            Screen.LOGIN -> LoginScreen(viewModel = viewModel)
            Screen.HOME -> HomeScreen(viewModel = viewModel)
        }

        // Overlay for captured external links (when captureExternalLinks is true)
        capturedUrl?.let { url ->
            Card(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .fillMaxWidth()
                    .padding(16.dp)
                    .padding(bottom = 80.dp),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFF1E1E24)),
                elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Captured Link Launch",
                            color = Color.Gray,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        // Must carry the exact watch URL as text and have the external_open_url testTag
                        Text(
                            text = url,
                            color = Color(0xFFFF4D4D),
                            fontSize = 14.sp,
                            fontWeight = FontWeight.SemiBold,
                            modifier = Modifier.testTag("external_open_url")
                        )
                    }
                    IconButton(
                        onClick = { viewModel.clearCapturedUrl() }
                    ) {
                        Text("✕", color = Color.Gray, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }

        // Overlay for failed external link launches (when captureExternalLinks is false and launch fails)
        externalOpenError?.let { err ->
            Card(
                modifier = Modifier
                    .align(Alignment.BottomCenter)
                    .fillMaxWidth()
                    .padding(16.dp)
                    .padding(bottom = 80.dp),
                shape = RoundedCornerShape(12.dp),
                colors = CardDefaults.cardColors(containerColor = Color(0xFFFF0000).copy(alpha = 0.9f)),
                elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    horizontalArrangement = Arrangement.SpaceBetween,
                    verticalAlignment = Alignment.CenterVertically
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text(
                            text = "Error",
                            color = Color.White,
                            fontSize = 12.sp,
                            fontWeight = FontWeight.Bold
                        )
                        Spacer(modifier = Modifier.height(4.dp))
                        // Must carry the external_open_error testTag
                        Text(
                            text = err,
                            color = Color.White,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.SemiBold,
                            modifier = Modifier.testTag("external_open_error")
                        )
                    }
                    IconButton(
                        onClick = { viewModel.clearExternalOpenError() }
                    ) {
                        Text("✕", color = Color.White, fontSize = 16.sp, fontWeight = FontWeight.Bold)
                    }
                }
            }
        }
    }
}
