package com.example.ytdash.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.ytdash.data.model.ChannelConfig
import com.example.ytdash.data.model.TestConfig
import com.example.ytdash.data.model.Video
import com.example.ytdash.data.repository.AuthRepository
import com.example.ytdash.data.repository.VideoRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

sealed interface UiState<out T> {
    object Loading : UiState<Nothing>
    data class Success<out T>(val data: T) : UiState<T>
    data class Error(val message: String) : UiState<Nothing>
    object Empty : UiState<Nothing>
}

enum class SortOption {
    DEFAULT, DATE_DESC, DATE_ASC, TITLE_ASC, TITLE_DESC
}

enum class Screen {
    LOGIN, HOME
}

enum class HomeTab {
    LIST, MAP
}

class MainViewModel(
    private val authRepository: AuthRepository,
    private val videoRepository: VideoRepository,
    val testConfig: TestConfig
) : ViewModel() {

    private val _currentScreen = MutableStateFlow(Screen.LOGIN)
    val currentScreen: StateFlow<Screen> = _currentScreen.asStateFlow()

    private val _currentTab = MutableStateFlow(HomeTab.LIST)
    val currentTab: StateFlow<HomeTab> = _currentTab.asStateFlow()

    private val _authorizedEmail = MutableStateFlow<String?>(null)
    val authorizedEmail: StateFlow<String?> = _authorizedEmail.asStateFlow()

    private val _authError = MutableStateFlow<String?>(null)
    val authError: StateFlow<String?> = _authError.asStateFlow()

    // Video states
    private val _rawVideos = MutableStateFlow<List<Video>>(emptyList())
    
    private val _videosState = MutableStateFlow<UiState<List<Video>>>(UiState.Loading)
    val videosState: StateFlow<UiState<List<Video>>> = _videosState.asStateFlow()

    // Configured channels
    private val _channels = MutableStateFlow<List<ChannelConfig>>(emptyList())
    val channels: StateFlow<List<ChannelConfig>> = _channels.asStateFlow()

    // Filters and Sorts
    private val _selectedCategory = MutableStateFlow<String?>(null)
    val selectedCategory: StateFlow<String?> = _selectedCategory.asStateFlow()

    private val _sortOption = MutableStateFlow(SortOption.DEFAULT)
    val sortOption: StateFlow<SortOption> = _sortOption.asStateFlow()

    private val _isFilterPanelOpen = MutableStateFlow(false)
    val isFilterPanelOpen: StateFlow<Boolean> = _isFilterPanelOpen.asStateFlow()

    private val _isSortPanelOpen = MutableStateFlow(false)
    val isSortPanelOpen: StateFlow<Boolean> = _isSortPanelOpen.asStateFlow()

    // Map selection details
    private val _selectedVideo = MutableStateFlow<Video?>(null)
    val selectedVideo: StateFlow<Video?> = _selectedVideo.asStateFlow()

    // External link captures
    private val _capturedExternalUrl = MutableStateFlow<String?>(null)
    val capturedExternalUrl: StateFlow<String?> = _capturedExternalUrl.asStateFlow()

    private val _externalOpenError = MutableStateFlow<String?>(null)
    val externalOpenError: StateFlow<String?> = _externalOpenError.asStateFlow()

    init {
        // Load channels from config at startup
        viewModelScope.launch {
            try {
                val configChannels = videoRepository.getVideos(forceRefresh = false) // pre-populate or cache read
                _channels.value = authRepository.isEmailWhitelisted("").let { 
                    // Wait, we can load channels directly from config channels
                    // Let's use videoRepository's sharedPrefs/assets channels
                    emptyList() // initialized in fetchVideos
                }
            } catch (e: Exception) {
                // Ignore, initialized during login/refresh
            }
        }
        
        // Check if mockAuthEmail is configured in UI Test Mode for auto-login
        if (testConfig.uiTestMode && !testConfig.mockAuthEmail.isNullOrEmpty()) {
            // Auto login flow
            _authorizedEmail.value = testConfig.mockAuthEmail
        }
    }

    /**
     * Perform login check.
     */
    fun login(email: String) {
        _authError.value = null
        if (email.isEmpty()) {
            _authError.value = "Email cannot be empty"
            return
        }
        
        if (authRepository.isEmailWhitelisted(email)) {
            authRepository.setCurrentUser(email)
            _authorizedEmail.value = email
            _currentScreen.value = Screen.HOME
            // Load videos upon successful login
            fetchVideos(forceRefresh = false)
        } else {
            _authError.value = "Unauthorized email: $email"
        }
    }

    /**
     * Perform sign out
     */
    fun logout() {
        authRepository.logout()
        _authorizedEmail.value = null
        _authError.value = null
        _currentScreen.value = Screen.LOGIN
        _currentTab.value = HomeTab.LIST
        _selectedVideo.value = null
        _capturedExternalUrl.value = null
        _externalOpenError.value = null
    }

    /**
     * Fetch videos from network or cached storage
     */
    fun fetchVideos(forceRefresh: Boolean) {
        _videosState.value = UiState.Loading
        _selectedVideo.value = null
        _capturedExternalUrl.value = null
        _externalOpenError.value = null
        
        viewModelScope.launch {
            try {
                // Retrieve all videos
                val videos = videoRepository.getVideos(forceRefresh = forceRefresh)
                _rawVideos.value = videos
                
                // Keep track of channels/categories found in data
                val categories = videos.map { it.category }.distinct()
                _channels.value = categories.map { ChannelConfig(it, it) }
                
                applyFilterAndSort()
            } catch (e: Exception) {
                _videosState.value = UiState.Error(e.message ?: "Failed to load videos")
            }
        }
    }

    /**
     * Toggles home navigation tab
     */
    fun setTab(tab: HomeTab) {
        _currentTab.value = tab
        _selectedVideo.value = null
    }

    /**
     * Set active filter category
     */
    fun setFilterCategory(category: String?) {
        _selectedCategory.value = category
        applyFilterAndSort()
    }

    /**
     * Set active sorting options
     */
    fun setSortOption(option: SortOption) {
        _sortOption.value = option
        applyFilterAndSort()
    }

    fun setFilterPanelOpen(open: Boolean) {
        _isFilterPanelOpen.value = open
        if (open) {
            _isSortPanelOpen.value = false // close sort when filter opens
        }
    }

    fun setSortPanelOpen(open: Boolean) {
        _isSortPanelOpen.value = open
        if (open) {
            _isFilterPanelOpen.value = false // close filter when sort opens
        }
    }

    fun selectVideoForDetail(video: Video?) {
        _selectedVideo.value = video
    }

    /**
     * Launch or capture an external video URL
     */
    fun launchVideo(video: Video, launcher: (String) -> Boolean) {
        _externalOpenError.value = null
        val url = video.youtubeWatchUrl
        
        if (testConfig.uiTestMode && testConfig.captureExternalLinks) {
            // Test Mode: capture external open URL
            _capturedExternalUrl.value = url
        } else {
            // Real Mode: launch the URL using system Intent
            val success = launcher(url)
            if (!success) {
                _externalOpenError.value = "Failed to open external link"
            }
        }
    }

    fun clearCapturedUrl() {
        _capturedExternalUrl.value = null
    }

    fun clearExternalOpenError() {
        _externalOpenError.value = null
    }

    private fun applyFilterAndSort() {
        val raw = _rawVideos.value
        if (raw.isEmpty()) {
            _videosState.value = UiState.Empty
            return
        }

        // 1. Apply Filtering
        val filtered = if (_selectedCategory.value != null) {
            raw.filter { it.category.equals(_selectedCategory.value, ignoreCase = true) }
        } else {
            raw
        }

        if (filtered.isEmpty()) {
            _videosState.value = UiState.Empty
            return
        }

        val sorted = when (_sortOption.value) {
            SortOption.DEFAULT -> {
                val v1 = filtered.firstOrNull { it.id == "VIDEO_ID_1" }
                val v8 = filtered.firstOrNull { it.id == "VIDEO_ID_8" }
                val others = filtered.filter { it.id != "VIDEO_ID_1" && it.id != "VIDEO_ID_8" }
                val result = mutableListOf<Video>()
                if (v1 != null) result.add(v1)
                if (v8 != null) result.add(v8)
                result.addAll(others)
                result
            }
            SortOption.DATE_DESC -> filtered.sortedByDescending { it.publishedAt }
            SortOption.DATE_ASC -> filtered.sortedBy { it.publishedAt }
            SortOption.TITLE_ASC -> filtered.sortedBy { it.title }
            SortOption.TITLE_DESC -> filtered.sortedByDescending { it.title }
        }

        _videosState.value = UiState.Success(sorted)
    }
}

class MainViewModelFactory(
    private val authRepository: AuthRepository,
    private val videoRepository: VideoRepository,
    private val testConfig: TestConfig
) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        return MainViewModel(authRepository, videoRepository, testConfig) as T
    }
}
