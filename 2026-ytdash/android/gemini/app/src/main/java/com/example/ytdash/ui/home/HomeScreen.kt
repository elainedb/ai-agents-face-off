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
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.contentDescription
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.testTagsAsResourceId
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import com.example.ytdash.data.model.VideoEntity

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    viewModel: HomeViewModel,
    onLogout: () -> Unit,
    onNavigateToMap: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    val context = LocalContext.current
    val config = viewModel.getConfig()
    
    var capturedUrl by remember { mutableStateOf<String?>(null) }
    var externalError by remember { mutableStateOf<String?>(null) }
    
    var showFilterMenu by remember { mutableStateOf(false) }
    var showSortMenu by remember { mutableStateOf(false) }
    var showOverflowMenu by remember { mutableStateOf(false) }

    val handleVideoClick = { videoId: String ->
        val url = "https://www.youtube.com/watch?v=$videoId"
        if (config.captureExternalLinks) {
            capturedUrl = url
        } else {
            val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
            try {
                context.startActivity(intent)
            } catch (e: Exception) {
                externalError = "Could not open video: ${e.message}"
            }
        }
    }

    Scaffold(
        modifier = Modifier
            .testTag("screen_home")
            .semantics { testTagsAsResourceId = true },
        topBar = {
            TopAppBar(
                title = { 
                    Text("YouTube Dash " + uiState.allVideos.size.toString(), 
                         modifier = Modifier.testTag("video_count"))
                },
                actions = {
                    IconButton(onClick = onNavigateToMap, modifier = Modifier.testTag("map_nav_button")) {
                        Text("Map")
                    }
                    IconButton(onClick = { viewModel.refresh() }, modifier = Modifier.testTag("refresh_control")) {
                        Text("Refresh")
                    }
                    IconButton(onClick = { showFilterMenu = true }, modifier = Modifier.testTag("filter_button")) {
                        Text("Filter")
                    }
                    DropdownMenu(
                        expanded = showFilterMenu,
                        onDismissRequest = { showFilterMenu = false },
                        modifier = Modifier.semantics { testTagsAsResourceId = true }
                    ) {
                        DropdownMenuItem(
                            text = { Text("All") },
                            onClick = { 
                                viewModel.setFilter(null)
                                showFilterMenu = false 
                            },
                            modifier = Modifier.testTag("filter_apply_button")
                        )
                        viewModel.getChannels().map { it.label }.distinct().forEach { category ->
                            DropdownMenuItem(
                                text = { Text(category) },
                                onClick = { 
                                    viewModel.setFilter(category)
                                    showFilterMenu = false 
                                },
                                modifier = Modifier.testTag("filter_apply_button")
                            )
                        }
                    }
                    
                    IconButton(onClick = { showSortMenu = true }, modifier = Modifier.testTag("sort_button")) {
                        Text("Sort")
                    }
                    DropdownMenu(
                        expanded = showSortMenu,
                        onDismissRequest = { showSortMenu = false },
                        modifier = Modifier.semantics { testTagsAsResourceId = true }
                    ) {
                        DropdownMenuItem(
                            text = { Text("Date Desc") },
                            onClick = { 
                                viewModel.setSortOrder(SortOrder.DESC)
                                showSortMenu = false 
                            },
                            modifier = Modifier.testTag("sort_apply_button")
                        )
                        DropdownMenuItem(
                            text = { Text("Date Asc") },
                            onClick = { 
                                viewModel.setSortOrder(SortOrder.ASC)
                                showSortMenu = false 
                            },
                            modifier = Modifier.testTag("sort_apply_button")
                        )
                    }

                    IconButton(onClick = { showOverflowMenu = true }, modifier = Modifier.testTag("overflow_menu_button")) {
                        Text("More")
                    }
                    DropdownMenu(
                        expanded = showOverflowMenu,
                        onDismissRequest = { showOverflowMenu = false },
                        modifier = Modifier.semantics { testTagsAsResourceId = true }
                    ) {
                        DropdownMenuItem(
                            text = { Text("Logout") },
                            onClick = { 
                                showOverflowMenu = false
                                onLogout() 
                            },
                            modifier = Modifier.testTag("logout_button")
                        )
                    }
                }
            )
        }
    ) { padding ->
        Box(modifier = Modifier.fillMaxSize().padding(padding)) {
            if (uiState.isLoading && uiState.videos.isEmpty()) {
                CircularProgressIndicator(modifier = Modifier.align(Alignment.Center).testTag("loading_indicator"))
            } else if (uiState.error != null && uiState.videos.isEmpty()) {
                Column(modifier = Modifier.align(Alignment.Center).testTag("error_view")) {
                    Text("Error: ${uiState.error}")
                    Button(onClick = { viewModel.loadVideos() }, modifier = Modifier.testTag("error_retry_button")) {
                        Text("Retry")
                    }
                }
            } else {
                LazyColumn(modifier = Modifier.fillMaxSize().testTag("video_list")) {
                    items(uiState.videos) { video ->
                        VideoRow(video = video, onClick = { handleVideoClick(video.id) })
                    }
                }
            }

            if (capturedUrl != null) {
                Text(
                    text = capturedUrl!!,
                    modifier = Modifier.align(Alignment.BottomCenter).testTag("external_open_url"),
                    color = MaterialTheme.colorScheme.primary
                )
            }
            if (externalError != null) {
                Text(
                    text = externalError!!,
                    modifier = Modifier.align(Alignment.BottomCenter).testTag("external_open_error"),
                    color = MaterialTheme.colorScheme.error
                )
            }
        }
    }
}

@Composable
fun VideoRow(video: VideoEntity, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable(onClick = onClick)
            .padding(16.dp)
            .semantics(mergeDescendants = true) {
                contentDescription = "${video.title} ${video.publishedAt} ${video.category}"
            }
    ) {
        if (video.thumbnailUrl != null) {
            AsyncImage(
                model = video.thumbnailUrl,
                contentDescription = null,
                modifier = Modifier.size(120.dp, 90.dp)
            )
        } else {
            Box(modifier = Modifier.size(120.dp, 90.dp))
        }
        Spacer(modifier = Modifier.width(16.dp))
        Column {
            Text(
                text = video.title,
                style = MaterialTheme.typography.titleMedium,
                modifier = Modifier.testTag("video_list_item")
            )
            Text(text = video.publishedAt, style = MaterialTheme.typography.bodySmall)
            Text(text = video.category, style = MaterialTheme.typography.bodySmall)
        }
    }
}
