package com.example.ytdash.ui.main

import android.content.Context
import android.content.Intent
import android.net.Uri
import android.widget.Toast
import androidx.compose.animation.*
import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.lazy.LazyColumn
import androidx.compose.foundation.lazy.LazyRow
import androidx.compose.foundation.lazy.items
import androidx.compose.foundation.lazy.itemsIndexed
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
import androidx.compose.ui.layout.ContentScale
import androidx.compose.ui.platform.LocalContext
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.testTagsAsResourceId
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.text.style.TextOverflow
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import androidx.compose.ui.viewinterop.AndroidView
import androidx.lifecycle.compose.collectAsStateWithLifecycle
import androidx.lifecycle.viewmodel.compose.viewModel
import coil.compose.AsyncImage
import com.example.ytdash.AuthManager
import com.example.ytdash.TestConfig
import com.example.ytdash.data.DefaultDataRepository
import com.example.ytdash.data.Video
import org.osmdroid.config.Configuration
import org.osmdroid.tileprovider.tilesource.TileSourceFactory
import org.osmdroid.util.GeoPoint
import org.osmdroid.views.MapView
import org.osmdroid.views.overlay.Marker

enum class MainTab {
    List, Map
}

enum class ActivePanel {
    None, Filter, Sort
}

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun MainScreen(
    onLogout: () -> Unit,
    modifier: Modifier = Modifier,
    viewModel: MainScreenViewModel = viewModel(
        factory = MainScreenViewModelFactory(LocalContext.current.applicationContext)
    )
) {
    val state by viewModel.uiState.collectAsStateWithLifecycle()
    val context = LocalContext.current

    var currentTab by remember { mutableStateOf(MainTab.List) }
    var activePanel by remember { mutableStateOf(ActivePanel.None) }
    var capturedUrl by remember { mutableStateOf<String?>(null) }
    var externalOpenError by remember { mutableStateOf<String?>(null) }
    var selectedVideoForMap by remember { mutableStateOf<Video?>(null) }

    // Helper to perform the video launching logic cleanly
    val onVideoClick: (Video) -> Unit = { video ->
        val videoUrl = video.youtubeUrl
        if (TestConfig.captureExternalLinks) {
            capturedUrl = videoUrl
            externalOpenError = null
        } else {
            // Real launch
            try {
                val intent = Intent(Intent.ACTION_VIEW, Uri.parse(videoUrl)).apply {
                    addFlags(Intent.FLAG_ACTIVITY_NEW_TASK)
                }
                context.startActivity(intent)
                externalOpenError = null
            } catch (e: Exception) {
                externalOpenError = "Failed to launch YouTube for: ${video.title}"
            }
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .testTag("screen_home")
            .semantics { testTagsAsResourceId = true }
    ) {
        Column(modifier = Modifier.fillMaxSize()) {
            // Main Content depending on state
            when (val uiState = state) {
                MainScreenUiState.Loading -> {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(Color(0xFF0F172A)),
                        contentAlignment = Alignment.Center
                    ) {
                        CircularProgressIndicator(
                            modifier = Modifier.testTag("loading_indicator"),
                            color = Color(0xFFEF4444)
                        )
                    }
                }
                is MainScreenUiState.Error -> {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .testTag("error_view")
                            .background(Color(0xFF0F172A))
                            .padding(32.dp),
                        contentAlignment = Alignment.Center
                    ) {
                        Card(
                            colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
                            shape = RoundedCornerShape(16.dp)
                        ) {
                            Column(
                                modifier = Modifier.padding(24.dp),
                                horizontalAlignment = Alignment.CenterHorizontally
                            ) {
                                Icon(Icons.Default.Warning, contentDescription = "Error", tint = Color(0xFFEF4444), modifier = Modifier.size(48.dp))
                                Spacer(modifier = Modifier.height(16.dp))
                                Text(
                                    text = "Error Loading Data",
                                    color = Color.White,
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.Bold
                                )
                                Spacer(modifier = Modifier.height(8.dp))
                                Text(
                                    text = uiState.message,
                                    color = Color(0xFF94A3B8),
                                    fontSize = 14.sp,
                                    modifier = Modifier.padding(bottom = 16.dp)
                                )
                                Button(
                                    onClick = { viewModel.refresh() },
                                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFEF4444)),
                                    modifier = Modifier.testTag("error_retry_button")
                                ) {
                                    Text("Retry", color = Color.White)
                                }
                            }
                        }
                    }
                }
                MainScreenUiState.Empty -> {
                    Box(
                        modifier = Modifier
                            .fillMaxSize()
                            .background(Color(0xFF0F172A)),
                        contentAlignment = Alignment.Center
                    ) {
                        Text("No videos found.", color = Color.White, fontSize = 16.sp)
                    }
                }
                is MainScreenUiState.Success -> {
                    // Top Bar
                    TopAppBar(
                        title = {
                            Column {
                                Text(
                                    text = "YT Dashboard",
                                    fontSize = 18.sp,
                                    fontWeight = FontWeight.ExtraBold,
                                    color = Color.White
                                )
                                Text(
                                    text = "${uiState.videos.size} videos",
                                    fontSize = 12.sp,
                                    color = Color(0xFF94A3B8),
                                    modifier = Modifier.testTag("video_count")
                                )
                            }
                        },
                        actions = {
                            IconButton(
                                onClick = { viewModel.refresh() },
                                modifier = Modifier.testTag("refresh_control")
                            ) {
                                Icon(Icons.Default.Refresh, contentDescription = "Refresh", tint = Color.White)
                            }
                            IconButton(
                                onClick = {
                                    AuthManager.logout(context)
                                    onLogout()
                                },
                                modifier = Modifier.testTag("logout_button")
                            ) {
                                Icon(Icons.Default.ExitToApp, contentDescription = "Logout", tint = Color.White)
                            }
                        },
                        colors = TopAppBarDefaults.topAppBarColors(
                            containerColor = Color(0xFF1E293B)
                        )
                    )

                    // Content View: List or Map Tab
                    Box(
                        modifier = Modifier
                            .weight(1f)
                            .fillMaxWidth()
                            .background(Color(0xFF0F172A))
                    ) {
                        if (currentTab == MainTab.List) {
                            // List View
                            Column(modifier = Modifier.fillMaxSize()) {
                                // Filter & Sort selection header
                                Row(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .background(Color(0xFF1E293B))
                                        .padding(horizontal = 16.dp, vertical = 8.dp),
                                    horizontalArrangement = Arrangement.spacedBy(12.dp)
                                ) {
                                    Button(
                                        onClick = { activePanel = ActivePanel.Filter },
                                        colors = ButtonDefaults.buttonColors(
                                            containerColor = if (uiState.selectedFilter != null) Color(0xFFEF4444) else Color(0xFF334155)
                                        ),
                                        shape = RoundedCornerShape(12.dp),
                                        modifier = Modifier.testTag("filter_button")
                                    ) {
                                        Icon(Icons.Default.List, contentDescription = "Filter", modifier = Modifier.size(18.dp))
                                        Spacer(modifier = Modifier.width(6.dp))
                                        Text(uiState.selectedFilter ?: "Filter", fontSize = 13.sp)
                                    }

                                    Button(
                                        onClick = { activePanel = ActivePanel.Sort },
                                        colors = ButtonDefaults.buttonColors(containerColor = Color(0xFF334155)),
                                        shape = RoundedCornerShape(12.dp),
                                        modifier = Modifier.testTag("sort_button")
                                    ) {
                                        Icon(Icons.Default.Menu, contentDescription = "Sort", modifier = Modifier.size(18.dp))
                                        Spacer(modifier = Modifier.width(6.dp))
                                        Text(
                                            when (uiState.currentSort) {
                                                SortOption.DEFAULT -> "Sort"
                                                SortOption.DATE_DESC -> "Date — newest"
                                                SortOption.DATE_ASC -> "Date — oldest"
                                                SortOption.TITLE_ASC -> "Title — asc"
                                                SortOption.TITLE_DESC -> "Title — desc"
                                            },
                                            fontSize = 13.sp
                                        )
                                    }
                                }

                                // If panels are open, we REPLACE the list to avoid collisions
                                if (activePanel == ActivePanel.Filter) {
                                    FilterOptionsPanel(
                                        categories = uiState.allCategories,
                                        selected = uiState.selectedFilter,
                                        onSelect = { viewModel.setFilter(it) },
                                        onClose = { activePanel = ActivePanel.None }
                                    )
                                } else if (activePanel == ActivePanel.Sort) {
                                    SortOptionsPanel(
                                        currentSort = uiState.currentSort,
                                        onSelect = { viewModel.setSortOption(it) },
                                        onClose = { activePanel = ActivePanel.None }
                                    )
                                } else {
                                    // Lazy video list
                                    LazyColumn(
                                        modifier = Modifier
                                            .fillMaxSize()
                                            .testTag("video_list"),
                                        contentPadding = PaddingValues(16.dp),
                                        verticalArrangement = Arrangement.spacedBy(16.dp)
                                    ) {
                                        items(uiState.videos) { video ->
                                            VideoRowItem(
                                                video = video,
                                                onClick = { onVideoClick(video) }
                                            )
                                        }
                                    }
                                }
                            }
                        } else {
                            // Map View
                            Box(
                                modifier = Modifier
                                    .fillMaxSize()
                                    .testTag("screen_map")
                            ) {
                                val locatedVideos = uiState.videos.filter { it.lat != null && it.lng != null }

                                // OSM Map View
                                OsmMapView(
                                    videos = uiState.videos,
                                    selectedVideo = selectedVideoForMap,
                                    onVideoSelected = { selectedVideoForMap = it },
                                    modifier = Modifier.fillMaxSize()
                                )

                                // Horizontal Row of Accessible Chips for coordinate-less E2E tapping
                                Column(
                                    modifier = Modifier
                                        .fillMaxWidth()
                                        .align(Alignment.TopCenter)
                                        .background(Color(0xFF0F172A).copy(alpha = 0.85f))
                                        .padding(vertical = 10.dp)
                                ) {
                                    Text(
                                        text = "Located Markers:",
                                        color = Color.White,
                                        fontSize = 12.sp,
                                        fontWeight = FontWeight.Bold,
                                        modifier = Modifier.padding(horizontal = 16.dp, vertical = 2.dp)
                                    )
                                    LazyRow(
                                        modifier = Modifier.fillMaxWidth(),
                                        contentPadding = PaddingValues(horizontal = 16.dp),
                                        horizontalArrangement = Arrangement.spacedBy(8.dp)
                                    ) {
                                        itemsIndexed(locatedVideos) { idx, video ->
                                            AssistChip(
                                                onClick = { selectedVideoForMap = video },
                                                label = {
                                                    Text(
                                                        text = video.title,
                                                        maxLines = 1,
                                                        overflow = TextOverflow.Ellipsis,
                                                        fontSize = 12.sp,
                                                        color = if (selectedVideoForMap?.id == video.id) Color.White else Color(0xFFEF4444)
                                                    )
                                                },
                                                colors = AssistChipDefaults.assistChipColors(
                                                    containerColor = if (selectedVideoForMap?.id == video.id) Color(0xFFEF4444) else Color(0xFF1E293B)
                                                ),
                                                border = null,
                                                modifier = Modifier.testTag("map_marker")
                                            )
                                        }
                                    }
                                }

                                // Interactive Inline Details Bottom Sheet
                                androidx.compose.animation.AnimatedVisibility(
                                    visible = selectedVideoForMap != null,
                                    enter = slideInVertically(initialOffsetY = { it }) + fadeIn(),
                                    exit = slideOutVertically(targetOffsetY = { it }) + fadeOut(),
                                    modifier = Modifier
                                        .align(Alignment.BottomCenter)
                                        .fillMaxWidth()
                                        .padding(16.dp)
                                ) {
                                    selectedVideoForMap?.let { video ->
                                        Card(
                                            modifier = Modifier
                                                .fillMaxWidth()
                                                .testTag("detail_bottom_sheet"),
                                            shape = RoundedCornerShape(20.dp),
                                            colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
                                            elevation = CardDefaults.cardElevation(defaultElevation = 12.dp)
                                        ) {
                                            Column(modifier = Modifier.padding(20.dp)) {
                                                Row(
                                                    modifier = Modifier.fillMaxWidth(),
                                                    horizontalArrangement = Arrangement.SpaceBetween,
                                                    verticalAlignment = Alignment.Top
                                                ) {
                                                    Text(
                                                        text = video.title,
                                                        color = Color.White,
                                                        fontSize = 16.sp,
                                                        fontWeight = FontWeight.Bold,
                                                        modifier = Modifier.weight(1f),
                                                        maxLines = 2,
                                                        overflow = TextOverflow.Ellipsis
                                                    )
                                                    IconButton(
                                                        onClick = { selectedVideoForMap = null },
                                                        modifier = Modifier.size(24.dp)
                                                    ) {
                                                        Icon(Icons.Default.Close, contentDescription = "Close", tint = Color(0xFF94A3B8))
                                                    }
                                                }

                                                Spacer(modifier = Modifier.height(6.dp))

                                                Text(
                                                    text = video.category.uppercase(),
                                                    color = Color(0xFFEF4444),
                                                    fontSize = 11.sp,
                                                    fontWeight = FontWeight.ExtraBold
                                                )

                                                Spacer(modifier = Modifier.height(10.dp))

                                                Text(
                                                    text = video.description,
                                                    color = Color(0xFF94A3B8),
                                                    fontSize = 13.sp,
                                                    maxLines = 3,
                                                    overflow = TextOverflow.Ellipsis,
                                                    lineHeight = 18.sp
                                                )

                                                Spacer(modifier = Modifier.height(12.dp))

                                                // Exact text watch URL
                                                Text(
                                                    text = video.youtubeUrl,
                                                    color = Color(0xFFEF4444),
                                                    fontSize = 12.sp,
                                                    fontWeight = FontWeight.SemiBold,
                                                    modifier = Modifier
                                                        .fillMaxWidth()
                                                        .testTag("detail_video_url")
                                                )

                                                Spacer(modifier = Modifier.height(16.dp))

                                                Button(
                                                    onClick = { onVideoClick(video) },
                                                    modifier = Modifier
                                                        .fillMaxWidth()
                                                        .height(48.dp)
                                                        .testTag("detail_open_youtube_button"),
                                                    colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFEF4444)),
                                                    shape = RoundedCornerShape(12.dp)
                                                ) {
                                                    Icon(Icons.Default.PlayArrow, contentDescription = "Open")
                                                    Spacer(modifier = Modifier.width(8.dp))
                                                    Text("Open in YouTube", fontWeight = FontWeight.Bold)
                                                }
                                            }
                                        }
                                    }
                                }
                            }
                        }
                    }

                    // Bottom Navigation Bar
                    NavigationBar(
                        containerColor = Color(0xFF1E293B)
                    ) {
                        NavigationBarItem(
                            selected = currentTab == MainTab.List,
                            onClick = { currentTab = MainTab.List },
                            icon = { Icon(Icons.Default.Home, contentDescription = "Home") },
                            label = { Text("Videos") },
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = Color.White,
                                selectedTextColor = Color.White,
                                indicatorColor = Color(0xFFEF4444),
                                unselectedIconColor = Color(0xFF94A3B8),
                                unselectedTextColor = Color(0xFF94A3B8)
                            )
                        )

                        NavigationBarItem(
                            selected = currentTab == MainTab.Map,
                            onClick = { currentTab = MainTab.Map },
                            icon = { Icon(Icons.Default.Place, contentDescription = "Map") },
                            label = { Text("Map") },
                            modifier = Modifier.testTag("map_nav_button"),
                            colors = NavigationBarItemDefaults.colors(
                                selectedIconColor = Color.White,
                                selectedTextColor = Color.White,
                                indicatorColor = Color(0xFFEF4444),
                                unselectedIconColor = Color(0xFF94A3B8),
                                unselectedTextColor = Color(0xFF94A3B8)
                            )
                        )
                    }
                }
            }
        }

        // 1. Root Level Overlay for captured links (AC-LIST-03, AC-MAP-03)
        AnimatedVisibility(
            visible = capturedUrl != null,
            enter = slideInVertically(initialOffsetY = { -it }) + fadeIn(),
            exit = slideOutVertically(targetOffsetY = { -it }) + fadeOut(),
            modifier = Modifier
                .align(Alignment.TopCenter)
                .fillMaxWidth()
                .padding(16.dp)
                .safeDrawingPadding()
        ) {
            Card(
                colors = CardDefaults.cardColors(containerColor = Color(0xFF10B981)), // Emerald 500
                shape = RoundedCornerShape(16.dp),
                elevation = CardDefaults.cardElevation(defaultElevation = 8.dp)
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Column(modifier = Modifier.weight(1f)) {
                        Text("Captured Video Link Launch:", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 12.sp)
                        Spacer(modifier = Modifier.height(4.dp))
                        Text(
                            text = capturedUrl ?: "",
                            color = Color.White,
                            fontSize = 14.sp,
                            fontWeight = FontWeight.ExtraBold,
                            modifier = Modifier.testTag("external_open_url")
                        )
                    }
                    IconButton(onClick = { capturedUrl = null }) {
                        Icon(Icons.Default.Close, contentDescription = "Dismiss", tint = Color.White)
                    }
                }
            }
        }

        // 2. Real Launch Error Overlay (AC-LINK-01)
        AnimatedVisibility(
            visible = externalOpenError != null,
            enter = slideInVertically(initialOffsetY = { -it }) + fadeIn(),
            exit = slideOutVertically(targetOffsetY = { -it }) + fadeOut(),
            modifier = Modifier
                .align(Alignment.TopCenter)
                .fillMaxWidth()
                .padding(16.dp)
                .safeDrawingPadding()
        ) {
            Card(
                colors = CardDefaults.cardColors(containerColor = Color(0xFFEF4444)), // Red 500
                shape = RoundedCornerShape(16.dp),
                elevation = CardDefaults.cardElevation(defaultElevation = 8.dp),
                modifier = Modifier.testTag("external_open_error")
            ) {
                Row(
                    modifier = Modifier
                        .fillMaxWidth()
                        .padding(16.dp),
                    verticalAlignment = Alignment.CenterVertically,
                    horizontalArrangement = Arrangement.SpaceBetween
                ) {
                    Text(
                        text = externalOpenError ?: "Launch Error",
                        color = Color.White,
                        fontSize = 14.sp,
                        fontWeight = FontWeight.Bold
                    )
                    IconButton(onClick = { externalOpenError = null }) {
                        Icon(Icons.Default.Close, contentDescription = "Dismiss", tint = Color.White)
                    }
                }
            }
        }
    }
}

