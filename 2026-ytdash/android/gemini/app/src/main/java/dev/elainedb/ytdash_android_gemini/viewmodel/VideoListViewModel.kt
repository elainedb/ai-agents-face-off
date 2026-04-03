package dev.elainedb.ytdash_android_gemini.viewmodel

import android.app.Application
import androidx.lifecycle.AndroidViewModel
import androidx.lifecycle.viewModelScope
import dev.elainedb.ytdash_android_gemini.model.Video
import dev.elainedb.ytdash_android_gemini.repository.YouTubeRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

sealed class VideoListUiState {
    object Loading : VideoListUiState()
    object Empty : VideoListUiState()
    data class Success(val videos: List<Video>, val totalCount: Int) : VideoListUiState()
    data class Error(val message: String) : VideoListUiState()
}

data class FilterOptions(
    val channelName: String? = null,
    val country: String? = null
)

enum class SortOption {
    PUBLISHED_NEWEST,
    PUBLISHED_OLDEST,
    RECORDED_NEWEST,
    RECORDED_OLDEST
}

class VideoListViewModel(application: Application) : AndroidViewModel(application) {
    private val repository = YouTubeRepository(application)

    private val _uiState = MutableStateFlow<VideoListUiState>(VideoListUiState.Loading)
    val uiState: StateFlow<VideoListUiState> = _uiState.asStateFlow()

    private val _filterOptions = MutableStateFlow(FilterOptions())
    val filterOptions: StateFlow<FilterOptions> = _filterOptions.asStateFlow()

    private val _sortOption = MutableStateFlow(SortOption.PUBLISHED_NEWEST)
    val sortOption: StateFlow<SortOption> = _sortOption.asStateFlow()

    val availableCountries: StateFlow<List<String>> = repository.getDistinctCountries()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val availableChannels: StateFlow<List<String>> = repository.getDistinctChannels()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val totalVideoCount: StateFlow<Int> = repository.getTotalVideoCount()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)

    init {
        loadVideos()
        observeVideoChanges()
    }

    private fun loadVideos() {
        viewModelScope.launch {
            _uiState.value = VideoListUiState.Loading
            try {
                repository.getLatestVideos()
            } catch (e: Exception) {
                _uiState.value = VideoListUiState.Error(e.message ?: "Unknown error")
            }
        }
    }

    fun refreshVideos() {
        viewModelScope.launch {
            _uiState.value = VideoListUiState.Loading
            try {
                repository.refreshVideos()
            } catch (e: Exception) {
                _uiState.value = VideoListUiState.Error(e.message ?: "Failed to refresh")
            }
        }
    }

    private fun observeVideoChanges() {
        viewModelScope.launch {
            combine(_filterOptions, _sortOption) { filter, sort ->
                Pair(filter, sort)
            }.flatMapLatest { (filter, sort) ->
                repository.getVideosWithFiltersAndSort(
                    channelName = filter.channelName,
                    country = filter.country,
                    sortBy = sort.name
                )
            }.collect { videos ->
                if (videos.isEmpty()) {
                    // Check if it's because DB is actually empty or just filters are strict
                    val total = totalVideoCount.value
                    if (total == 0) {
                        _uiState.value = VideoListUiState.Empty
                    } else {
                        _uiState.value = VideoListUiState.Success(videos, total)
                    }
                } else {
                    _uiState.value = VideoListUiState.Success(videos, totalVideoCount.value)
                }
            }
        }
    }

    fun applyFilter(channelName: String?, country: String?) {
        _filterOptions.value = FilterOptions(
            channelName = if (channelName == "All Channels") null else channelName,
            country = if (country == "All Countries") null else country
        )
    }

    fun applySorting(option: SortOption) {
        _sortOption.value = option
    }

    fun clearFilters() {
        _filterOptions.value = FilterOptions()
    }
}
