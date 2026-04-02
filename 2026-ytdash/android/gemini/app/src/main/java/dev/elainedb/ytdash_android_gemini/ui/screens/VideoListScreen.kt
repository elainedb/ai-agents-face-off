package dev.elainedb.ytdash_android_gemini.ui.screens

import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ExitToApp
import androidx.compose.material.icons.filled.FilterList
import androidx.compose.material.icons.filled.Map
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Sort
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import dev.elainedb.ytdash_android_gemini.models.Video
import dev.elainedb.ytdash_android_gemini.viewmodel.VideoListViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VideoListScreen(
    viewModel: VideoListViewModel,
    onLogoutClick: () -> Unit,
    onMapClick: () -> Unit
) {
    val videos by viewModel.videos.collectAsState()
    val isLoading by viewModel.isLoading.collectAsState()
    val isRefreshing by viewModel.isRefreshing.collectAsState()
    val channels by viewModel.distinctChannels.collectAsState()
    val countries by viewModel.distinctCountries.collectAsState()

    val currentChannel by viewModel.channelFilter.collectAsState()
    val currentCountry by viewModel.countryFilter.collectAsState()
    val currentSort by viewModel.sortBy.collectAsState()

    var showFilterDialog by remember { mutableStateOf(false) }
    var showSortDialog by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("YT Dashboard") },
                actions = {
                    IconButton(onClick = onMapClick) {
                        Icon(Icons.Filled.Map, contentDescription = "View Map")
                    }
                    IconButton(onClick = { showFilterDialog = true }) {
                        Icon(Icons.Filled.FilterList, contentDescription = "Filter")
                    }
                    IconButton(onClick = { showSortDialog = true }) {
                        Icon(Icons.Filled.Sort, contentDescription = "Sort")
                    }
                    IconButton(onClick = onLogoutClick) {
                        Icon(Icons.Filled.ExitToApp, contentDescription = "Logout")
                    }
                }
            )
        },
        floatingActionButton = {
            FloatingActionButton(onClick = { viewModel.refresh() }) {
                Icon(Icons.Filled.Refresh, contentDescription = "Refresh")
            }
        }
    ) { paddingValues ->
        Box(modifier = Modifier.fillMaxSize().padding(paddingValues)) {
            if (isLoading && videos.isEmpty()) {
                CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
            } else {
                val context = LocalContext.current
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    items(videos, key = { it.id }) { video ->
                        VideoItem(video, onClick = {
                            dev.elainedb.ytdash_android_gemini.utils.YouTubeUtils.openYouTubeVideo(context, video.id)
                        })
                    }
                }
            }
            if (isRefreshing) {
                LinearProgressIndicator(modifier = Modifier.fillMaxWidth().align(Alignment.TopCenter))
            }
        }
    }

    if (showFilterDialog) {
        FilterDialog(
            channels = channels,
            countries = countries,
            selectedChannel = currentChannel,
            selectedCountry = currentCountry,
            onDismiss = { showFilterDialog = false },
            onApply = { channel, country ->
                viewModel.setChannelFilter(channel)
                viewModel.setCountryFilter(country)
                showFilterDialog = false
            }
        )
    }

    if (showSortDialog) {
        SortDialog(
            currentSort = currentSort,
            onDismiss = { showSortDialog = false },
            onApply = { sort ->
                viewModel.setSortBy(sort)
                showSortDialog = false
            }
        )
    }
}

@Composable
fun VideoItem(video: Video, onClick: () -> Unit = {}) {
    Card(
        modifier = Modifier.fillMaxWidth().clickable { onClick() },
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column {
            AsyncImage(
                model = video.thumbnailUrl,
                contentDescription = video.title,
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(16f / 9f),
                contentScale = ContentScale.Crop
            )
            Column(modifier = Modifier.padding(16.dp)) {
                Text(text = video.title, style = MaterialTheme.typography.titleMedium, maxLines = 2, overflow = TextOverflow.Ellipsis)
                Spacer(modifier = Modifier.height(4.dp))
                Text(text = video.channelName, style = MaterialTheme.typography.bodyMedium)
                Spacer(modifier = Modifier.height(4.dp))
                Text(text = "Published: ${video.publishedAt}", style = MaterialTheme.typography.bodySmall)
                if (video.locationCountry != null) {
                    Text(text = "Location: ${video.locationCity ?: ""} ${video.locationCountry}", style = MaterialTheme.typography.bodySmall)
                }
                if (video.recordingDate != null) {
                    Text(text = "Recorded: ${video.recordingDate}", style = MaterialTheme.typography.bodySmall)
                }
            }
        }
    }
}

@Composable
fun FilterDialog(
    channels: List<String>,
    countries: List<String>,
    selectedChannel: String?,
    selectedCountry: String?,
    onDismiss: () -> Unit,
    onApply: (String?, String?) -> Unit
) {
    var tempChannel by remember { mutableStateOf(selectedChannel) }
    var tempCountry by remember { mutableStateOf(selectedCountry) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Filter Videos") },
        text = {
            Column {
                Text("Channel", style = MaterialTheme.typography.labelLarge)
                DropdownMenuBox(
                    options = listOf("All") + channels,
                    selectedOption = tempChannel ?: "All",
                    onOptionSelected = { tempChannel = if (it == "All") null else it }
                )
                Spacer(modifier = Modifier.height(16.dp))
                Text("Country", style = MaterialTheme.typography.labelLarge)
                DropdownMenuBox(
                    options = listOf("All") + countries,
                    selectedOption = tempCountry ?: "All",
                    onOptionSelected = { tempCountry = if (it == "All") null else it }
                )
            }
        },
        confirmButton = {
            TextButton(onClick = { onApply(tempChannel, tempCountry) }) {
                Text("Apply")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun DropdownMenuBox(
    options: List<String>,
    selectedOption: String,
    onOptionSelected: (String) -> Unit
) {
    var expanded by remember { mutableStateOf(false) }

    ExposedDropdownMenuBox(
        expanded = expanded,
        onExpandedChange = { expanded = !expanded }
    ) {
        OutlinedTextField(
            readOnly = true,
            value = selectedOption,
            onValueChange = { },
            trailingIcon = {
                ExposedDropdownMenuDefaults.TrailingIcon(expanded = expanded)
            },
            modifier = Modifier.menuAnchor().fillMaxWidth()
        )
        ExposedDropdownMenu(
            expanded = expanded,
            onDismissRequest = { expanded = false }
        ) {
            options.forEach { option ->
                DropdownMenuItem(
                    text = { Text(option) },
                    onClick = {
                        onOptionSelected(option)
                        expanded = false
                    }
                )
            }
        }
    }
}

@Composable
fun SortDialog(
    currentSort: String,
    onDismiss: () -> Unit,
    onApply: (String) -> Unit
) {
    var tempSort by remember { mutableStateOf(currentSort) }
    val sortOptions = listOf(
        "PUB_DATE_DESC" to "Published Date (Newest)",
        "PUB_DATE_ASC" to "Published Date (Oldest)",
        "REC_DATE_DESC" to "Recording Date (Newest)",
        "REC_DATE_ASC" to "Recording Date (Oldest)"
    )

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Sort Videos") },
        text = {
            Column {
                sortOptions.forEach { (key, label) ->
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { tempSort = key }
                            .padding(vertical = 8.dp)
                    ) {
                        RadioButton(
                            selected = tempSort == key,
                            onClick = { tempSort = key }
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(text = label)
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = { onApply(tempSort) }) {
                Text("Apply")
            }
        },
        dismissButton = {
            TextButton(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}
