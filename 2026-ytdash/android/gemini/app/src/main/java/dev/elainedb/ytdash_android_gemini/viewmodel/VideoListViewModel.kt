package dev.elainedb.ytdash_android_gemini.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import dev.elainedb.ytdash_android_gemini.model.Video
import dev.elainedb.ytdash_android_gemini.repository.YouTubeRepository
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
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

enum class SortOption {
    PUB_DATE_DESC, PUB_DATE_ASC, REC_DATE_DESC, REC_DATE_ASC
}

data class FilterOptions(
    val channelName: String? = null,
    val country: String? = null
)

class VideoListViewModel(
    private val repository: YouTubeRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<VideoListUiState>(VideoListUiState.Loading)
    val uiState: StateFlow<VideoListUiState> = _uiState

    private val _filterOptions = MutableStateFlow(FilterOptions())
    val filterOptions: StateFlow<FilterOptions> = _filterOptions

    private val _sortOption = MutableStateFlow(SortOption.PUB_DATE_DESC)
    val sortOption: StateFlow<SortOption> = _sortOption

    val availableCountries: StateFlow<List<String>> = repository.getDistinctCountries()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val availableChannels: StateFlow<List<String>> = repository.getDistinctChannels()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val totalVideoCount: StateFlow<Int> = repository.getTotalVideoCount()
        .stateIn(viewModelScope, SharingStarted.Lazily, 0)

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
                _uiState.value = VideoListUiState.Error(e.message ?: "Unknown error")
            }
        }
    }

    @OptIn(ExperimentalCoroutinesApi::class)
    private fun observeVideoChanges() {
        viewModelScope.launch {
            combine(_filterOptions, _sortOption, totalVideoCount) { filters, sort, total ->
                Triple(filters, sort, total)
            }.flatMapLatest { (filters, sort, total) ->
                repository.observeVideos(filters.channelName, filters.country, sort.name)
                    .combine(MutableStateFlow(total)) { videos, t -> Pair(videos, t) }
            }.collect { (videos, total) ->
                if (videos.isEmpty() && _uiState.value !is VideoListUiState.Loading) {
                    _uiState.value = VideoListUiState.Empty
                } else if (videos.isNotEmpty()) {
                    _uiState.value = VideoListUiState.Success(videos, total)
                }
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
    }
}

class VideoListViewModelFactory(private val repository: YouTubeRepository) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(VideoListViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return VideoListViewModel(repository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
