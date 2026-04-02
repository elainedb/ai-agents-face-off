package dev.elainedb.ytdash_android_gemini.ui

import android.content.Intent
import android.net.Uri
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.FilterList
import androidx.compose.material.icons.filled.Map
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material.icons.filled.Sort
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import coil.compose.AsyncImage
import dev.elainedb.ytdash_android_gemini.MapActivity
import dev.elainedb.ytdash_android_gemini.model.Video
import dev.elainedb.ytdash_android_gemini.viewmodel.SortOption
import dev.elainedb.ytdash_android_gemini.viewmodel.VideoListUiState
import dev.elainedb.ytdash_android_gemini.viewmodel.VideoListViewModel

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun VideoListScreen(viewModel: VideoListViewModel, onLogout: () -> Unit) {
    val uiState by viewModel.uiState.collectAsState()
    val filterOptions by viewModel.filterOptions.collectAsState()
    val sortOption by viewModel.sortOption.collectAsState()
    val totalCount by viewModel.totalVideoCount.collectAsState()
    val availableChannels by viewModel.availableChannels.collectAsState()
    val availableCountries by viewModel.availableCountries.collectAsState()

    var showFilterDialog by remember { mutableStateOf(false) }
    var showSortDialog by remember { mutableStateOf(false) }

    val context = LocalContext.current

    Scaffold(
        topBar = {
            TopAppBar(
                title = { Text("YouTube Video List") },
                actions = {
                    TextButton(onClick = onLogout) {
                        Text("Logout", color = Color.White)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = MaterialTheme.colorScheme.primary,
                    titleContentColor = Color.White
                )
            )
        }
    ) { innerPadding ->
        Column(modifier = Modifier.padding(innerPadding)) {
            ControlButtons(
                onRefresh = { viewModel.refreshVideos() },
                onViewMap = {
                    context.startActivity(Intent(context, MapActivity::class.java))
                },
                onFilter = { showFilterDialog = true },
                onSort = { showSortDialog = true }
            )

            if (filterOptions.channelName != "All Channels" || filterOptions.country != "All Countries") {
                val currentCount = (uiState as? VideoListUiState.Success)?.videos?.size ?: 0
                Text(
                    text = "Showing $currentCount of $totalCount videos",
                    modifier = Modifier.padding(horizontal = 16.dp, vertical = 8.dp),
                    style = MaterialTheme.typography.bodySmall
                )
                TextButton(onClick = { viewModel.clearFilters() }, modifier = Modifier.padding(horizontal = 8.dp)) {
                    Text("Clear Filters")
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
                is VideoListUiState.Success -> {
                    VideoList(state.videos)
                }
                is VideoListUiState.Error -> {
                    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Text("Error: ${state.message}", color = Color.Red)
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
            onApply = { option ->
                viewModel.applySorting(option)
                showSortDialog = false
            },
            onDismiss = { showSortDialog = false }
        )
    }
}

@Composable
fun ControlButtons(
    onRefresh: () -> Unit,
    onViewMap: () -> Unit,
    onFilter: () -> Unit,
    onSort: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .padding(8.dp),
        horizontalArrangement = Arrangement.SpaceEvenly
    ) {
        IconButtonWithLabel(icon = Icons.Default.Refresh, label = "Refresh", onClick = onRefresh)
        IconButtonWithLabel(icon = Icons.Default.Map, label = "Map", onClick = onViewMap)
        IconButtonWithLabel(icon = Icons.Default.FilterList, label = "Filter", onClick = onFilter)
        IconButtonWithLabel(icon = Icons.Default.Sort, label = "Sort", onClick = onSort)
    }
}

@Composable
fun IconButtonWithLabel(icon: androidx.compose.ui.graphics.vector.ImageVector, label: String, onClick: () -> Unit) {
    Column(horizontalAlignment = Alignment.CenterHorizontally) {
        IconButton(onClick = onClick) {
            Icon(icon, contentDescription = label)
        }
        Text(label, style = MaterialTheme.typography.labelSmall)
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
            VideoItem(video)
        }
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
                if (intent.resolveActivity(context.packageManager) == null) {
                    context.startActivity(Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=${video.id}")))
                } else {
                    context.startActivity(intent)
                }
            },
        elevation = CardDefaults.cardElevation(defaultElevation = 4.dp)
    ) {
        Column {
            AsyncImage(
                model = video.thumbnailUrl,
                contentDescription = null,
                modifier = Modifier
                    .fillMaxWidth()
                    .height(200.dp),
                contentScale = ContentScale.Crop
            )
            Column(modifier = Modifier.padding(12.dp)) {
                Text(text = video.title, fontWeight = FontWeight.Bold, fontSize = 18.sp)
                Text(text = video.channelName, style = MaterialTheme.typography.bodyMedium, color = Color.Gray)
                Text(text = video.publishedAt.take(10), style = MaterialTheme.typography.bodySmall)
                
                if (video.tags.isNotEmpty()) {
                    Spacer(modifier = Modifier.height(8.dp))
                    FlowRow(mainAxisSpacing = 4.dp, crossAxisSpacing = 4.dp) {
                        video.tags.take(5).forEach { tag ->
                            SuggestionChip(onClick = {}, label = { Text(tag) })
                        }
                    }
                }

                if (video.locationCity != null || video.locationCountry != null) {
                    Spacer(modifier = Modifier.height(8.dp))
                    Text(
                        text = "📍 ${listOfNotNull(video.locationCity, video.locationCountry).joinToString(", ")}",
                        style = MaterialTheme.typography.bodySmall
                    )
                }
                
                if (video.recordingDate != null) {
                    Text(
                        text = "🎥 Recorded: ${video.recordingDate.take(10)}",
                        style = MaterialTheme.typography.bodySmall
                    )
                }
            }
        }
    }
}

@Composable
fun FlowRow(
    mainAxisSpacing: androidx.compose.ui.unit.Dp,
    crossAxisSpacing: androidx.compose.ui.unit.Dp,
    content: @Composable () -> Unit
) {
    androidx.compose.ui.layout.Layout(content = content) { measurables, constraints ->
        val placeables = measurables.map { it.measure(constraints) }
        var xPosition = 0
        var yPosition = 0
        var rowHeight = 0
        
        placeables.forEach { placeable ->
            if (xPosition + placeable.width > constraints.maxWidth && xPosition != 0) {
                xPosition = 0
                yPosition += rowHeight + crossAxisSpacing.roundToPx()
                rowHeight = 0
            }
            xPosition += placeable.width + mainAxisSpacing.roundToPx()
            rowHeight = maxOf(rowHeight, placeable.height)
        }
        
        val totalHeight = if (placeables.isEmpty()) 0 else yPosition + rowHeight

        layout(constraints.maxWidth, totalHeight) {
            var currentX = 0
            var currentY = 0
            var currentRowHeight = 0
            
            placeables.forEach { placeable ->
                if (currentX + placeable.width > constraints.maxWidth && currentX != 0) {
                    currentX = 0
                    currentY += currentRowHeight + crossAxisSpacing.roundToPx()
                    currentRowHeight = 0
                }
                placeable.placeRelative(currentX, currentY)
                currentX += placeable.width + mainAxisSpacing.roundToPx()
                currentRowHeight = maxOf(currentRowHeight, placeable.height)
            }
        }
    }
}