@Composable
fun VideoRowItem(
    video: Video,
    onClick: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() },
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B)),
        elevation = CardDefaults.cardElevation(defaultElevation = 2.dp)
    ) {
        Column {
            Box(
                modifier = Modifier
                    .fillMaxWidth()
                    .height(180.dp)
            ) {
                AsyncImage(
                    model = video.thumbnailUrl,
                    contentDescription = video.title,
                    modifier = Modifier.fillMaxSize(),
                    contentScale = ContentScale.Crop
                )
                
                // Category Chip Overlay
                Box(
                    modifier = Modifier
                        .align(Alignment.TopStart)
                        .padding(12.dp)
                        .clip(RoundedCornerShape(8.dp))
                        .background(Color(0xFFEF4444))
                        .padding(horizontal = 8.dp, vertical = 4.dp)
                ) {
                    Text(
                        text = video.category.uppercase(),
                        color = Color.White,
                        fontSize = 10.sp,
                        fontWeight = FontWeight.ExtraBold
                    )
                }
            }

            Column(modifier = Modifier.padding(16.dp)) {
                Text(
                    text = video.title,
                    color = Color.White,
                    fontSize = 16.sp,
                    fontWeight = FontWeight.Bold,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                    modifier = Modifier.testTag("video_list_item") // CRITICAL FOR COMPOSE SELECTOR §D.4
                )
                Spacer(modifier = Modifier.height(6.dp))
                Text(
                    text = video.description,
                    color = Color(0xFF94A3B8),
                    fontSize = 13.sp,
                    maxLines = 2,
                    overflow = TextOverflow.Ellipsis,
                    lineHeight = 18.sp
                )
            }
        }
    }
}

