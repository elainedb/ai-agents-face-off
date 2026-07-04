package com.example.ytdash.ui.home

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.*
import androidx.compose.material3.pulltorefresh.PullToRefreshBox
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import coil3.compose.AsyncImage
import com.example.ytdash.LocalTestConfig
import com.example.ytdash.data.Video
import com.example.ytdash.ui.login.LoginViewModel
import kotlinx.coroutines.launch

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    onNavigateToMap: () -> Unit,
    onLogout: () -> Unit,
    viewModel: HomeViewModel,
    loginViewModel: LoginViewModel
) {
    val uiState by viewModel.uiState.collectAsState()
    val testConfig = LocalTestConfig.current
    val context = LocalContext.current

    var showFilterPanel by remember { mutableStateOf(false) }
    var showSortPanel by remember { mutableStateOf(false) }
    var menuExpanded by remember { mutableStateOf(false) }
    var capturedUrl by remember { mutableStateOf<String?>(null) }
    var openError by remember { mutableStateOf(false) }

    val handleOpenVideo = { id: String ->
        val url = "https://www.youtube.com/watch?v=$id"
        if (testConfig.captureExternalLinks) {
            capturedUrl = url
        } else {
            try {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(url))
                context.startActivity(intent)
            } catch (e: ActivityNotFoundException) {
                openError = true
            }
        }
    }

    Scaffold(
        modifier = Modifier.fillMaxSize().testTag("screen_home"),
        topBar = {
            TopAppBar(
                title = {
                    val count = if (uiState is HomeUiState.Content) {
                        (uiState as HomeUiState.Content).totalCount
                    } else 0
                    Text("YT Dash ($count)", modifier = Modifier.testTag("video_count"))
                },
                actions = {
                    IconButton(onClick = onNavigateToMap, modifier = Modifier.testTag("map_nav_button")) {
                        Text("Map")
                    }
                    IconButton(onClick = { viewModel.loadVideos(forceRefresh = true) }, modifier = Modifier.testTag("refresh_control")) {
                        Text("Refresh")
                    }
                    IconButton(onClick = { menuExpanded = true }, modifier = Modifier.testTag("overflow_menu_button")) {
                        Text("Menu")
                    }
                    DropdownMenu(
                        expanded = menuExpanded,
                        onDismissRequest = { menuExpanded = false }
                    ) {
                        DropdownMenuItem(
                            text = { Text("Filter") },
                            onClick = {
                                showFilterPanel = true
                                showSortPanel = false
                                menuExpanded = false
                            },
                            modifier = Modifier.testTag("filter_button")
                        )
                        DropdownMenuItem(
                            text = { Text("Sort") },
                            onClick = {
                                showSortPanel = true
                                showFilterPanel = false
                                menuExpanded = false
                            },
                            modifier = Modifier.testTag("sort_button")
                        )
                        DropdownMenuItem(
                            text = { Text("Logout") },
                            onClick = {
                                menuExpanded = false
                                loginViewModel.onSignOut()
                                onLogout()
                            },
                            modifier = Modifier.testTag("logout_button")
                        )
                    }
                }
            )
        }
    ) { paddingValues ->
        Box(modifier = Modifier.padding(paddingValues).fillMaxSize()) {
            Column(modifier = Modifier.fillMaxSize()) {
                if (capturedUrl != null) {
                    Surface(color = MaterialTheme.colorScheme.tertiaryContainer, modifier = Modifier.fillMaxWidth()) {
                        Text(
                            text = capturedUrl!!,
                            modifier = Modifier.padding(16.dp).testTag("external_open_url"),
                            color = MaterialTheme.colorScheme.onTertiaryContainer
                        )
                    }
                }
                if (openError) {
                    Surface(color = MaterialTheme.colorScheme.errorContainer, modifier = Modifier.fillMaxWidth()) {
                        Text(
                            text = "Error opening YouTube",
                            modifier = Modifier.padding(16.dp).testTag("external_open_error"),
                            color = MaterialTheme.colorScheme.onErrorContainer
                        )
                    }
                }

                when (val state = uiState) {
                    is HomeUiState.Loading -> {
                        Box(modifier = Modifier.fillMaxSize().testTag("loading_indicator"), contentAlignment = Alignment.Center) {
                            CircularProgressIndicator()
                        }
                    }
                    is HomeUiState.Error -> {
                        Column(
                            modifier = Modifier.fillMaxSize().testTag("error_view"),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center
                        ) {
                            Text(state.message, color = MaterialTheme.colorScheme.error)
                            Spacer(Modifier.height(16.dp))
                            Button(
                                onClick = { viewModel.loadVideos(forceRefresh = true) },
                                modifier = Modifier.testTag("error_retry_button")
                            ) {
                                Text("Retry")
                            }
                        }
                    }
                    is HomeUiState.Content -> {
                        if (showFilterPanel) {
                            FilterPanel(
                                state = state,
                                onApply = { cat ->
                                    viewModel.setCategory(cat)
                                    showFilterPanel = false
                                }
                            )
                        } else if (showSortPanel) {
                            SortPanel(
                                state = state,
                                onApply = { sort ->
                                    viewModel.setSort(sort)
                                    showSortPanel = false
                                }
                            )
                        } else {
                            PullToRefreshBox(
                                isRefreshing = false,
                                onRefresh = { viewModel.loadVideos(forceRefresh = true) }
                            ) {
                                LazyColumn(
                                    modifier = Modifier.fillMaxSize().testTag("video_list"),
                                    contentPadding = PaddingValues(16.dp),
                                    verticalArrangement = Arrangement.spacedBy(16.dp)
                                ) {
                                    items(state.videos, key = { it.id }) { video ->
                                        VideoRow(video = video, onClick = { handleOpenVideo(video.id) })
                                    }
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun VideoRow(video: Video, onClick: () -> Unit) {
    Card(
        modifier = Modifier.fillMaxWidth().clickable { onClick() }
    ) {
        Column(modifier = Modifier.padding(16.dp)) {
            AsyncImage(
                model = video.thumbnailUrl,
                contentDescription = null,
                modifier = Modifier.fillMaxWidth().height(180.dp)
            )
            Spacer(Modifier.height(8.dp))
            // IMPORTANT: Tag the title text with video_list_item to satisfy Compose testing caveats
            Text(
                text = video.title,
                style = MaterialTheme.typography.titleMedium,
                fontWeight = FontWeight.Bold,
                modifier = Modifier.testTag("video_list_item")
            )
            Spacer(Modifier.height(4.dp))
            Text(
                text = "${video.category} • ${video.publishedAt}",
                style = MaterialTheme.typography.bodySmall,
                color = MaterialTheme.colorScheme.onSurfaceVariant
            )
            Spacer(Modifier.height(4.dp))
            Text(
                text = video.description,
                style = MaterialTheme.typography.bodyMedium,
                maxLines = 2
            )
        }
    }
}

@Composable
fun FilterPanel(state: HomeUiState.Content, onApply: (String?) -> Unit) {
    var selected by remember { mutableStateOf(state.currentCategory) }
    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Text("Filter by Category", style = MaterialTheme.typography.titleLarge)
        Spacer(Modifier.height(16.dp))
        Row(verticalAlignment = Alignment.CenterVertically) {
            RadioButton(selected = selected == null, onClick = { selected = null })
            Text("All")
        }
        state.allCategories.forEach { cat ->
            Row(verticalAlignment = Alignment.CenterVertically) {
                RadioButton(selected = selected == cat, onClick = { selected = cat })
                Text(cat)
            }
        }
        Spacer(Modifier.height(16.dp))
        Button(onClick = { onApply(selected) }, modifier = Modifier.testTag("filter_apply_button")) {
            Text("Apply Filter")
        }
    }
}

@Composable
fun SortPanel(state: HomeUiState.Content, onApply: (SortOption) -> Unit) {
    var selected by remember { mutableStateOf(state.currentSort) }
    Column(modifier = Modifier.fillMaxSize().padding(16.dp)) {
        Text("Sort Options", style = MaterialTheme.typography.titleLarge)
        Spacer(Modifier.height(16.dp))
        SortOption.entries.forEach { opt ->
            Row(verticalAlignment = Alignment.CenterVertically) {
                RadioButton(selected = selected == opt, onClick = { selected = opt })
                Text(opt.label) // Sort option labels must END with the regex keyword, e.g. 'Date — newest'
            }
        }
        Spacer(Modifier.height(16.dp))
        Button(onClick = { onApply(selected) }, modifier = Modifier.testTag("sort_apply_button")) {
            Text("Apply Sort")
        }
    }
}
