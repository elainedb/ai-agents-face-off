package dev.elainedb.ytdash_android_gemini

import android.content.Intent
import android.net.Uri
import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.hilt.navigation.compose.hiltViewModel
import coil.compose.AsyncImage
import com.google.android.gms.auth.api.signin.GoogleSignIn
import com.google.android.gms.auth.api.signin.GoogleSignInOptions
import dagger.hilt.android.AndroidEntryPoint
import dev.elainedb.ytdash_android_gemini.domain.model.Video
import dev.elainedb.ytdash_android_gemini.presentation.main.VideoListUiState
import dev.elainedb.ytdash_android_gemini.presentation.main.VideoListViewModel
import dev.elainedb.ytdash_android_gemini.ui.theme.YTDashAGeminiTheme

@AndroidEntryPoint
class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        setContent {
            YTDashAGeminiTheme {
                Surface(modifier = Modifier.fillMaxSize(), color = MaterialTheme.colorScheme.background) {
                    MainScreen(
                        onLogout = { logout() },
                        onViewMap = {
                            startActivity(Intent(this, MapActivity::class.java))
                        },
                        onVideoClick = { video ->
                            val intentApp = Intent(Intent.ACTION_VIEW, Uri.parse("vnd.youtube:" + video.id))
                            val intentBrowser = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=" + video.id))
                            try {
                                startActivity(intentApp)
                            } catch (e: Exception) {
                                startActivity(intentBrowser)
                            }
                        }
                    )
                }
            }
        }
    }

    private fun logout() {
        val gso = GoogleSignInOptions.Builder(GoogleSignInOptions.DEFAULT_SIGN_IN).build()
        GoogleSignIn.getClient(this, gso).signOut().addOnCompleteListener {
            startActivity(Intent(this, LoginActivity::class.java).apply {
                flags = Intent.FLAG_ACTIVITY_NEW_TASK or Intent.FLAG_ACTIVITY_CLEAR_TASK
            })
            finish()
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(
    onLogout: () -> Unit,
    onViewMap: () -> Unit,
    onVideoClick: (Video) -> Unit,
    viewModel: VideoListViewModel = hiltViewModel()
) {
    val uiState by viewModel.uiState.collectAsState()
    val totalCount by viewModel.totalVideoCount.collectAsState()
    
    var showFilterDialog by remember { mutableStateOf(false) }
    var showSortDialog by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("YT Dashboard") },
                actions = {
                    IconButton(onClick = onLogout) {
                        Text("Logout")
                    }
                }
            )
        }
    ) { padding ->
        Column(modifier = Modifier.padding(padding)) {
            Row(modifier = Modifier.fillMaxWidth().padding(8.dp), horizontalArrangement = Arrangement.SpaceEvenly) {
                Button(onClick = { viewModel.fetchVideos(true) }) { Text("Refresh") }
                Button(onClick = onViewMap) { Text("View Map") }
                Button(onClick = { showFilterDialog = true }) { Text("Filter") }
                Button(onClick = { showSortDialog = true }) { Text("Sort") }
            }

            if (uiState is VideoListUiState.Success) {
                val videos = (uiState as VideoListUiState.Success).videos
                Text(
                    text = "Showing ${videos.size} of $totalCount videos",
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                    style = MaterialTheme.typography.bodyMedium
                )
            }

            Box(modifier = Modifier.fillMaxSize()) {
                when (val state = uiState) {
                    is VideoListUiState.Loading -> CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
                    is VideoListUiState.Empty -> Text("No videos found.", modifier = Modifier.align(Alignment.Center))
                    is VideoListUiState.Error -> Text("Error: ${state.message}", modifier = Modifier.align(Alignment.Center))
                    is VideoListUiState.Success -> {
                        LazyColumn(modifier = Modifier.fillMaxSize()) {
                            items(state.videos) { video ->
                                VideoItem(video = video, onClick = { onVideoClick(video) })
                            }
                        }
                    }
                }
            }
        }

        if (showFilterDialog) {
            val countries by viewModel.availableCountries.collectAsState()
            val channels by viewModel.availableChannels.collectAsState()
            
            FilterDialog(
                countries = countries,
                channels = channels,
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
                onApply = { sort ->
                    viewModel.applySorting(sort)
                    showSortDialog = false
                }
            )
        }
    }
}

@Composable
fun VideoItem(video: Video, onClick: () -> Unit) {
    Card(modifier = Modifier.fillMaxWidth().padding(8.dp).clickable { onClick() }) {
        Column {
            AsyncImage(
                model = video.thumbnailUrl,
                contentDescription = "Thumbnail",
                modifier = Modifier.fillMaxWidth().height(200.dp)
            )
            Column(modifier = Modifier.padding(16.dp)) {
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
            }
        }
    }
}
