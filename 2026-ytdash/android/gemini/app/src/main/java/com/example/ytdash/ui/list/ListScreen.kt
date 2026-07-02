package com.example.ytdash.ui.list

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.util.Log
import androidx.compose.foundation.Image
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.*
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.draw.clip
import androidx.compose.ui.graphics.Brush
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.graphics.asImageBitmap
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.testTagsAsResourceId
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.lifecycle.viewmodel.compose.viewModel
import com.example.ytdash.TestConfig
import com.example.ytdash.data.DefaultDataRepository
import com.example.ytdash.data.Video
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.launch
import kotlinx.coroutines.withContext

enum class ListPanel {
    NONE, FILTER, SORT
}

enum class SortOption(val displayName: String) {
    DEFAULT("Default Order"),
    DATE_DESC("Date — Newest"), // Ends with 'newest' to match (?i)date.*(desc|newest)
    DATE_ASC("Date — Oldest"),   // Ends with 'oldest' to match (?i)date.*(asc|oldest)
    TITLE_ASC("Title — A-Z"),
    TITLE_DESC("Title — Z-A")
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun ListScreen(
    authenticatedEmail: String,
    onNavigateToMap: () -> Unit,
    onLogout: () -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current.applicationContext
    val coroutineScope = rememberCoroutineScope()
    
    // Instantiate repository and VM manually to ensure applicationContext is supplied
    val repository = remember { DefaultDataRepository(context) }
    val videosState by repository.videos.collectAsState(initial = emptyList())

    var isRefreshing by remember { mutableStateOf(false) }
    var refreshError by remember { mutableStateOf<String?>(null) }
    var externalOpenError by remember { mutableStateOf<String?>(null) }
    var capturedUrl by remember { mutableStateOf<String?>(null) }

    // Sort & Filter state
    var activePanel by remember { mutableStateOf(ListPanel.NONE) }
    var selectedSortOption by remember { mutableStateOf(SortOption.DEFAULT) }
    var selectedCategoryFilter by remember { mutableStateOf<String?>(null) } // null = All

    // Trigger initial refresh
    LaunchedEffect(Unit) {
        isRefreshing = true
        val result = repository.refresh()
        if (result.isFailure) {
            refreshError = result.exceptionOrNull()?.message ?: "Unknown error"
        }
        isRefreshing = false
    }

    val handleRefresh = {
        coroutineScope.launch {
            isRefreshing = true
            refreshError = null
            val result = repository.refresh()
            if (result.isFailure) {
                refreshError = result.exceptionOrNull()?.message ?: "Refresh failed"
            }
            isRefreshing = false
        }
    }

    // Process list filtering and sorting
    val filteredAndSortedVideos = remember(videosState, selectedSortOption, selectedCategoryFilter) {
        var list = videosState

        // 1. Filter
        if (!selectedCategoryFilter.isNullOrEmpty()) {
            list = list.filter { it.category.equals(selectedCategoryFilter, ignoreCase = true) }
        }

        // 2. Sort
        when (selectedSortOption) {
            SortOption.DEFAULT -> { /* Keep original order */ }
            SortOption.DATE_DESC -> list = list.sortedByDescending { it.publishedAt }
            SortOption.DATE_ASC -> list = list.sortedBy { it.publishedAt }
            SortOption.TITLE_ASC -> list = list.sortedBy { it.title.lowercase() }
            SortOption.TITLE_DESC -> list = list.sortedByDescending { it.title.lowercase() }
        }

        list
    }

    // Get unique categories for filter options
    val availableCategories = remember(videosState) {
        videosState.map { it.category }.filter { it.isNotEmpty() }.distinct()
    }

    val handleVideoClick = { video: Video ->
        Log.d("ListScreen", "Tapped video: '${video.title}' with URL: ${video.youtubeUrl}")
        if (TestConfig.captureExternalLinks) {
            capturedUrl = video.youtubeUrl
            TestConfig.lastCapturedUrl = video.youtubeUrl
            Log.d("ListScreen", "Captured external URL: ${TestConfig.lastCapturedUrl}")
        } else {
            try {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(video.youtubeUrl)).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
                externalOpenError = null
            } catch (e: Exception) {
                Log.e("ListScreen", "Failed to launch external YouTube experience", e)
                externalOpenError = "Failed to open video in YouTube."
            }
        }
    }

