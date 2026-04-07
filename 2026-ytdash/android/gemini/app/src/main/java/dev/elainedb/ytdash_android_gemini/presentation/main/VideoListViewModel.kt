package dev.elainedb.ytdash_android_gemini.presentation.main

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import dev.elainedb.ytdash_android_gemini.core.error.Result
import dev.elainedb.ytdash_android_gemini.domain.model.Video
import dev.elainedb.ytdash_android_gemini.domain.repository.YouTubeRepository
import dev.elainedb.ytdash_android_gemini.domain.usecase.GetVideos
import dev.elainedb.ytdash_android_gemini.domain.usecase.GetVideosParams
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.flow.update
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

@HiltViewModel
class VideoListViewModel @Inject constructor(
    private val repository: YouTubeRepository,
    private val getVideosUseCase: GetVideos
) : ViewModel() {

    private val _uiState = MutableStateFlow<VideoListUiState>(VideoListUiState.Loading)
    val uiState: StateFlow<VideoListUiState> = _uiState.asStateFlow()

    private val _filterOptions = MutableStateFlow(FilterOptions())
    val filterOptions: StateFlow<FilterOptions> = _filterOptions.asStateFlow()

    private val _sortOption = MutableStateFlow("DATE_DESC")
    val sortOption: StateFlow<String> = _sortOption.asStateFlow()

    val availableCountries: StateFlow<List<String>> = repository.observeDistinctCountries()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val availableChannels: StateFlow<List<String>> = repository.observeDistinctChannels()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), emptyList())

    val totalVideoCount: StateFlow<Int> = repository.observeTotalVideoCount()
        .stateIn(viewModelScope, SharingStarted.WhileSubscribed(5000), 0)

    private val channelIds = listOf(
        "UCynoa1DjwnvHAowA_jiMEAQ",
        "UCK0KOjX3beyB9nzonls0cuw",
        "UCACkIrvrGAQ7kuc0hMVwvmA",
        "UCtWRAKKvOEA0CXOue9BG8ZA"
    )

    init {
        observeVideoChanges()
        fetchVideos(forceRefresh = false)
    }

    private fun observeVideoChanges() {
        viewModelScope.launch {
            combine(_filterOptions, _sortOption) { filters, sort ->
                Pair(filters, sort)
            }.flatMapLatest { (filters, sort) ->
                repository.observeVideos(filters.channelName, filters.country, sort)
            }.collect { videos ->
                if (videos.isEmpty() && _uiState.value !is VideoListUiState.Loading) {
                    _uiState.value = VideoListUiState.Empty
                } else {
                    _uiState.value = VideoListUiState.Success(videos, videos.size)
                }
            }
        }
    }

    fun fetchVideos(forceRefresh: Boolean = true) {
        viewModelScope.launch {
            _uiState.value = VideoListUiState.Loading
            val result = getVideosUseCase(GetVideosParams(channelIds, forceRefresh))
            if (result is Result.Error) {
                _uiState.value = VideoListUiState.Error(result.failure.message)
            }
        }
    }

    fun applyFilter(channelName: String?, country: String?) {
        _filterOptions.update {
            it.copy(
                channelName = if (channelName == "All Channels") null else channelName,
                country = if (country == "All Countries") null else country
            )
        }
    }

    fun applySorting(sort: String) {
        _sortOption.value = sort
    }

    fun clearFilters() {
        _filterOptions.update { FilterOptions(null, null) }
        _sortOption.value = "DATE_DESC"
    }
}
