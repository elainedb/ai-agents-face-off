package com.example.ytdash.ui.view

import androidx.compose.foundation.background
import androidx.compose.foundation.clickable
import androidx.compose.foundation.layout.*
import androidx.compose.foundation.shape.RoundedCornerShape
import androidx.compose.material.icons.Icons
import androidx.compose.material.icons.filled.Home
import androidx.compose.material.icons.filled.LocationOn
import androidx.compose.material.icons.filled.Lock
import androidx.compose.material.icons.filled.Refresh
import androidx.compose.material3.*
import androidx.compose.runtime.*
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.text.font.FontWeight
import androidx.compose.ui.unit.dp
import androidx.compose.ui.unit.sp
import com.example.ytdash.ui.viewmodel.HomeTab
import com.example.ytdash.ui.viewmodel.MainViewModel
import com.example.ytdash.ui.viewmodel.SortOption
import com.example.ytdash.ui.viewmodel.UiState

@OptIn(ExperimentalMaterial3Api::class)
@Composable
fun HomeScreen(
    viewModel: MainViewModel,
    modifier: Modifier = Modifier
) {
    val currentTab by viewModel.currentTab.collectAsState()
    val videosState by viewModel.videosState.collectAsState()
    val channels by viewModel.channels.collectAsState()
    val selectedCategory by viewModel.selectedCategory.collectAsState()
    val sortOption by viewModel.sortOption.collectAsState()
    
    val isFilterPanelOpen by viewModel.isFilterPanelOpen.collectAsState()
    val isSortPanelOpen by viewModel.isSortPanelOpen.collectAsState()

    // Determine the total count of loaded videos
    val loadedCount = (videosState as? UiState.Success)?.data?.size ?: 0

    Scaffold(
        modifier = modifier
            .fillMaxSize()
            .testTag("screen_home"),
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
                        // This element displays the total loaded count carrying the video_count ID
                        Surface(
                            color = Color(0xFFFF0000).copy(alpha = 0.2f),
                            shape = RoundedCornerShape(8.dp)
                        ) {
                            Text(
                                text = "$loadedCount Videos",
                                color = Color(0xFFFF3333),
                                fontSize = 12.sp,
                                fontWeight = FontWeight.Bold,
                                modifier = Modifier
                                    .padding(horizontal = 8.dp, vertical = 4.dp)
                                    .testTag("video_count")
                            )
                        }
                    }
                },
                actions = {
                    // Refresh Button carrying the refresh_control testTag
                    IconButton(
                        onClick = { viewModel.fetchVideos(forceRefresh = true) },
                        modifier = Modifier.testTag("refresh_control")
                    ) {
                        Icon(
                            imageVector = Icons.Default.Refresh,
                            contentDescription = "Refresh Feed",
                            tint = Color.White
                        )
                    }

                    // Filter Button
                    IconButton(
                        onClick = { viewModel.setFilterPanelOpen(true) },
                        modifier = Modifier.testTag("filter_button")
                    ) {
                        Text("⏳", color = Color.White, fontSize = 18.sp) // Filter icon
                    }

                    // Sort Button
                    IconButton(
                        onClick = { viewModel.setSortPanelOpen(true) },
                        modifier = Modifier.testTag("sort_button")
                    ) {
                        Text("⇅", color = Color.White, fontSize = 18.sp) // Sort icon
                    }

                    // Logout Button carrying the logout_button testTag
                    IconButton(
                        onClick = { viewModel.logout() },
                        modifier = Modifier.testTag("logout_button")
                    ) {
                        Icon(
                            imageVector = Icons.Default.Lock,
                            contentDescription = "Logout",
                            tint = Color.Gray
                        )
                    }
                },
                colors = TopAppBarDefaults.topAppBarColors(
                    containerColor = Color(0xFF0F0F11)
                )
            )
        },
        bottomBar = {
            // Render navigation bar only if the filter or sort panels are closed
            if (!isFilterPanelOpen && !isSortPanelOpen) {
                NavigationBar(
                    containerColor = Color(0xFF0F0F11),
                    tonalElevation = 8.dp
                ) {
                    NavigationBarItem(
                        selected = currentTab == HomeTab.LIST,
                        onClick = { viewModel.setTab(HomeTab.LIST) },
                        icon = { Icon(Icons.Default.Home, contentDescription = "Videos") },
                        label = { Text("Videos") },
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = Color(0xFFFF0000),
                            selectedTextColor = Color(0xFFFF0000),
                            unselectedIconColor = Color.Gray,
                            unselectedTextColor = Color.Gray,
                            indicatorColor = Color(0xFFFF0000).copy(alpha = 0.1f)
                        )
                    )

                    NavigationBarItem(
                        selected = currentTab == HomeTab.MAP,
                        onClick = { viewModel.setTab(HomeTab.MAP) },
                        icon = { Icon(Icons.Default.LocationOn, contentDescription = "Map") },
                        label = { Text("Map") },
                        // This element carries the map_nav_button test tag
                        modifier = Modifier.testTag("map_nav_button"),
                        colors = NavigationBarItemDefaults.colors(
                            selectedIconColor = Color(0xFFFF0000),
                            selectedTextColor = Color(0xFFFF0000),
                            unselectedIconColor = Color.Gray,
                            unselectedTextColor = Color.Gray,
                            indicatorColor = Color(0xFFFF0000).copy(alpha = 0.1f)
                        )
                    )
                }
            }
        }
    ) { paddingValues ->
        Box(
            modifier = Modifier
                .fillMaxSize()
                .padding(paddingValues)
                .background(Color(0xFF0F0F11))
        ) {
            // REPLACEMENT CONTRACT: If filter or sort panel is open, completely replace the content
            // to avoid label collision with the video list rows.
            if (isFilterPanelOpen) {
                FilterPanel(
                    categories = channels.map { it.label },
                    selectedCategory = selectedCategory,
                    onCategorySelected = { category ->
                        viewModel.setFilterCategory(category)
                    },
                    onDismiss = { viewModel.setFilterPanelOpen(false) }
                )
            } else if (isSortPanelOpen) {
                SortPanel(
                    selectedOption = sortOption,
                    onOptionSelected = { option ->
                        viewModel.setSortOption(option)
                    },
                    onDismiss = { viewModel.setSortPanelOpen(false) }
                )
            } else {
                // Otherwise render the normal home view contents
                when (currentTab) {
                    HomeTab.LIST -> {
                        VideoListTab(viewModel = viewModel)
                    }
                    HomeTab.MAP -> {
                        MapTab(viewModel = viewModel)
                    }
                }
            }
        }
    }
}

