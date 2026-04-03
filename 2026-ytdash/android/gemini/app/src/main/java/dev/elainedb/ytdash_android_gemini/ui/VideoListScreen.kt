package dev.elainedb.ytdash_android_gemini.ui

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.Arrangement
import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.ExperimentalLayoutApi
import androidx.compose.foundation.layout.FlowRow
import androidx.compose.foundation.layout.Row
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.fillMaxWidth
import androidx.compose.foundation.layout.height
import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material3.Button
import androidx.compose.material3.Card
import androidx.compose.material3.CircularProgressIndicator
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.SuggestionChip
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import dev.elainedb.ytdash_android_gemini.MapActivity
import dev.elainedb.ytdash_android_gemini.model.Video
import dev.elainedb.ytdash_android_gemini.viewmodel.VideoListUiState
import dev.elainedb.ytdash_android_gemini.viewmodel.VideoListViewModel

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun VideoListScreen(viewModel: VideoListViewModel, modifier: Modifier = Modifier) {
    val uiState by viewModel.uiState.collectAsState()
    val filterOptions by viewModel.filterOptions.collectAsState()
    val sortOption by viewModel.sortOption.collectAsState()
    val availableChannels by viewModel.availableChannels.collectAsState()
    val availableCountries by viewModel.availableCountries.collectAsState()
    val totalCount by viewModel.totalVideoCount.collectAsState()

    var showFilterDialog by remember { mutableStateOf(false) }
    var showSortDialog by remember { mutableStateOf(false) }

    val context = LocalContext.current

    Column(modifier = modifier.fillMaxSize()) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(8.dp),
            horizontalArrangement = Arrangement.SpaceEvenly
        ) {
            Button(onClick = { viewModel.refreshVideos() }) {
                Text("Refresh")
            }
            Button(onClick = { context.startActivity(Intent(context, MapActivity::class.java)) }) {
                Text("View Map")
            }
            Button(onClick = { showFilterDialog = true }) {
                Text("Filter")
            }
            Button(onClick = { showSortDialog = true }) {
                Text("Sort")
            }
        }

        if (showFilterDialog) {
            FilterDialog(
                availableChannels = availableChannels,
                availableCountries = availableCountries,
                currentChannel = filterOptions.channelName,
                currentCountry = filterOptions.country,
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
                onApply = { option ->
                    viewModel.applySorting(option)
                    showSortDialog = false
                }
            )
        }

        when (val state = uiState) {
            is VideoListUiState.Loading -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    CircularProgressIndicator()
                }
            }
            is VideoListUiState.Error -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Text("Error: ${state.message}", color = MaterialTheme.colorScheme.error)
                }
            }
            is VideoListUiState.Empty -> {
                Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                    Text("No videos found matching filters.")
                }
            }
            is VideoListUiState.Success -> {
                val videos = state.videos
                Text(
                    text = "Showing ${videos.size} of ${state.totalCount} videos",
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                    style = MaterialTheme.typography.bodyMedium
                )
                LazyColumn(modifier = Modifier.fillMaxSize()) {
                    items(videos, key = { it.id }) { video ->
                        VideoItem(video = video) {
                            val intent = Intent(Intent.ACTION_VIEW, Uri.parse("vnd.youtube:${video.id}"))
                            val fallbackIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=${video.id}"))
                            try {
                                context.startActivity(intent)
                            } catch (e: Exception) {
                                context.startActivity(fallbackIntent)
                            }
                        }
                    }
                }
            }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun VideoItem(video: Video, onClick: () -> Unit) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(horizontal = 16.dp, vertical = 8.dp)
            .clickable(onClick = onClick)
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
                Text(text = video.title, style = MaterialTheme.typography.titleMedium)
                Spacer(modifier = Modifier.height(4.dp))
                Text(text = video.channelName, style = MaterialTheme.typography.bodyMedium)
                Text(text = "Published: ${video.publishedAt.take(10)}", style = MaterialTheme.typography.bodySmall)

                if (video.recordingDate != null) {
                    Text(text = "Recorded: ${video.recordingDate.take(10)}", style = MaterialTheme.typography.bodySmall)
                }

                if (video.locationCity != null || video.locationCountry != null) {
                    val locationText = listOfNotNull(video.locationCity, video.locationCountry).joinToString(", ")
                    val gps = if (video.locationLatitude != null && video.locationLongitude != null) {
                        " (%.4f, %.4f)".format(video.locationLatitude, video.locationLongitude)
                    } else ""
                    Text(text = "Location: $locationText$gps", style = MaterialTheme.typography.bodySmall)
                }

                if (video.tags.isNotEmpty()) {
                    Spacer(modifier = Modifier.height(8.dp))
                    FlowRow(horizontalArrangement = Arrangement.spacedBy(4.dp)) {
                        video.tags.take(5).forEach { tag ->
                            SuggestionChip(
                                onClick = { },
                                label = { Text(tag) }
                            )
                        }
                    }
                }
            }
        }
    }
}
