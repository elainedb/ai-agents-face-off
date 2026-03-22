package dev.elainedb.ytdash_android_gemini.ui.screen

import android.content.ActivityNotFoundException
import android.content.Intent
import android.net.Uri
import android.widget.Toast
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.unit.dp
import coil.compose.AsyncImage
import dev.elainedb.ytdash_android_gemini.data.model.Video
import dev.elainedb.ytdash_android_gemini.ui.viewmodel.VideoListUiState
import dev.elainedb.ytdash_android_gemini.ui.viewmodel.VideoListViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VideoListScreen(
    viewModel: VideoListViewModel,
    onLogoutClick: () -> Unit
) {
    val uiState by viewModel.uiState.collectAsState()
    val filterOptions by viewModel.filterOptions.collectAsState()
    val sortOption by viewModel.sortOption.collectAsState()
    val availableCountries by viewModel.availableCountries.collectAsState()
    val availableChannels by viewModel.availableChannels.collectAsState()
    val totalVideoCount by viewModel.totalVideoCount.collectAsState()

    var showFilterDialog by remember { mutableStateOf(false) }
    var showSortDialog by remember { mutableStateOf(false) }
    
    val context = LocalContext.current

    if (showFilterDialog) {
        FilterDialog(
            currentChannel = filterOptions.channelName,
            currentCountry = filterOptions.country,
            availableChannels = availableChannels,
            availableCountries = availableCountries,
            onApply = { channel, country ->
                viewModel.applyFilter(channel, country)
                showFilterDialog = false
            },
            onDismiss = { showFilterDialog = false }
        )
    }

    if (showSortDialog) {
        SortDialog(
            currentSort = sortOption,
            onApply = { sort ->
                viewModel.applySorting(sort)
                showSortDialog = false
            },
            onDismiss = { showSortDialog = false }
        )
    }

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("YouTube Dashboard") },
                actions = {
                    TextButton(onClick = onLogoutClick) {
                        Text("Logout", color = MaterialTheme.colorScheme.onPrimary)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = MaterialTheme.colorScheme.onPrimary,
                    actionIconContentColor = MaterialTheme.colorScheme.onPrimary
                )
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
                Button(onClick = { viewModel.refresh() }) {
                    Text("Refresh")
                }
                Button(onClick = {
                    val intent = Intent(context, dev.elainedb.ytdash_android_gemini.MapActivity::class.java)
                    context.startActivity(intent)
                }) {
                    Text("View Map")
                }
                Button(onClick = { showFilterDialog = true }) {
                    Text("Filter")
                }
                Button(onClick = { showSortDialog = true }) {
                    Text("Sort")
                }
            }

            if (uiState is VideoListUiState.Success) {
                val state = uiState as VideoListUiState.Success
                if (filterOptions.channelName != null || filterOptions.country != null) {
                    Text(
                        text = "Showing ${state.videos.size} of $totalVideoCount videos",
                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                        style = MaterialTheme.typography.bodyMedium
                    )
                }
            }

            Box(modifier = Modifier.fillMaxWidth().weight(1f)) {
                when (val state = uiState) {
                    is VideoListUiState.Loading -> {
                        CircularProgressIndicator(modifier = Modifier.align(Alignment.Center))
                    }
                    is VideoListUiState.Empty -> {
                        Text("No videos found", modifier = Modifier.align(Alignment.Center))
                    }
                    is VideoListUiState.Error -> {
                        Text("Error: ${state.message}", modifier = Modifier.align(Alignment.Center))
                    }
                    is VideoListUiState.Success -> {
                        VideoList(videos = state.videos)
                    }
                }
            }
        }
    }
}

@Composable
fun VideoList(videos: List<Video>) {
    LazyColumn(
        modifier = Modifier.fillMaxSize(),
        contentPadding = PaddingValues(16.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp)
    ) {
        items(videos) { video ->
            VideoItem(video = video)
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
                try {
                    context.startActivity(intent)
                } catch (e: ActivityNotFoundException) {
                    val browserIntent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=${video.id}"))
                    context.startActivity(browserIntent)
                }
            },
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column {
            AsyncImage(
                model = video.thumbnailUrl,
                contentDescription = "Thumbnail for ${video.title}",
                modifier = Modifier
                    .fillMaxWidth()
                    .aspectRatio(16f / 9f)
            )
            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = video.title,
                    style = MaterialTheme.typography.titleMedium,
                    maxLines = 2
                )
                Spacer(modifier = Modifier.height(8.dp))
                Text(
                    text = video.channelName,
                    style = MaterialTheme.typography.bodyMedium
                )
                Spacer(modifier = Modifier.height(4.dp))
                
                val formattedDate = video.publishedAt.substringBefore("T")
                Text(
                    text = "Published: $formattedDate",
                    style = MaterialTheme.typography.bodySmall
                )
                
                if (video.recordingDate != null) {
                    Text(
                        text = "Recorded: ${video.recordingDate.substringBefore("T")}",
                        style = MaterialTheme.typography.bodySmall
                    )
                }
                
                if (video.locationCity != null || video.locationCountry != null) {
                    val locationStr = listOfNotNull(video.locationCity, video.locationCountry).joinToString(", ")
                    val gpsStr = if (video.locationLatitude != null && video.locationLongitude != null) {
                        " (${video.locationLatitude}, ${video.locationLongitude})"
                    } else ""
                    Text(
                        text = "Location: $locationStr$gpsStr",
                        style = MaterialTheme.typography.bodySmall
                    )
                }
                
                if (video.tags.isNotEmpty()) {
                    Spacer(modifier = Modifier.height(8.dp))
                    FlowRow(
                        modifier = Modifier.fillMaxWidth(),
                        horizontalArrangement = Arrangement.spacedBy(4.dp),
                        verticalArrangement = Arrangement.spacedBy(4.dp)
                    ) {
                        video.tags.take(5).forEach { tag ->
                            Box(
                                modifier = Modifier
                                    .clip(RoundedCornerShape(8.dp))
                                    .background(MaterialTheme.colorScheme.secondaryContainer)
                                    .padding(horizontal = 8.dp, vertical = 4.dp)
                            ) {
                                Text(
                                    text = tag,
                                    style = MaterialTheme.typography.labelSmall,
                                    color = MaterialTheme.colorScheme.onSecondaryContainer
                                )
                            }
                        }
                    }
                }
            }
        }
    }
}