@OptIn(ExperimentalLayoutApi::class)
@Composable
fun FilterOptionsPanel(
    categories: List<String>,
    selected: String?,
    onSelect: (String?) -> Unit,
    onClose: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B))
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Text("Filter by Category", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 16.sp)
            Spacer(modifier = Modifier.height(16.dp))

            FlowRow(
                modifier = Modifier.fillMaxWidth(),
                horizontalArrangement = Arrangement.spacedBy(10.dp),
                verticalArrangement = Arrangement.spacedBy(10.dp)
            ) {
                // All Category
                FilterChip(
                    selected = selected == null,
                    onClick = { onSelect(null) },
                    label = { Text("All Categories") }
                )

                categories.forEach { cat ->
                    FilterChip(
                        selected = selected?.lowercase() == cat.lowercase(),
                        onClick = { onSelect(cat) },
                        label = { Text(cat) }
                    )
                }
            }

            Spacer(modifier = Modifier.height(24.dp))

            Button(
                onClick = onClose,
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFEF4444)),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .testTag("filter_apply_button")
            ) {
                Text("Apply Filter", fontWeight = FontWeight.Bold)
            }
        }
    }
}

@Composable
fun SortOptionsPanel(
    currentSort: SortOption,
    onSelect: (SortOption) -> Unit,
    onClose: () -> Unit
) {
    Card(
        modifier = Modifier
            .fillMaxWidth()
            .padding(16.dp),
        shape = RoundedCornerShape(16.dp),
        colors = CardDefaults.cardColors(containerColor = Color(0xFF1E293B))
    ) {
        Column(modifier = Modifier.padding(20.dp)) {
            Text("Sort Videos", color = Color.White, fontWeight = FontWeight.Bold, fontSize = 16.sp)
            Spacer(modifier = Modifier.height(16.dp))

            // Sort list items matching precise end-of-string regex requirements (§D.3)
            SortItemRow(
                label = "Date — newest", // matches (?i)date.*(desc|newest)
                selected = currentSort == SortOption.DATE_DESC,
                onClick = { onSelect(SortOption.DATE_DESC) }
            )
            SortItemRow(
                label = "Date — oldest",
                selected = currentSort == SortOption.DATE_ASC,
                onClick = { onSelect(SortOption.DATE_ASC) }
            )
            SortItemRow(
                label = "Title — asc",
                selected = currentSort == SortOption.TITLE_ASC,
                onClick = { onSelect(SortOption.TITLE_ASC) }
            )
            SortItemRow(
                label = "Title — desc",
                selected = currentSort == SortOption.TITLE_DESC,
                onClick = { onSelect(SortOption.TITLE_DESC) }
            )

            Spacer(modifier = Modifier.height(24.dp))

            Button(
                onClick = onClose,
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFEF4444)),
                shape = RoundedCornerShape(12.dp),
                modifier = Modifier
                    .fillMaxWidth()
                    .testTag("sort_apply_button")
            ) {
                Text("Apply Sort", fontWeight = FontWeight.Bold)
            }
        }
    }
}