    // Root node - MUST have screen_home and enable testTagsAsResourceId
    Scaffold(
        modifier = modifier
            .fillMaxSize()
            .testTag("screen_home")
            .semantics { testTagsAsResourceId = true },
        topBar = {
            TopAppBar(
                title = {
                    Row(
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                    ) {
                        Text(
                            text = "ytdash",
                            fontWeight = FontWeight.Bold,
                            fontSize = 20.sp,
                            color = Color.White
                        )
                        // MUST contain total loaded count - video_count
                        Surface(
                            shape = RoundedCornerShape(8.dp),
                            color = MaterialTheme.colorScheme.primary.copy(alpha = 0.2f),
                            modifier = Modifier.padding(horizontal = 4.dp)
                        ) {
                            Text(
                                text = "${filteredAndSortedVideos.size}",
                                modifier = Modifier
                                    .padding(horizontal = 8.dp, vertical = 4.dp)
                                    .testTag("video_count"),
                                fontSize = 14.sp,
                                fontWeight = FontWeight.Bold,
                                color = MaterialTheme.colorScheme.primary
                            )
                        }
                    }
                },
                actions = {
                    IconButton(
                        onClick = { activePanel = ListPanel.FILTER },
                        modifier = Modifier.testTag("filter_button")
                    ) {
                        Icon(imageVector = Icons.Default.FilterList, contentDescription = "Filter", tint = Color.White)
                    }
                    IconButton(
                        onClick = { activePanel = ListPanel.SORT },
                        modifier = Modifier.testTag("sort_button")
                    ) {
                        Icon(imageVector = Icons.Default.Sort, contentDescription = "Sort", tint = Color.White)
                    }
                    IconButton(
                        onClick = onNavigateToMap,
                        modifier = Modifier.testTag("map_nav_button")
                    ) {
                        Icon(imageVector = Icons.Default.Map, contentDescription = "Map View", tint = Color.White)
                    }
                    IconButton(
                        onClick = { handleRefresh() },
                        modifier = Modifier.testTag("refresh_control")
                    ) {
                        Icon(imageVector = Icons.Default.Refresh, contentDescription = "Refresh", tint = Color.White)
                    }
                    IconButton(
                        onClick = onLogout,
                        modifier = Modifier.testTag("logout_button")
                    ) {
                        Icon(imageVector = Icons.Default.ExitToApp, contentDescription = "Logout", tint = Color.White)
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(containerColor = Color(0xFF0F172A))
            )
        },
        containerColor = Color(0xFF0F172A)
    ) { innerPadding ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(innerPadding)
        ) {
            // Panels and Video List logic
            when (activePanel) {
                ListPanel.FILTER -> {
                    // Filter selection panel (replaces list to avoid E2E matching conflicts)
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(24.dp)
                            .background(Color(0xFF1E293B), RoundedCornerShape(16.dp))
                            .padding(24.dp),
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        Text(
                            text = "Filter by Category",
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                        Divider(color = Color.Gray.copy(alpha = 0.3f))

                        // "All" option
                        Row(
                            modifier = Modifier
                                .fillMaxWidth()
                                .clickable { selectedCategoryFilter = null }
                                .padding(vertical = 12.dp),
                            verticalAlignment = Alignment.CenterVertically
                        ) {
                            RadioButton(
                                selected = (selectedCategoryFilter == null),
                                onClick = { selectedCategoryFilter = null },
                                colors = RadioButtonDefaults.colors(selectedColor = MaterialTheme.colorScheme.primary)
                            )
                            Spacer(modifier = Modifier.width(12.dp))
                            Text(text = "All Categories", fontSize = 16.sp, color = Color.White)
                        }

                        // Category options from config
                        availableCategories.forEach { category ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clickable { selectedCategoryFilter = category }
                                    .padding(vertical = 12.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                RadioButton(
                                    selected = (selectedCategoryFilter == category),
                                    onClick = { selectedCategoryFilter = category },
                                    colors = RadioButtonDefaults.colors(selectedColor = MaterialTheme.colorScheme.primary)
                                )
                                Spacer(modifier = Modifier.width(12.dp))
                                // Must match the visible text regex (?i)${FILTER_LABEL}
                                Text(text = category, fontSize = 16.sp, color = Color.White)
                            }
                        }

                        Spacer(modifier = Modifier.weight(1f))

                        Button(
                            onClick = { activePanel = ListPanel.NONE },
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(50.dp)
                                .testTag("filter_apply_button"),
                            shape = RoundedCornerShape(12.dp)
                        ) {
                            Text(text = "Apply Filter", fontWeight = FontWeight.Bold)
                        }
                    }
                }
                ListPanel.SORT -> {
                    // Sort selection panel (replaces list to avoid E2E matching conflicts)
                    Column(
                        modifier = Modifier
                            .fillMaxSize()
                            .padding(24.dp)
                            .background(Color(0xFF1E293B), RoundedCornerShape(16.dp))
                            .padding(24.dp),
                        verticalArrangement = Arrangement.spacedBy(16.dp)
                    ) {
                        Text(
                            text = "Sort Videos",
                            fontSize = 20.sp,
                            fontWeight = FontWeight.Bold,
                            color = Color.White
                        )
                        Divider(color = Color.Gray.copy(alpha = 0.3f))

                        SortOption.values().forEach { option ->
                            Row(
                                modifier = Modifier
                                    .fillMaxWidth()
                                    .clickable { selectedSortOption = option }
                                    .padding(vertical = 12.dp),
                                verticalAlignment = Alignment.CenterVertically
                            ) {
                                RadioButton(
                                    selected = (selectedSortOption == option),
                                    onClick = { selectedSortOption = option },
                                    colors = RadioButtonDefaults.colors(selectedColor = MaterialTheme.colorScheme.primary)
                                )
                                Spacer(modifier = Modifier.width(12.dp))
                                // Must match the regex (?i)date.*(desc|newest) or others
                                Text(text = option.displayName, fontSize = 16.sp, color = Color.White)
                            }
                        }

                        Spacer(modifier = Modifier.weight(1f))

                        Button(
                            onClick = { activePanel = ListPanel.NONE },
                            modifier = Modifier
                                .fillMaxWidth()
                                .height(50.dp)
                                .testTag("sort_apply_button"),
                            shape = RoundedCornerShape(12.dp)
                        ) {
                            Text(text = "Apply Sort", fontWeight = FontWeight.Bold)
                        }
                    }
                }
                ListPanel.NONE -> {
                    // Main Video List - loading, empty or success list
                    if (isRefreshing && filteredAndSortedVideos.isEmpty()) {
                        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                            CircularProgressIndicator(modifier = Modifier.testTag("loading_indicator"))
                        }
                    } else if (refreshError != null && filteredAndSortedVideos.isEmpty()) {
                        // Blocking error screen if list is empty
                        Column(
                            modifier = Modifier
                                .fillMaxSize()
                                .padding(32.dp)
                                .testTag("error_view"),
                            horizontalAlignment = Alignment.CenterHorizontally,
                            verticalArrangement = Arrangement.Center
                        ) {
                            Icon(imageVector = Icons.Default.Error, contentDescription = "Error", tint = MaterialTheme.colorScheme.error, modifier = Modifier.size(64.dp))
                            Spacer(modifier = Modifier.height(16.dp))
                            Text(text = "Error Loading Dashboards", fontSize = 18.sp, fontWeight = FontWeight.Bold, color = Color.White)
                            Spacer(modifier = Modifier.height(8.dp))
                            Text(text = refreshError ?: "Failed to aggregate feeds.", color = Color.LightGray, textAlign = androidx.compose.ui.text.style.TextAlign.Center)
                            Spacer(modifier = Modifier.height(24.dp))
                            Button(onClick = { handleRefresh() }, modifier = Modifier.testTag("error_retry_button")) {
                                Text(text = "Retry Refresh")
                            }
                        }
                    } else if (filteredAndSortedVideos.isEmpty()) {
                        Box(modifier = Modifier.fillMaxSize(), contentAlignment = Alignment.Center) {
                            Text(text = "No videos available.", color = Color.LightGray, fontSize = 16.sp)
                        }
                    } else {
                        // Standard list displaying the videos
                        LazyColumn(
                            modifier = Modifier
                                .fillMaxSize()
                                .testTag("video_list"),
                            contentPadding = PaddingValues(horizontal = 8.dp, vertical = 4.dp),
                            verticalArrangement = Arrangement.spacedBy(6.dp)
                        ) {
                            items(filteredAndSortedVideos) { video ->
                                VideoRow(video = video, onClick = { handleVideoClick(video) })
                            }
                        }
                    }
                }
            }

            // Top Overlay for captured links - MANDATORY "external_open_url"
            if (capturedUrl != null) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .align(Alignment.BottomCenter)
                        .padding(16.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.primaryContainer)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Column(modifier = Modifier.weight(1f)) {
                            Text(text = "Test Link Captured", fontSize = 12.sp, fontWeight = FontWeight.Bold, color = MaterialTheme.colorScheme.onPrimaryContainer)
                            Text(
                                text = capturedUrl!!,
                                modifier = Modifier.testTag("external_open_url"),
                                fontSize = 14.sp,
                                color = MaterialTheme.colorScheme.onPrimaryContainer
                            )
                        }
                        IconButton(onClick = { capturedUrl = null }) {
                            Icon(imageVector = Icons.Default.Close, contentDescription = "Close", tint = MaterialTheme.colorScheme.onPrimaryContainer)
                        }
                    }
                }
            }

            // Overlay for external open failures - MANDATORY "external_open_error"
            if (externalOpenError != null) {
                Card(
                    modifier = Modifier
                        .fillMaxWidth()
                        .align(Alignment.BottomCenter)
                        .padding(16.dp),
                    shape = RoundedCornerShape(12.dp),
                    colors = CardDefaults.cardColors(containerColor = MaterialTheme.colorScheme.errorContainer)
                ) {
                    Row(
                        modifier = Modifier
                            .fillMaxWidth()
                            .padding(16.dp),
                        verticalAlignment = Alignment.CenterVertically,
                        horizontalArrangement = Arrangement.SpaceBetween
                    ) {
                        Text(
                            text = externalOpenError!!,
                            modifier = Modifier.testTag("external_open_error"),
                            fontSize = 14.sp,
                            color = MaterialTheme.colorScheme.onErrorContainer
                        )
                        IconButton(onClick = { externalOpenError = null }) {
                            Icon(imageVector = Icons.Default.Close, contentDescription = "Close", tint = MaterialTheme.colorScheme.onErrorContainer)
                        }
                    }
                }
            }
        }
    }
}

