package dev.elainedb.android_gemini.presentation.main

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
import androidx.compose.ui.unit.dp
import org.koin.androidx.compose.koinViewModel
import coil.compose.AsyncImage
import dev.elainedb.android_gemini.domain.youtube.YoutubeVideo
import dev.elainedb.android_gemini.presentation.main.MainViewModel
import dev.elainedb.android_gemini.presentation.main.SortOrder

@Composable
fun MainScreen(
    mainViewModel: MainViewModel = koinViewModel(),
    onLogout: () -> Unit,
    onNavigateToMap: () -> Unit
) {
    val uiState by mainViewModel.uiState.collectAsState()
    val context = LocalContext.current

    var showSortDialog by remember { mutableStateOf(false) }
    var showFilterDialog by remember { mutableStateOf(false) }

    LaunchedEffect(Unit) {
        mainViewModel.getVideos()
    }

    Scaffold(
        topBar = {
            Column(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(16.dp),
                horizontalAlignment = Alignment.CenterHorizontally
            ) {
                val videoCount = when (val state = uiState) {
                    is MainUiState.Success -> state.videos.size
                    else -> 0
                }
                Text(text = "Videos: $videoCount")
                Spacer(modifier = Modifier.height(8.dp))
                Row(
                    modifier = Modifier.fillMaxWidth(),
                    horizontalArrangement = Arrangement.SpaceEvenly
                ) {
                    Button(onClick = { mainViewModel.refreshVideos() }) {
                        Text("Refresh")
                    }
                    Button(onClick = { showFilterDialog = true }) {
                        Text("Filter")
                    }
                    Button(onClick = { showSortDialog = true }) {
                        Text("Sort")
                    }
                    Button(onClick = onNavigateToMap) {
                        Text("View Map")
                    }
                }
            }
        },
        bottomBar = {
            Row(
                modifier = Modifier
                    .fillMaxWidth()
                    .padding(bottom = 16.dp),
                horizontalArrangement = Arrangement.Center
            ) {
                Button(onClick = onLogout) {
                    Text("Logout")
                }
            }
        }
    ) { paddingValues ->
        Column(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
        ) {
            when (val state = uiState) {
                is MainUiState.Loading -> {
                    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        CircularProgressIndicator()
                    }
                }
                is MainUiState.Success -> {
                    LazyColumn(modifier = Modifier.fillMaxSize()) {
                        items(state.videos) { video ->
                            VideoItem(video = video, onClick = {
                                val intent = Intent(Intent.ACTION_VIEW, Uri.parse("https://www.youtube.com/watch?v=${video.videoId}"))
                                context.startActivity(intent)
                            })
                        }
                    }
                }
                is MainUiState.Error -> {
                    Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                        Text(text = state.message)
                    }
                }
            }
        }
    }

    if (showSortDialog) {
        SortDialog(
            onDismiss = { showSortDialog = false },
            onSortSelected = { sortOrder ->
                mainViewModel.setSortOrder(sortOrder)
                showSortDialog = false
            }
        )
    }

    if (showFilterDialog) {
        val state = uiState
        if (state is MainUiState.Success) {
            FilterDialog(
                channels = state.channels,
                countries = state.countries,
                onDismiss = { showFilterDialog = false },
                onFilterSelected = { channel, country ->
                    mainViewModel.setFilter(channel, country)
                    showFilterDialog = false
                }
            )
        }
    }
}

@Composable
fun VideoItem(video: YoutubeVideo, onClick: () -> Unit) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(16.dp)
    ) {
        AsyncImage(
            model = video.thumbnailUrl,
            contentDescription = null,
            modifier = Modifier.size(120.dp, 90.dp),
            contentScale = ContentScale.Crop
        )
        Spacer(modifier = Modifier.width(16.dp))
        Column {
            Text(text = video.title)
            Text(text = video.channelTitle)
            Text(text = video.publishedAt.substring(0, 10))
            video.tags?.let { Text(text = "Tags: ${it.joinToString()}") }
            video.country?.let { Text(text = "Country: $it") }
            video.city?.let { Text(text = "City: $it") }
            video.recordingDate?.let { Text(text = "Recorded: ${it.substring(0, 10)}") }
        }
    }
}

@Composable
fun SortDialog(onDismiss: () -> Unit, onSortSelected: (SortOrder) -> Unit) {
    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(text = "Sort by") },
        text = {
            Column {
                Text("Publication Date (Newest to Oldest)", modifier = Modifier.clickable { onSortSelected(SortOrder.PUBLICATION_DATE_DESC) })
                Text("Publication Date (Oldest to Newest)", modifier = Modifier.clickable { onSortSelected(SortOrder.PUBLICATION_DATE_ASC) })
                Text("Recording Date (Newest to Oldest)", modifier = Modifier.clickable { onSortSelected(SortOrder.RECORDING_DATE_DESC) })
                Text("Recording Date (Oldest to Newest)", modifier = Modifier.clickable { onSortSelected(SortOrder.RECORDING_DATE_ASC) })
            }
        },
        confirmButton = {
            Button(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun FilterDialog(
    channels: List<String>,
    countries: List<String>,
    onDismiss: () -> Unit,
    onFilterSelected: (String?, String?) -> Unit
) {
    var selectedChannel by remember { mutableStateOf<String?>(null) }
    var selectedCountry by remember { mutableStateOf<String?>(null) }
    var expandedChannel by remember { mutableStateOf(false) }
    var expandedCountry by remember { mutableStateOf(false) }

    AlertDialog(
        onDismissRequest = onDismiss,
        title = { Text(text = "Filter by") },
        text = {
            Column {
                ExposedDropdownMenuBox(
                    expanded = expandedChannel,
                    onExpandedChange = { expandedChannel = !expandedChannel }
                ) {
                    TextField(
                        value = selectedChannel ?: "",
                        onValueChange = {},
                        readOnly = true,
                        label = { Text("Channel") },
                        trailingIcon = {
                            ExposedDropdownMenuDefaults.TrailingIcon(expanded = expandedChannel)
                        },
                        modifier = Modifier.menuAnchor()
                    )
                    ExposedDropdownMenu(
                        expanded = expandedChannel,
                        onDismissRequest = { expandedChannel = false }
                    ) {
                        channels.forEach { channel ->
                            DropdownMenuItem(
                                text = { Text(channel) },
                                onClick = {
                                    selectedChannel = channel
                                    expandedChannel = false
                                }
                            )
                        }
                    }
                }
                Spacer(modifier = Modifier.height(16.dp))
                ExposedDropdownMenuBox(
                    expanded = expandedCountry,
                    onExpandedChange = { expandedCountry = !expandedCountry }
                ) {
                    TextField(
                        value = selectedCountry ?: "",
                        onValueChange = {},
                        readOnly = true,
                        label = { Text("Country") },
                        trailingIcon = {
                            ExposedDropdownMenuDefaults.TrailingIcon(expanded = expandedCountry)
                        },
                        modifier = Modifier.menuAnchor()
                    )
                    ExposedDropdownMenu(
                        expanded = expandedCountry,
                        onDismissRequest = { expandedCountry = false }
                    ) {
                        countries.forEach { country ->
                            DropdownMenuItem(
                                text = { Text(country) },
                                onClick = {
                                    selectedCountry = country
                                    expandedCountry = false
                                }
                            )
                        }
                    }
                }
            }
        },
        confirmButton = {
            Button(onClick = { onFilterSelected(selectedChannel, selectedCountry) }) {
                Text("Apply")
            }
        },
        dismissButton = {
            Button(onClick = onDismiss) {
                Text("Cancel")
            }
        }
    )
}
