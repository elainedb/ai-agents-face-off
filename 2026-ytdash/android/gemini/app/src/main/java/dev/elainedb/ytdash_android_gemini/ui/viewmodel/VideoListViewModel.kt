package dev.elainedb.ytdash_android_gemini.ui.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import dev.elainedb.ytdash_android_gemini.core.error.Result
import dev.elainedb.ytdash_android_gemini.domain.model.Video
import dev.elainedb.ytdash_android_gemini.domain.usecase.GetVideos
import dev.elainedb.ytdash_android_gemini.domain.usecase.GetVideosParams
import dev.elainedb.ytdash_android_gemini.domain.repository.YouTubeRepository
import kotlinx.coroutines.ExperimentalCoroutinesApi
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
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

data class FilterOptions(
    val channelName: String? = null,
    val country: String? = null
)

data class SortOption(
    val name: String = "Publication Date (Newest First)"
)

@HiltViewModel
class VideoListViewModel @Inject constructor(
    private val getVideosUseCase: GetVideos,
    private val repository: YouTubeRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<VideoListUiState>(VideoListUiState.Loading)
    val uiState: StateFlow<VideoListUiState> = _uiState

    private val _filterOptions = MutableStateFlow(FilterOptions())
    private val _sortOption = MutableStateFlow(SortOption())

    val availableCountries: StateFlow<List<String>> = repository.getAvailableCountries()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val availableChannels: StateFlow<List<String>> = repository.getAvailableChannels()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    private val channelIds = listOf(
        "UCynoa1DjwnvHAowA_jiMEAQ",
        "UCK0KOjX3beyB9nzonls0cuw",
        "UCACkIrvrGAQ7kuc0hMVwvmA",
        "UCtWRAKKvOEA0CXOue9BG8ZA"
    )

    init {
        observeVideoChanges()
        loadVideos(forceRefresh = false)
    }

    @OptIn(ExperimentalCoroutinesApi::class)
    private fun observeVideoChanges() {
        viewModelScope.launch {
            combine(
                _filterOptions,
                _sortOption
            ) { filter, sort ->
                Pair(filter, sort)
            }.flatMapLatest { (filter, sort) ->
                repository.getVideosFlow(
                    channelName = filter.channelName,
                    country = filter.country,
                    sortBy = sort.name
                )
            }.collect { videos ->
                if (videos.isEmpty() && _uiState.value !is VideoListUiState.Loading) {
                    _uiState.value = VideoListUiState.Empty
                } else if (videos.isNotEmpty()) {
                    _uiState.value = VideoListUiState.Success(videos, videos.size)
                }
            }
        }
    }

    fun loadVideos(forceRefresh: Boolean) {
        viewModelScope.launch {
            _uiState.value = VideoListUiState.Loading
            val result = getVideosUseCase(GetVideosParams(channelIds, forceRefresh))
            if (result is Result.Error) {
                _uiState.value = VideoListUiState.Error(result.failure.message)
            }
        }
    }

    fun applyFilter(channelName: String?, country: String?) {
        _filterOptions.value = FilterOptions(
            channelName = if (channelName == "All Channels") null else channelName,
            country = if (country == "All Countries") null else country
        )
    }

    fun applySorting(sortOption: String) {
        _sortOption.value = SortOption(sortOption)
    }

    fun clearFilters() {
        _filterOptions.value = FilterOptions(null, null)
    }
}