@Composable
fun VideoRow(
    video: Video,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() },
        shape = RoundedCornerShape(10.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
        elevation = CardDefaults.cardElevation(defaultElevation = 1.dp)
    ) {
        Row(
            modifier = Modifier
                .fillMaxWidth()
                .padding(6.dp),
            verticalAlignment = Alignment.CenterVertically
        ) {
            // Self-contained AsyncImage thumbnail
            AsyncImage(
                url = video.thumbnailUrl,
                modifier = Modifier
                    .size(width = 72.dp, height = 48.dp)
                    .clip(RoundedCornerShape(4.dp))
            )

            Spacer(modifier = Modifier.width(10.dp))

            Column(
                modifier = Modifier.weight(1f),
                verticalArrangement = Arrangement.spacedBy(2.dp)
            ) {
                // Compose-only: put the list-item id on the title Text directly (crucial for Maestro checks!)
                Text(
                    text = video.title,
                    modifier = Modifier.testTag("video_list_item"),
                    fontSize = 13.sp,
                    fontWeight = FontWeight.Bold,
                    color = Color.White,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                Text(
                    text = video.description,
                    fontSize = 11.sp,
                    color = Color.LightGray,
                    maxLines = 1,
                    overflow = TextOverflow.Ellipsis
                )

                Row(
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween,
                    modifier = Modifier.fillMaxWidth().padding(top = 1.dp)
                ) {
                    Text(
                        text = video.category,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.SemiBold,
                        color = MaterialTheme.colorScheme.primary,
                        modifier = Modifier
                            .background(MaterialTheme.colorScheme.primary.copy(alpha = 0.15f), RoundedCornerShape(4.dp))
                            .padding(horizontal = 4.dp, vertical = 1.dp)
                    )
                    
                    if (video.location != null) {
                        Icon(
                            imageVector = Icons.Default.LocationOn,
                            contentDescription = "Geolocated",
                            tint = Color(0xFF34D399), // Green 400
                            modifier = Modifier.size(12.dp)
                        )
                    }
                }
            }
        }
    }
}

