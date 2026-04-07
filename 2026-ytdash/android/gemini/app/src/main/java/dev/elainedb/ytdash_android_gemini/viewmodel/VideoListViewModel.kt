package dev.elainedb.ytdash_android_gemini.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import dev.elainedb.ytdash_android_gemini.core.error.Result
import dev.elainedb.ytdash_android_gemini.model.Video
import dev.elainedb.ytdash_android_gemini.repository.YouTubeRepository
import dev.elainedb.ytdash_android_gemini.usecases.GetVideos
import dev.elainedb.ytdash_android_gemini.usecases.GetVideosParams
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.collectLatest
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch
import javax.inject.Inject

sealed class VideoListUiState {
    object Loading : VideoListUiState()
    object Empty : VideoListUiState()
    data class Success(val videos: List<Video>, val totalCount: Int) : VideoListUiState()
    data class Error(val message: String) : VideoListUiState()
}

data class FilterOptions(val channelName: String? = null, val country: String? = null)
enum class SortOption(val displayName: String) {
    DATE_NEWEST("Publication Date (Newest First)"),
    DATE_OLDEST("Publication Date (Oldest First)"),
    RECORDING_NEWEST("Recording Date (Newest First)"),
    RECORDING_OLDEST("Recording Date (Oldest First)")
}

@HiltViewModel
class VideoListViewModel @Inject constructor(
    private val getVideosUseCase: GetVideos,
    private val repository: YouTubeRepository
) : ViewModel() {

    private val CHANNEL_IDS = listOf(
        "UCynoa1DjwnvHAowA_jiMEAQ",
        "UCK0KOjX3beyB9nzonls0cuw",
        "UCACkIrvrGAQ7kuc0hMVwvmA",
        "UCtWRAKKvOEA0CXOue9BG8ZA"
    )

    private val _uiState = MutableStateFlow<VideoListUiState>(VideoListUiState.Loading)
    val uiState: StateFlow<VideoListUiState> = _uiState

    private val _filterOptions = MutableStateFlow(FilterOptions())
    val filterOptions: StateFlow<FilterOptions> = _filterOptions

    private val _sortOption = MutableStateFlow(SortOption.DATE_NEWEST)
    val sortOption: StateFlow<SortOption> = _sortOption

    val availableCountries = repository.getAvailableCountries().stateIn(viewModelScope, SharingStarted.Lazily, emptyList())
    val availableChannels = repository.getAvailableChannels().stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    init {
        fetchVideos(forceRefresh = false)
        observeVideoChanges()
    }

    fun fetchVideos(forceRefresh: Boolean) {
        viewModelScope.launch {
            _uiState.value = VideoListUiState.Loading
            when (val result = getVideosUseCase(GetVideosParams(CHANNEL_IDS, forceRefresh))) {
                is Result.Success -> {
                    // State handled by observeVideoChanges flow
                }
                is Result.Error -> {
                    _uiState.value = VideoListUiState.Error(result.failure.message)
                }
            }
        }
    }
@OptIn(kotlinx.coroutines.ExperimentalCoroutinesApi::class)
private fun observeVideoChanges() {
    viewModelScope.launch {
        combine(_filterOptions, _sortOption) { filters, sort ->
            Pair(filters, sort)
        }.flatMapLatest { (filters, sort) ->
            repository.getVideosWithFiltersAndSort(filters.channelName, filters.country, sort.displayName)
                .combine(repository.getTotalVideoCount()) { videos, totalCount ->
                    Pair(videos, totalCount)
                }
        }.collect { (videos, totalCount) ->
            if (videos.isEmpty() && _uiState.value !is VideoListUiState.Loading) {
                _uiState.value = VideoListUiState.Empty
            } else if (videos.isNotEmpty()) {
                _uiState.value = VideoListUiState.Success(videos, totalCount)
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

    fun applySorting(sortOption: SortOption) {
        _sortOption.value = sortOption
    }

    fun clearFilters() {
        _filterOptions.value = FilterOptions()
        _sortOption.value = SortOption.DATE_NEWEST
    }
}
