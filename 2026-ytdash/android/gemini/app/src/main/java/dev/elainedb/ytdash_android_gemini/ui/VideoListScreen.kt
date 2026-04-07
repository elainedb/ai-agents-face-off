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

@Composable
fun VideoListScreen(
    viewModel: VideoListViewModel,
    onViewMapClick: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    val availableChannels by viewModel.availableChannels.collectAsState()
    val availableCountries by viewModel.availableCountries.collectAsState()
    val filterOptions by viewModel.filterOptions.collectAsState()
    val sortOption by viewModel.sortOption.collectAsState()
    
    var showFilterDialog by remember { mutableStateOf(false) }
    var showSortDialog by remember { mutableStateOf(false) }

    Column(modifier = Modifier.fillMaxSize()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(8.dp),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            Button(onClick = { viewModel.fetchVideos(forceRefresh = true) }) {
                Text("Refresh")
            }
            Button(onClick = onViewMapClick) {
                Text("View Map")
            }
            Button(onClick = { showFilterDialog = true }) {
                Text("Filter")
            }
            Button(onClick = { showSortDialog = true }) {
                Text("Sort")
            }
        }

        when (val state = uiState) {
            is VideoListUiState.Loading -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator()
                }
            }
            is VideoListUiState.Empty -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Text("No videos found.")
                }
            }
            is VideoListUiState.Error -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Text(text = "Error: ${state.message}", color = MaterialTheme.colorScheme.error)
                }
            }
            is VideoListUiState.Success -> {
                Text(
                    text = "Showing ${state.videos.size} of ${state.totalCount} videos",
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                    style = MaterialTheme.typography.bodyMedium
                )
                LazyColumn(
                    modifier = Modifier.fillMaxSize(),
                    contentPadding = PaddingValues(16.dp),
                    verticalArrangement = Arrangement.spacedBy(16.dp)
                ) {
                    items(
                        items = state.videos,
                        key = { video -> video.id }
                    ) { video ->
                        VideoItem(video = video)
                    }
                }
            }
        }
    }

    if (showFilterDialog) {
        FilterDialog(
            availableChannels = availableChannels,
            availableCountries = availableCountries,
            initialChannel = filterOptions.channelName,
            initialCountry = filterOptions.country,
            onDismiss = { showFilterDialog = false },
            onApply = { channel, country ->
                viewModel.applyFilter(channel, country)
                showFilterDialog = false
            }
        )
    }

    if (showSortDialog) {
        SortDialog(
            initialSort = sortOption,
            onDismiss = { showSortDialog = false },
            onApply = { newSortOption ->
                viewModel.applySorting(newSortOption)
                showSortDialog = false
            }
        )
    }
}

@Composable
fun VideoItem(video: Video) {
    val context = LocalContext.current
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("vnd.youtube:${video.id}"))
                intent.flags = Intent.FLAG_ACTIVITY_NEW_TASK
                try {
                    context.startActivity(intent)
                } catch (e: Exception) {
                    val webIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=${video.id}"))
                    context.startActivity(webIntent)
                }
            },
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column(modifier = Modifier.fillMaxWidth()) {
            AsyncImage(
                model = video.thumbnailUrl,
                contentDescription = "Video Thumbnail",
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
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = video.channelName,
                    style = MaterialTheme.typography.bodyMedium
                )
                Spacer(modifier = Modifier.height(4.dp))
                Text(
                    text = "Published: ${video.publishedAt.take(10)}",
                    style = MaterialTheme.typography.bodySmall
                )
                if (video.recordingDate != null) {
                    Spacer(modifier = Modifier.height(4.dp))
                    Text(
                        text = "Recorded: ${video.recordingDate.take(10)}",
                        style = MaterialTheme.typography.bodySmall
                    )
                }
                if (video.locationCity != null || video.locationCountry != null) {
                    Spacer(modifier = Modifier.height(4.dp))
                    val locationStr = listOfNotNull(video.locationCity, video.locationCountry).joinToString(", ")
                    val gpsStr = if (video.locationLatitude != null && video.locationLongitude != null) " (${video.locationLatitude}, ${video.locationLongitude})" else ""
                    Text(
                        text = "Location: $locationStr$gpsStr",
                        style = MaterialTheme.typography.bodySmall
                    )
                }
                if (video.tags.isNotEmpty()) {
                    Spacer(modifier = Modifier.height(8.dp))
                    @OptIn(ExperimentalLayoutApi::class)
                    FlowRow(
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        verticalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        video.tags.take(5).forEach { tag ->
                            SuggestionChip(
                                onClick = { },
                                label = { Text(tag) }
                            )
                        }
                        if (video.tags.size > 5) {
                            SuggestionChip(
                                onClick = { },
                                label = { Text("+${video.tags.size - 5} more") }
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
    availableChannels: List<String>,
    availableCountries: List<String>,
    initialChannel: String?,
    initialCountry: String?,
    onDismiss: () -> Unit,
    onApply: (channel: String?, country: String?) -> Unit
) {
    var selectedChannel by remember(initialChannel) { mutableStateOf(initialChannel ?: "All Channels") }
    var selectedCountry by remember(initialCountry) { mutableStateOf(initialCountry ?: "All Countries") }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Filter Videos") },
        text = {
            Column {
                Text("Channel", fontWeight = FontWeight.Bold)
                val channelOptions = listOf("All Channels") + availableChannels
                channelOptions.forEach { channel ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { selectedChannel = channel }
                            .padding(vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        RadioButton(
                            selected = selectedChannel == channel,
                            onClick = { selectedChannel = channel }
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(channel)
                    }
                }

                Spacer(modifier = Modifier.height(16.dp))
                
                Text("Country", fontWeight = FontWeight.Bold)
                val countryOptions = listOf("All Countries") + availableCountries
                countryOptions.forEach { country ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { selectedCountry = country }
                            .padding(vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        RadioButton(
                            selected = selectedCountry == country,
                            onClick = { selectedCountry = country }
                        )
                        Spacer(modifier = Modifier.width(8.dp))
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
    initialSort: SortOption,
    onDismiss: () -> Unit,
    onApply: (SortOption) -> Unit
) {
    var selectedSort by remember { mutableStateOf(initialSort) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text("Sort Videos") },
        text = {
            Column {
                SortOption.values().forEach { option ->
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .clickable { selectedSort = option }
                            .padding(vertical = 8.dp),
                        verticalAlignment = Alignment.CenterVertically
                    ) {
                        RadioButton(
                            selected = selectedSort == option,
                            onClick = { selectedSort = option }
                        )
                        Spacer(modifier = Modifier.width(8.dp))
                        Text(option.displayName)
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
