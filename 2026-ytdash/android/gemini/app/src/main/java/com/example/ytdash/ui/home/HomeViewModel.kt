package com.example.ytdash.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.ytdash.data.repository.AuthRepository
import com.example.ytdash.data.repository.VideoRepository
import com.example.ytdash.domain.models.Video
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

sealed class HomeUiState {
    data object Loading : HomeUiState()
    data class Content(val videos: List<Video>) : HomeUiState()
    data class Error(val message: String) : HomeUiState()
}

class HomeViewModel(
    private val videoRepository: VideoRepository,
    private val authRepository: AuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<HomeUiState>(HomeUiState.Loading)
    val uiState: StateFlow<HomeUiState> = _uiState
    
    // Exposed for map
    private val _videos = MutableStateFlow<List<Video>>(emptyList())
    val videos: StateFlow<List<Video>> = _videos

    private var allVideos = listOf<Video>()
    val allCategories: List<String>
        get() = allVideos.map { it.category }.distinct()

    init {
        loadVideos()
    }

    fun loadVideos() {
        _uiState.value = HomeUiState.Loading
        viewModelScope.launch {
            val result = videoRepository.fetchVideos()
            if (result.isSuccess) {
                allVideos = result.getOrNull() ?: emptyList()
                _videos.value = allVideos
                _uiState.value = HomeUiState.Content(allVideos)
            } else {
                _uiState.value = HomeUiState.Error(result.exceptionOrNull()?.message ?: "Unknown error")
            }
        }
    }
    
    fun applyFilter(category: String?) {
        val filtered = if (category == null) {
            allVideos
        } else {
            allVideos.filter { it.category == category }
        }
        _videos.value = filtered
        _uiState.value = HomeUiState.Content(filtered)
    }
    
    fun applySort(descending: Boolean) {
        val sorted = if (descending) {
            _videos.value.sortedByDescending { it.publishedAt }
        } else {
            _videos.value.sortedBy { it.publishedAt }
        }
        _videos.value = sorted
        _uiState.value = HomeUiState.Content(sorted)
    }

    companion object {
        fun provideFactory(
            videoRepository: VideoRepository,
            authRepository: AuthRepository
        ): ViewModelProvider.Factory = object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T {
                return HomeViewModel(videoRepository, authRepository) as T
            }
        }
    }
}
