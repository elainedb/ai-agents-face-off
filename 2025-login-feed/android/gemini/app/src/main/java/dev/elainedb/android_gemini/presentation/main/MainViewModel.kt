package dev.elainedb.android_gemini.presentation.main

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dagger.hilt.android.lifecycle.HiltViewModel
import dev.elainedb.android_gemini.domain.youtube.GetYoutubeVideosUseCase
import dev.elainedb.android_gemini.domain.youtube.YoutubeVideo
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch
import javax.inject.Inject

@HiltViewModel
class MainViewModel @Inject constructor(
    private val getYoutubeVideosUseCase: GetYoutubeVideosUseCase
) : ViewModel() {

    private val _uiState = MutableStateFlow<MainUiState>(MainUiState.Loading)
    val uiState = _uiState.asStateFlow()

    fun getVideos() {
        viewModelScope.launch {
            try {
                val videos = getYoutubeVideosUseCase()
                _uiState.value = MainUiState.Success(videos)
            } catch (e: Exception) {
                Log.e("MainViewModel", "Error getting videos", e)
                _uiState.value = MainUiState.Error(e.message ?: "An unknown error occurred")
            }
        }
    }
}

sealed class MainUiState {
    object Loading : MainUiState()
    data class Success(val videos: List<YoutubeVideo>) : MainUiState()
    data class Error(val message: String) : MainUiState()
}
