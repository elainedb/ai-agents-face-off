package dev.elainedb.ytdash_android_gemini.ui

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.ExitToApp
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import dev.elainedb.ytdash_android_gemini.MapActivity
import dev.elainedb.ytdash_android_gemini.model.Video
import dev.elainedb.ytdash_android_gemini.viewmodel.SortOption
import dev.elainedb.ytdash_android_gemini.viewmodel.VideoListUiState
import dev.elainedb.ytdash_android_gemini.viewmodel.VideoListViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VideoListScreen(
    viewModel: VideoListViewModel,
    onLogoutClick: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    val availableCountries by viewModel.availableCountries.collectAsState()
    val availableChannels by viewModel.availableChannels.collectAsState()
    val context = LocalContext.current

    var showFilterDialog by remember { mutableStateOf(false) }
    var showSortDialog by remember { mutableStateOf(false) }

    var selectedChannel by remember { mutableStateOf<String?>(null) }
    var selectedCountry by remember { mutableStateOf<String?>(null) }
    var selectedSortOption by remember { mutableStateOf(SortOption.PUB_DATE_DESC) }

    if (showFilterDialog) {
        FilterDialog(
            channels = availableChannels,
            countries = availableCountries,
            currentChannel = selectedChannel,
            currentCountry = selectedCountry,
            onDismiss = { showFilterDialog = false },
            onApply = { channel, country ->
                selectedChannel = channel
                selectedCountry = country
                viewModel.applyFilter(channel, country)
                showFilterDialog = false
            }
        )
    }

    if (showSortDialog) {
        SortDialog(
            currentSortOption = selectedSortOption,
            onDismiss = { showSortDialog = false },
            onApply = { sortOption ->
                selectedSortOption = sortOption
                viewModel.applySorting(sortOption)
                showSortDialog = false
            }
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("YouTube Videos") },
                actions = {
                    IconButton(onClick = onLogoutClick) {
                        Icon(Icons.Filled.ExitToApp, contentDescription = "Logout")
                    }
                }
            )
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(8.dp),
                horizontalArrangement = Arrangement.SpaceEvenly
            ) {
                Button(onClick = { viewModel.refreshVideos() }) { Text("Refresh") }
                Button(onClick = {
                    context.startActivity(MapActivity.newIntent(context))
                }) { Text("View Map") }
                Button(onClick = { showFilterDialog = true }) { Text("Filter") }
                Button(onClick = { showSortDialog = true }) { Text("Sort") }
            }

            if (selectedChannel != null || selectedCountry != null) {
                if (uiState is VideoListUiState.Success) {
                    val state = uiState as VideoListUiState.Success
                    Text(
                        text = "Showing ${state.videos.size} of ${state.totalCount} videos",
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 4.dp),
                        style = MaterialTheme.typography.bodySmall
                    )
                }
            }

            Box(modifier = Modifier.weight(1f)) {
                when (val state = uiState) {
                    is VideoListUiState.Loading -> {
                        CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
                    }
                    is VideoListUiState.Empty -> {
                        Text("No videos found", modifier = Modifier.align(Alignment.Center))
                    }
                    is VideoListUiState.Error -> {
                        Text(
                            text = "Error: ${state.message}",
                            color = MaterialTheme.colorScheme.error,
                            modifier = Modifier.align(Alignment.Center)
                        )
                    }
                    is VideoListUiState.Success -> {
                        LazyColumn(
                            modifier = Modifier.fillMaxSize(),
                            contentPadding = PaddingValues(16.dp),
                            verticalArrangement = Arrangement.spacedBy(16.dp)
                        ) {
                            items(state.videos) { video ->
                                VideoItem(video = video, context = context)
                            }
                        }
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VideoItem(video: Video, context: android.content.Context) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable {
                val intentApp = Intent(Intent.ACTION_VIEW, Uri.parse("vnd.youtube:${video.id}"))
                val intentBrowser = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=${video.id}"))
                try {
                    context.startActivity(intentApp)
                } catch (e: ActivityNotFoundException) {
                    context.startActivity(intentBrowser)
                }
            },
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column {
            AsyncImage(
                model = video.thumbnailUrl,
                contentDescription = "Video Thumbnail",
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(16f / 9f),
                contentScale = ContentScale.Crop
            )
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = video.title,
                    style = MaterialTheme.typography.titleMedium,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis
                )
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        text = video.channelName,
                        style = MaterialTheme.typography.bodyMedium,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                    Text(
                        text = video.publishedAt,
                        style = MaterialTheme.typography.bodySmall,
                        color = MaterialTheme.colorScheme.onSurfaceVariant
                    )
                }
                Spacer(modifier = Modifier.height(8.dp))
                LazyRow(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                    if (video.locationCity != null || video.locationCountry != null) {
                        val location = listOfNotNull(video.locationCity, video.locationCountry).joinToString(", ")
                        item {
                            SuggestionChip(onClick = {}, label = { Text(location) })
                        }
                    }
                    if (video.recordingDate != null) {
                        item {
                            SuggestionChip(onClick = {}, label = { Text("Rec: ${video.recordingDate}") })
                        }
                    }
                    items(video.tags) { tag ->
                        SuggestionChip(onClick = {}, label = { Text(tag) })
                    }
                }
            }
        }
    }
}

@Composable
fun FilterDialog(
    channels: List<String>,
    countries: List<String>,
    currentChannel: String?,
    currentCountry: String?,
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
                Text("Channel", style = MaterialTheme.typography.titleSmall)
                Row(verticalAlignment = Alignment.CenterVertically) {
                    RadioButton(selected = selectedChannel == null, onClick = { selectedChannel = null })
                    Text("All Channels")
                }
                channels.forEach { channel ->
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        RadioButton(selected = selectedChannel == channel, onClick = { selectedChannel = channel })
                        Text(channel)
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))

                Text("Country", style = MaterialTheme.typography.titleSmall)
                Row(verticalAlignment = Alignment.CenterVertically) {
                    RadioButton(selected = selectedCountry == null, onClick = { selectedCountry = null })
                    Text("All Countries")
                }
                countries.forEach { country ->
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        RadioButton(selected = selectedCountry == country, onClick = { selectedCountry = country })
                        Text(country)
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
    currentSortOption: SortOption,
    onDismiss: () -> Unit,
    onApply: (SortOption) -> Unit
) {
    var selectedOption by remember { mutableStateOf(currentSortOption) }

    val options = listOf(
        SortOption.PUB_DATE_DESC to "Publication Date (Newest First)",
        SortOption.PUB_DATE_ASC to "Publication Date (Oldest First)",
        SortOption.REC_DATE_DESC to "Recording Date (Newest First)",
        SortOption.REC_DATE_ASC to "Recording Date (Oldest First)"
    )

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Sort Videos") },
        text = {
            Column {
                options.forEach { (option, label) ->
                    Row(verticalAlignment = Alignment.CenterVertically) {
                        RadioButton(selected = selectedOption == option, onClick = { selectedOption = option })
                        Text(label)
                    }
                }
            }
        },
        confirmButton = {
            TextButton(onClick = { onApply(selectedOption) }) {
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
