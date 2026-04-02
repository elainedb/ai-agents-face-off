package dev.elainedb.ytdash_android_gemini.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.elainedb.ytdash_android_gemini.model.Video
import dev.elainedb.ytdash_android_gemini.repository.YouTubeRepository
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

sealed class VideoListUiState {
    object Loading : VideoListUiState()
    object Empty : VideoListUiState()
    data class Success(val videos: List<Video>, val totalCount: Int) : VideoListUiState()
    data class Error(val message: String) : VideoListUiState()
}

data class FilterOptions(
    val channelName: String = "All Channels",
    val country: String = "All Countries"
)

enum class SortOption(val value: String, val label: String) {
    PUB_NEWEST("pub_newest", "Publication Date (Newest First)"),
    PUB_OLDEST("pub_oldest", "Publication Date (Oldest First)"),
    REC_NEWEST("rec_newest", "Recording Date (Newest First)"),
    REC_OLDEST("rec_oldest", "Recording Date (Oldest First)")
}

@OptIn(kotlinx.coroutines.ExperimentalCoroutinesApi::class)
class VideoListViewModel(private val repository: YouTubeRepository) : ViewModel() {

    private val _filterOptions = MutableStateFlow(FilterOptions())
    val filterOptions: StateFlow<FilterOptions> = _filterOptions.asStateFlow()

    private val _sortOption = MutableStateFlow(SortOption.PUB_NEWEST)
    val sortOption: StateFlow<SortOption> = _sortOption.asStateFlow()

    private val _uiState = MutableStateFlow<VideoListUiState>(VideoListUiState.Loading)
    val uiState: StateFlow<VideoListUiState> = _uiState.asStateFlow()

    val availableChannels: StateFlow<List<String>> = repository.getDistinctChannels()
        .map { listOf("All Channels") + it }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), listOf("All Channels"))

    val availableCountries: StateFlow<List<String>> = repository.getDistinctCountries()
        .map { listOf("All Countries") + it }
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), listOf("All Countries"))

    val totalVideoCount: StateFlow<Int> = repository.getTotalVideoCount()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)

    init {
        observeVideos()
        initialLoad()
    }

    private fun observeVideos() {
        combine(_filterOptions, _sortOption) { filters, sort ->
            filters to sort
        }.flatMapLatest { (filters, sort) ->
            repository.getVideos(filters.channelName, filters.country, sort.value)
        }.onEach { videos ->
            if (videos.isEmpty()) {
                // If we are empty but we have zero count in DB, it might be loading or truly empty
                // We'll trust the refresh logic
            }
            _uiState.value = if (videos.isEmpty()) VideoListUiState.Empty else VideoListUiState.Success(videos, videos.size)
        }.launchIn(viewModelScope)
    }

    private fun initialLoad() {
        viewModelScope.launch {
            if (!repository.isCacheValid()) {
                refreshVideos()
            }
        }
    }

    fun refreshVideos() {
        viewModelScope.launch {
            _uiState.value = VideoListUiState.Loading
            try {
                repository.refreshVideos()
            } catch (e: Exception) {
                _uiState.value = VideoListUiState.Error(e.message ?: "Unknown error")
            }
        }
    }

    fun applyFilter(channelName: String, country: String) {
        _filterOptions.value = FilterOptions(channelName, country)
    }

    fun applySorting(option: SortOption) {
        _sortOption.value = option
    }

    fun clearFilters() {
        _filterOptions.value = FilterOptions()
    }
}
