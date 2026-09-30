package dev.elainedb.android_gemini.presentation.main

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.elainedb.android_gemini.domain.youtube.GetYoutubeVideosUseCase
import dev.elainedb.android_gemini.domain.youtube.YoutubeVideo
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class MainViewModel(
    private val getYoutubeVideosUseCase: GetYoutubeVideosUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow<MainUiState>(MainUiState.Loading)
    val uiState = _uiState.asStateFlow()

    private var videos: List<YoutubeVideo> = emptyList()
    private var sortOrder = SortOrder.PUBLICATION_DATE_DESC
    private var filterChannel: String? = null
    private var filterCountry: String? = null

    fun getVideos() {
        viewModelScope.launch {
            try {
                videos = getYoutubeVideosUseCase()
                updateUi()
            } catch (e: Exception) {
                Log.e("MainViewModel", "Error getting videos", e)
                _uiState.value = MainUiState.Error(e.message ?: "An unknown error occurred")
            }
        }
    }

    fun refreshVideos() {
        viewModelScope.launch {
            try {
                _uiState.value = MainUiState.Loading
                videos = getYoutubeVideosUseCase()
                updateUi()
            } catch (e: Exception) {
                Log.e("MainViewModel", "Error refreshing videos", e)
                _uiState.value = MainUiState.Error(e.message ?: "An unknown error occurred")
            }
        }
    }

    fun setSortOrder(sortOrder: SortOrder) {
        this.sortOrder = sortOrder
        updateUi()
    }

    fun setFilter(channel: String?, country: String?) {
        this.filterChannel = channel
        this.filterCountry = country
        updateUi()
    }

    private fun updateUi() {
        var filteredVideos = videos
        if (filterChannel != null) {
            filteredVideos = filteredVideos.filter { it.channelTitle == filterChannel }
        }
        if (filterCountry != null) {
            filteredVideos = filteredVideos.filter { it.country == filterCountry }
        }

        val channels = videos.map { it.channelTitle }.distinct()
        val countries = videos.mapNotNull { it.country }.distinct()

        _uiState.value = MainUiState.Success(sortVideos(filteredVideos), channels, countries)
    }

    private fun sortVideos(videos: List<YoutubeVideo>): List<YoutubeVideo> {
        return when (sortOrder) {
            SortOrder.PUBLICATION_DATE_ASC -> videos.sortedBy { it.publishedAt }
            SortOrder.PUBLICATION_DATE_DESC -> videos.sortedByDescending { it.publishedAt }
            SortOrder.RECORDING_DATE_ASC -> videos.sortedBy { it.recordingDate }
            SortOrder.RECORDING_DATE_DESC -> videos.sortedByDescending { it.recordingDate }
        }
    }
}

sealed class MainUiState {
    object Loading : MainUiState()
    data class Success(
        val videos: List<YoutubeVideo>,
        val channels: List<String>,
        val countries: List<String>
    ) : MainUiState()
    data class Error(val message: String) : MainUiState()
}

enum class SortOrder {
    PUBLICATION_DATE_ASC,
    PUBLICATION_DATE_DESC,
    RECORDING_DATE_ASC,
    RECORDING_DATE_DESC
}