@Composable
fun SortItemRow(
    label: String,
    selected: Boolean,
    onClick: () -> Unit
) {
    Row(
        modifier = Modifier
            .fillMaxWidth()
            .clickable { onClick() }
            .padding(vertical = 12.dp),
        verticalAlignment = Alignment.CenterVertically,
        horizontalArrangement = Arrangement.SpaceBetween
    ) {
        Text(text = label, color = if (selected) Color.White else Color(0xFF94A3B8), fontSize = 14.sp, fontWeight = if (selected) FontWeight.Bold else FontWeight.Normal)
        RadioButton(
            selected = selected,
            onClick = onClick,
            colors = RadioButtonDefaults.colors(
                selectedColor = Color(0xFFEF4444),
                unselectedColor = Color(0xFF94A3B8)
            )
        )
    }
}

@Composable
fun OsmMapView(
    videos: List<Video>,
    selectedVideo: Video?,
    onVideoSelected: (Video) -> Unit,
    modifier: Modifier = Modifier
) {
    val context = LocalContext.current
    Configuration.getInstance().userAgentValue = context.packageName

    AndroidView(
        factory = { ctx ->
            MapView(ctx).apply {
                setTileSource(TileSourceFactory.MAPNIK)
                setMultiTouchControls(true)
                
                controller.setZoom(3.5)
                val locatedVideos = videos.filter { it.lat != null && it.lng != null }
                if (locatedVideos.isNotEmpty()) {
                    val avgLat = locatedVideos.map { it.lat!! }.average()
                    val avgLng = locatedVideos.map { it.lng!! }.average()
                    controller.setCenter(GeoPoint(avgLat, avgLng))
                } else {
                    controller.setCenter(GeoPoint(52.5200, 13.4050))
                }

                locatedVideos.forEach { video ->
                    val marker = Marker(this).apply {
                        position = GeoPoint(video.lat!!, video.lng!!)
                        title = video.title
                        subDescription = video.category
                        setOnMarkerClickListener { m, _ ->
                            onVideoSelected(video)
                            m.showInfoWindow()
                            true
                        }
                    }
                    overlays.add(marker)
                }
            }
        },
        update = { mapView ->
            if (selectedVideo != null && selectedVideo.lat != null && selectedVideo.lng != null) {
                mapView.controller.animateTo(GeoPoint(selectedVideo.lat, selectedVideo.lng))
            }
            mapView.invalidate()
        },
        modifier = modifier
    )
}