@Composable
fun FilterPanel(
    categories: List<String>,
    selectedCategory: String?,
    onCategorySelected: (String?) -> Unit,
    onDismiss: () -> Unit
) {
    var tempCategory by remember { mutableStateOf(selectedCategory) }

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Filter Videos",
            color = Color.White,
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        // Clear option
        Surface(
            modifier = Modifier
                .fillMaxWidth()
                .clickable { tempCategory = null },
            color = if (tempCategory == null) Color(0xFFFF0000).copy(alpha = 0.2f) else Color(0xFF1E1E24),
            shape = RoundedCornerShape(12.dp),
            border = if (tempCategory == null) CardDefaults.outlinedCardBorder() else null
        ) {
            Text(
                text = "Show All Categories",
                color = if (tempCategory == null) Color.Red else Color.White,
                fontWeight = FontWeight.SemiBold,
                modifier = Modifier.padding(16.dp)
            )
        }

        // Available categories dynamically retrieved from configuration labels
        categories.forEach { category ->
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { tempCategory = category },
                color = if (tempCategory?.equals(category, ignoreCase = true) == true) {
                    Color(0xFFFF0000).copy(alpha = 0.2f)
                } else {
                    Color(0xFF1E1E24)
                },
                shape = RoundedCornerShape(12.dp)
            ) {
                Text(
                    // Important: Keep option text matched to whitelisted regex/names
                    text = category,
                    color = if (tempCategory?.equals(category, ignoreCase = true) == true) Color.Red else Color.White,
                    fontWeight = FontWeight.SemiBold,
                    modifier = Modifier.padding(16.dp)
                )
            }
        }

        Spacer(modifier = Modifier.weight(1f))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            OutlinedButton(
                onClick = onDismiss,
                modifier = Modifier.weight(1f),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text("Cancel", color = Color.White)
            }

            // Filter Apply Button
            Button(
                onClick = {
                    onCategorySelected(tempCategory)
                    onDismiss()
                },
                modifier = Modifier
                    .weight(1f)
                    .testTag("filter_apply_button"),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFFF0000))
            ) {
                Text("Apply", color = Color.White, fontWeight = FontWeight.Bold)
            }
        }
    }
}

@Composable
fun SortPanel(
    selectedOption: SortOption,
    onOptionSelected: (SortOption) -> Unit,
    onDismiss: () -> Unit
) {
    var tempOption by remember { mutableStateOf(selectedOption) }

    val options = listOf(
        SortOption.DATE_DESC to "Date — newest",
        SortOption.DATE_ASC to "Date — oldest",
        SortOption.TITLE_ASC to "Title — ascending",
        SortOption.TITLE_DESC to "Title — descending"
    )

    Column(
        modifier = Modifier
            .fillMaxSize()
            .padding(24.dp),
        verticalArrangement = Arrangement.spacedBy(16.dp),
        horizontalAlignment = Alignment.CenterHorizontally
    ) {
        Text(
            text = "Sort Videos",
            color = Color.White,
            fontSize = 22.sp,
            fontWeight = FontWeight.Bold,
            modifier = Modifier.padding(bottom = 8.dp)
        )

        options.forEach { (option, label) ->
            Surface(
                modifier = Modifier
                    .fillMaxWidth()
                    .clickable { tempOption = option },
                color = if (tempOption == option) Color(0xFFFF0000).copy(alpha = 0.2f) else Color(0xFF1E1E24),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text(
                    // Important: The label must END with the regex keyword, e.g. "newest" or "oldest"
                    text = label,
                    color = if (tempOption == option) Color.Red else Color.White,
                    fontWeight = FontWeight.SemiBold,
                    modifier = Modifier.padding(16.dp)
                )
            }
        }

        Spacer(modifier = Modifier.weight(1f))

        Row(
            modifier = Modifier.fillMaxWidth(),
            horizontalArrangement = Arrangement.spacedBy(16.dp)
        ) {
            OutlinedButton(
                onClick = onDismiss,
                modifier = Modifier.weight(1f),
                shape = RoundedCornerShape(12.dp)
            ) {
                Text("Cancel", color = Color.White)
            }

            // Sort Apply Button
            Button(
                onClick = {
                    onOptionSelected(tempOption)
                    onDismiss()
                },
                modifier = Modifier
                    .weight(1f)
                    .testTag("sort_apply_button"),
                shape = RoundedCornerShape(12.dp),
                colors = ButtonDefaults.buttonColors(containerColor = Color(0xFFFF0000))
            ) {
                Text("Apply", color = Color.White, fontWeight = FontWeight.Bold)
            }
        }
    }
}
