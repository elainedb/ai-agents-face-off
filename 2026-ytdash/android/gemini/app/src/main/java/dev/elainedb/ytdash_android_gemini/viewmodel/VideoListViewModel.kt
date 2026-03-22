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

data class FilterOptions(val channelName: String? = null, val country: String? = null)

enum class SortOption {
    PUB_DATE_DESC, PUB_DATE_ASC, REC_DATE_DESC, REC_DATE_ASC
}

class VideoListViewModel(private val repository: YouTubeRepository) : ViewModel() {

    private val _uiState = MutableStateFlow<VideoListUiState>(VideoListUiState.Loading)
    val uiState: StateFlow<VideoListUiState> = _uiState.asStateFlow()

    private val _filterOptions = MutableStateFlow(FilterOptions())
    private val _sortOption = MutableStateFlow(SortOption.PUB_DATE_DESC)

    val availableCountries: StateFlow<List<String>> = repository.getDistinctCountries()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val availableChannels: StateFlow<List<String>> = repository.getDistinctChannels()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    init {
        observeVideoChanges()
        fetchVideos()
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
                ).combine(repository.getTotalVideoCount()) { videos, totalCount ->
                    Pair(videos, totalCount)
                }
            }.collectLatest { (videos, totalCount) ->
                if (videos.isEmpty()) {
                    _uiState.value = VideoListUiState.Empty
                } else {
                    _uiState.value = VideoListUiState.Success(videos, totalCount)
                }
            }
        }
    }

    fun fetchVideos() {
        _uiState.value = VideoListUiState.Loading
        viewModelScope.launch {
            try {
                repository.getLatestVideos()
            } catch (e: Exception) {
                _uiState.value = VideoListUiState.Error(e.message ?: "Unknown error")
            }
        }
    }

    fun refreshVideos() {
        _uiState.value = VideoListUiState.Loading
        viewModelScope.launch {
            try {
                repository.refreshVideos()
            } catch (e: Exception) {
                _uiState.value = VideoListUiState.Error(e.message ?: "Unknown error")
            }
        }
    }

    fun applyFilter(channelName: String?, country: String?) {
        _filterOptions.value = FilterOptions(channelName, country)
    }

    fun applySorting(sortOption: SortOption) {
        _sortOption.value = sortOption
    }

    fun clearFilters() {
        _filterOptions.value = FilterOptions()
        _sortOption.value = SortOption.PUB_DATE_DESC
    }
}
