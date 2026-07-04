package com.example.ytdash.ui.home

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items

import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp
import com.example.ytdash.TestConfig
import com.example.ytdash.domain.models.Video

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    viewModel: HomeViewModel,
    testConfig: TestConfig,
    onNavigateToMap: () -> Unit,
    onLogout: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    var showMenu by remember { mutableStateOf(false) }
    var externalError by remember { mutableStateOf<String?>(null) }
    var externalUrl by remember { mutableStateOf<String?>(null) }
    val context = LocalContext.current

    var showFilter by remember { mutableStateOf(false) }
    var showSort by remember { mutableStateOf(false) }

    Scaffold(
        modifier = Modifier.testTag("screen_home"),
        topBar = {
            TopAppBar(
                title = { 
                    val count = if (uiState is HomeUiState.Content) (uiState as HomeUiState.Content).videos.size else 0
                    Text("ytdash - Videos: $count", modifier = Modifier.testTag("video_count")) 
                },
                actions = {
                    IconButton(onClick = onNavigateToMap, modifier = Modifier.testTag("map_nav_button")) {
                        Text("Map")
                    }
                    IconButton(onClick = { viewModel.loadVideos() }, modifier = Modifier.testTag("refresh_control")) {
                        Text("Refresh")
                    }
                    IconButton(onClick = { showFilter = true }, modifier = Modifier.testTag("filter_button")) {
                        Text("Filter")
                    }
                    IconButton(onClick = { showSort = true }, modifier = Modifier.testTag("sort_button")) {
                        Text("Sort")
                    }
                    IconButton(onClick = onLogout, modifier = Modifier.testTag("logout_button")) {
                        Text("Logout")
                    }
                }
            )
        }
    ) { padding ->
        Box(modifier = Modifier.padding(padding).fillMaxSize()) {
            val currentState = uiState
            when (currentState) {
                is HomeUiState.Loading -> {
                    CircularProgressIndicator(modifier = Modifier.align(Alignment.Center).testTag("loading_indicator"))
                }
                is HomeUiState.Error -> {
                    Column(
                        modifier = Modifier.align(Alignment.Center).testTag("error_view"),
                        horizontalAlignment = Alignment.CenterHorizontally
                    ) {
                        Text(currentState.message)
                        Button(onClick = { viewModel.loadVideos() }, modifier = Modifier.testTag("error_retry_button")) {
                            Text("Retry")
                        }
                    }
                }
                is HomeUiState.Content -> {
                    if (showFilter) {
                        FilterPanel(
                            categories = viewModel.allCategories,
                            onApply = { category ->
                                viewModel.applyFilter(category)
                                showFilter = false
                            }
                        )
                    } else if (showSort) {
                        SortPanel(
                            onApply = { descending ->
                                viewModel.applySort(descending)
                                showSort = false
                            }
                        )
                    } else {
                        LazyColumn(modifier = Modifier.fillMaxSize().testTag("video_list")) {
                            items(currentState.videos) { video ->
                                VideoItemRow(
                                    video = video,
                                    onClick = {
                                        if (testConfig.captureExternalLinks) {
                                            externalUrl = video.youtubeUrl
                                        } else {
                                            try {
                                                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(video.youtubeUrl))
                                                context.startActivity(intent)
                                            } catch (e: Exception) {
                                                externalError = "Failed to open YouTube"
                                            }
                                        }
                                    }
                                )
                            }
                        }
                    }
                }
            }
            
            // External link capture banner
            if (externalUrl != null) {
                Surface(color = MaterialTheme.colorScheme.primaryContainer, modifier = Modifier.align(Alignment.BottomCenter).fillMaxWidth()) {
                    Text(externalUrl!!, modifier = Modifier.testTag("external_open_url").padding(16.dp))
                }
            }
            
            // External link error banner
            if (externalError != null) {
                Surface(color = MaterialTheme.colorScheme.errorContainer, modifier = Modifier.align(Alignment.BottomCenter).fillMaxWidth()) {
                    Text(externalError!!, modifier = Modifier.testTag("external_open_error").padding(16.dp))
                }
            }
        }
    }
}

@Composable
fun FilterPanel(categories: List<String>, onApply: (String?) -> Unit) {
    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Text("Filter by Category", style = MaterialTheme.typography.titleLarge)
        Spacer(modifier = Modifier.height(16.dp))
        
        categories.forEach { cat ->
            Button(onClick = { onApply(cat) }, modifier = Modifier.fillMaxWidth()) {
                Text(cat)
            }
        }
        
        Button(onClick = { onApply(null) }, modifier = Modifier.fillMaxWidth()) {
            Text("Clear Filter")
        }
    }
}

@Composable
fun SortPanel(onApply: (Boolean) -> Unit) {
    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Text("Sort by Date", style = MaterialTheme.typography.titleLarge)
        Spacer(modifier = Modifier.height(16.dp))
        Button(onClick = { onApply(true) }, modifier = Modifier.fillMaxWidth()) {
            Text("Date - newest")
        }
        Button(onClick = { onApply(false) }, modifier = Modifier.fillMaxWidth()) {
            Text("Date - oldest")
        }
    }
}

@Composable
fun VideoItemRow(video: Video, onClick: () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth().padding(8.dp).clickable { onClick() }
            .semantics(mergeDescendants = true) {
                contentDescription = "${video.title} ${video.description} ${video.publishedAt}"
            }
            .testTag("video_list_item")
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            Text(video.title, style = MaterialTheme.typography.titleMedium, modifier = Modifier.testTag("video_list_item_title"))
            Text(video.description, style = MaterialTheme.typography.bodyMedium)
            Text(video.publishedAt, style = MaterialTheme.typography.bodySmall)
            Text("Category: \${video.category}", style = MaterialTheme.typography.bodySmall)
        }
    }
}
