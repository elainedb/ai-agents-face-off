package dev.elainedb.ytdash_android_gemini.viewmodel

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import dev.elainedb.ytdash_android_gemini.models.Video
import dev.elainedb.ytdash_android_gemini.repository.YouTubeRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.SharingStarted
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.combine
import kotlinx.coroutines.flow.flatMapLatest
import kotlinx.coroutines.flow.stateIn
import kotlinx.coroutines.launch

class VideoListViewModel(private val repository: YouTubeRepository) : ViewModel() {

    private val _isLoading = MutableStateFlow(true)
    val isLoading: StateFlow<Boolean> = _isLoading
    
    private val _isRefreshing = MutableStateFlow(false)
    val isRefreshing: StateFlow<Boolean> = _isRefreshing

    private val _channelFilter = MutableStateFlow<String?>(null)
    val channelFilter: StateFlow<String?> = _channelFilter

    private val _countryFilter = MutableStateFlow<String?>(null)
    val countryFilter: StateFlow<String?> = _countryFilter

    private val _sortBy = MutableStateFlow("PUB_DATE_DESC")
    val sortBy: StateFlow<String> = _sortBy

    val distinctChannels: StateFlow<List<String>> = repository.getDistinctChannels()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    val distinctCountries: StateFlow<List<String>> = repository.getDistinctCountries()
        .stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    private data class FilterParams(val channel: String?, val country: String?, val sort: String)

    @OptIn(kotlinx.coroutines.ExperimentalCoroutinesApi::class)
    val videos: StateFlow<List<Video>> = combine(_channelFilter, _countryFilter, _sortBy) { channel, country, sort ->
        FilterParams(channel, country, sort)
    }.flatMapLatest { params ->
        repository.getVideosWithFiltersAndSort(params.channel, params.country, params.sort)
    }.stateIn(viewModelScope, SharingStarted.Lazily, emptyList())

    init {
        viewModelScope.launch {
            _isLoading.value = true
            repository.getLatestVideos()
            _isLoading.value = false
        }
    }

    fun refresh() {
        viewModelScope.launch {
            _isRefreshing.value = true
            repository.refreshVideos()
            _isRefreshing.value = false
        }
    }

    fun setChannelFilter(channel: String?) {
        _channelFilter.value = channel
    }

    fun setCountryFilter(country: String?) {
        _countryFilter.value = country
    }

    fun setSortBy(sort: String) {
        _sortBy.value = sort
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
