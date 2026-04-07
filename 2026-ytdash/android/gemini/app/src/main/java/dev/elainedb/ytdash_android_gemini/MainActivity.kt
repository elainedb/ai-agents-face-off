package dev.elainedb.ytdash_android_gemini

import android.content.Intent
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.padding
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ExitToApp
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import androidx.hilt.navigation.compose.hiltViewModel
import dagger.hilt.android.AndroidEntryPoint
import dev.elainedb.ytdash_android_gemini.domain.usecase.SignOut
import dev.elainedb.ytdash_android_gemini.ui.LoginActivity
import dev.elainedb.ytdash_android_gemini.ui.MapActivity
import dev.elainedb.ytdash_android_gemini.ui.components.FilterDialog
import dev.elainedb.ytdash_android_gemini.ui.components.SortDialog
import dev.elainedb.ytdash_android_gemini.ui.components.VideoListScreen
import dev.elainedb.ytdash_android_gemini.ui.theme.YTDashAGeminiTheme
import dev.elainedb.ytdash_android_gemini.ui.viewmodel.VideoListViewModel
import kotlinx.coroutines.launch
import javax.inject.Inject

@AndroidEntryPoint
class MainActivity : ComponentActivity() {

    @Inject
    lateinit var signOutUseCase: SignOut

    @OptIn(ExperimentalMaterial3Api::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            YTDashAGeminiTheme {
                val viewModel: VideoListViewModel = hiltViewModel()
                val uiState by viewModel.uiState.collectAsState()
                val availableCountries by viewModel.availableCountries.collectAsState()
                val availableChannels by viewModel.availableChannels.collectAsState()
                
                var showFilterDialog by remember { mutableStateOf(false) }
                var showSortDialog by remember { mutableStateOf(false) }
                val coroutineScope = rememberCoroutineScope()

                Scaffold(
                    modifier = Modifier.fillMaxSize(),
                    topBar = {
                        TopAppBar(
                            title = { Text("YT Dashboard") },
                            actions = {
                                IconButton(onClick = {
                                    coroutineScope.launch {
                                        signOutUseCase(Unit)
                                        val intent = Intent(this@MainActivity, LoginActivity::class.java).apply {
                                            flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
                                        }
                                        startActivity(intent)
                                        finish()
                                    }
                                }) {
                                    Icon(Icons.Filled.ExitToApp, contentDescription = "Logout")
                                }
                            }
                        )
                    }
                ) { innerPadding ->
                    Box(modifier = Modifier.padding(innerPadding)) {
                        VideoListScreen(
                            uiState = uiState,
                            onRefresh = { viewModel.loadVideos(forceRefresh = true) },
                            onViewMap = {
                                startActivity(MapActivity.newIntent(this@MainActivity))
                            },
                            onFilterClick = { showFilterDialog = true },
                            onSortClick = { showSortDialog = true }
                        )

                        if (showFilterDialog) {
                            FilterDialog(
                                availableChannels = availableChannels,
                                availableCountries = availableCountries,
                                onDismiss = { showFilterDialog = false },
                                onApply = { channel, country ->
                                    viewModel.applyFilter(channel, country)
                                    showFilterDialog = false
                                }
                            )
                        }

                        if (showSortDialog) {
                            SortDialog(
                                onDismiss = { showSortDialog = false },
                                onApply = { sortOption ->
                                    viewModel.applySorting(sortOption)
                                    showSortDialog = false
                                }
                            )
                        }
                    }
                }
            }
        }
    }
}