@Composable
fun AsyncImage(
    url: String,
    modifier: Modifier = Modifier
) {
    var bitmap by remember { mutableStateOf<androidx.compose.ui.graphics.ImageBitmap?>(null) }

    LaunchedEffect(url) {
        if (url.isNotEmpty()) {
            withContext(Dispatchers.IO) {
                try {
                    val connection = java.net.URL(url).openConnection() as java.net.HttpURLConnection
                    connection.connectTimeout = 4000
                    connection.readTimeout = 4000
                    connection.doInput = true
                    connection.connect()
                    val input = connection.inputStream
                    val bmp = android.graphics.BitmapFactory.decodeStream(input)
                    if (bmp != null) {
                        bitmap = bmp.asImageBitmap()
                    }
                } catch (e: Exception) {
                    Log.e("AsyncImage", "Error loading thumbnail: $url", e)
                }
            }
        }
    }

    val currentBitmap = bitmap
    if (currentBitmap != null) {
        Image(
            bitmap = currentBitmap,
            contentDescription = "Thumbnail",
            modifier = modifier,
            contentScale = ContentScale.Crop
        )
    } else {
        Box(
            modifier = modifier.background(
                Brush.linearGradient(
                    colors = listOf(Color(0xFF334155), Color(0xFF1E293B))
                )
            ),
            contentAlignment = Alignment.Center
        ) {
            Icon(
                imageVector = Icons.Default.PlayArrow,
                contentDescription = "Loading",
                tint = Color.LightGray.copy(alpha = 0.5f),
                modifier = Modifier.size(24.dp)
            )
        }
    }
}
