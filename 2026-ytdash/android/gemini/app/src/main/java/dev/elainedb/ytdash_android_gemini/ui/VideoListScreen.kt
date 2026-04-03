package dev.elainedb.ytdash_android_gemini.ui

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
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import dev.elainedb.ytdash_android_gemini.model.Video
import dev.elainedb.ytdash_android_gemini.viewmodel.SortOption
import dev.elainedb.ytdash_android_gemini.viewmodel.VideoListUiState
import dev.elainedb.ytdash_android_gemini.viewmodel.VideoListViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VideoListScreen(
    viewModel: VideoListViewModel,
    onLogoutClick: () -> Unit,
    onViewMapClick: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    val filterOptions by viewModel.filterOptions.collectAsState()
    val sortOption by viewModel.sortOption.collectAsState()
    val availableChannels by viewModel.availableChannels.collectAsState()
    val availableCountries by viewModel.availableCountries.collectAsState()

    var showFilterDialog by remember { mutableStateOf(false) }
    var showSortDialog by remember { mutableStateOf(false) }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("YT Dashboard") },
                actions = {
                    IconButton(onClick = onLogoutClick) {
                        Text("Logout", modifier = Modifier.padding(end = 8.dp))
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(modifier = Modifier.padding(paddingValues)) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(8.dp),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                Button(onClick = { viewModel.refreshVideos() }) { Text("Refresh") }
                Button(onClick = onViewMapClick) { Text("View Map") }
                Button(onClick = { showFilterDialog = true }) { Text("Filter") }
                Button(onClick = { showSortDialog = true }) { Text("Sort") }
            }

            if (uiState is VideoListUiState.Success) {
                val successState = uiState as VideoListUiState.Success
                if (filterOptions.channelName != null || filterOptions.country != null) {
                    Text(
                        text = "Showing ${successState.videos.size} of ${successState.totalCount} videos",
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                        style = MaterialTheme.typography.bodyMedium
                    )
                }
            }

            Box(modifier = Modifier.fillMaxSize()) {
                when (uiState) {
                    is VideoListUiState.Loading -> {
                        CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
                    }
                    is VideoListUiState.Empty -> {
                        Text("No videos found", modifier = Modifier.align(Alignment.Center))
                    }
                    is VideoListUiState.Error -> {
                        Text(
                            text = (uiState as VideoListUiState.Error).message,
                            color = MaterialTheme.colorScheme.error,
                            modifier = Modifier.align(Alignment.Center)
                        )
                    }
                    is VideoListUiState.Success -> {
                        val videos = (uiState as VideoListUiState.Success).videos
                        LazyColumn(
                            contentPadding = PaddingValues(16.dp),
                            verticalArrangement = Arrangement.spacedBy(16.dp)
                        ) {
                            items(videos) { video ->
                                VideoItem(video)
                            }
                        }
                    }
                }
            }
        }

        if (showFilterDialog) {
            FilterDialog(
                currentChannel = filterOptions.channelName,
                currentCountry = filterOptions.country,
                channels = availableChannels,
                countries = availableCountries,
                onDismiss = { showFilterDialog = false },
                onApply = { channel, country ->
                    viewModel.applyFilter(channel, country)
                    showFilterDialog = false
                }
            )
        }

        if (showSortDialog) {
            SortDialog(
                currentSort = sortOption,
                onDismiss = { showSortDialog = false },
                onApply = { sort ->
                    viewModel.applySorting(sort)
                    showSortDialog = false
                }
            )
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun VideoItem(video: Video) {
    val context = LocalContext.current
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("vnd.youtube:${video.id}"))
                intent.putExtra("force_fullscreen", true)
                try {
                    context.startActivity(intent)
                } catch (e: Exception) {
                    val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=${video.id}"))
                    context.startActivity(webIntent)
                }
            },
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column {
            AsyncImage(
                model = video.thumbnailUrl,
                contentDescription = video.title,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp),
                contentScale = ContentScale.Crop
            )
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = video.title,
                    style = MaterialTheme.typography.titleMedium,
                    fontWeight = FontWeight.Bold,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(text = "Channel: ${video.channelName}", style = MaterialTheme.typography.bodyMedium)
                Text(text = "Published: ${video.publishedAt.take(10)}", style = MaterialTheme.typography.bodySmall)

                if (video.recordingDate != null) {
                    Text(text = "Recorded: ${video.recordingDate.take(10)}", style = MaterialTheme.typography.bodySmall)
                }

                if (video.locationCity != null || video.locationCountry != null) {
                    val loc = listOfNotNull(video.locationCity, video.locationCountry).joinToString(", ")
                    val gps = if (video.locationLatitude != null && video.locationLongitude != null) {
                        " (%.4f, %.4f)".format(video.locationLatitude, video.locationLongitude)
                    } else ""
                    Text(text = "Location: $loc$gps", style = MaterialTheme.typography.bodySmall)
                }

                if (video.tags.isNotEmpty()) {
                    Spacer(modifier = Modifier.height(8.dp))
                    FlowRow(
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        verticalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        video.tags.take(5).forEach { tag ->
                            SuggestionChip(
                                onClick = {},
                                label = { Text(tag, style = MaterialTheme.typography.labelSmall) }
                            )
                        }
                        if (video.tags.size > 5) {
                            SuggestionChip(
                                onClick = {},
                                label = { Text("+${video.tags.size - 5}", style = MaterialTheme.typography.labelSmall) }
                            )
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun FilterDialog(
    currentChannel: String?,
    currentCountry: String?,
    channels: List<String>,
    countries: List<String>,
    onDismiss: () -> Unit,
    onApply: (String?, String?) -> Unit
) {
    var selectedChannel by remember { mutableStateOf(currentChannel) }
    var selectedCountry by remember { mutableStateOf(currentCountry) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Filter Videos") },
        text = {
            Column {
                Text("Channel", fontWeight = FontWeight.Bold)
                LazyColumn(modifier = Modifier.heightIn(max = 100.dp)) {
                    item {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            RadioButton(selected = selectedChannel == null, onClick = { selectedChannel = null })
                            Text("All Channels")
                        }
                    }
                    items(channels) { channel ->
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            RadioButton(selected = selectedChannel == channel, onClick = { selectedChannel = channel })
                            Text(channel)
                        }
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                Text("Country", fontWeight = FontWeight.Bold)
                LazyColumn(modifier = Modifier.heightIn(max = 100.dp)) {
                    item {
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            RadioButton(selected = selectedCountry == null, onClick = { selectedCountry = null })
                            Text("All Countries")
                        }
                    }
                    items(countries) { country ->
                        Row(verticalAlignment = Alignment.CenterVertically) {
                            RadioButton(selected = selectedCountry == country, onClick = { selectedCountry = country })
                            Text(country)
                        }
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = { onApply(selectedChannel, selectedCountry) }) {
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

@Composable
fun SortDialog(
    currentSort: SortOption,
    onDismiss: () -> Unit,
    onApply: (SortOption) -> Unit
) {
    var selectedSort by remember { mutableStateOf(currentSort) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Sort Videos") },
        text = {
            Column {
                val options = listOf(
                    SortOption.PUB_DATE_DESC to "Publication Date (Newest First)",
                    SortOption.PUB_DATE_ASC to "Publication Date (Oldest First)",
                    SortOption.REC_DATE_DESC to "Recording Date (Newest First)",
                    SortOption.REC_DATE_ASC to "Recording Date (Oldest First)"
                )
                options.forEach { (option, label) ->
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        RadioButton(selected = selectedSort == option, onClick = { selectedSort = option })
                        Text(label)
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = { onApply(selectedSort) }) {
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
