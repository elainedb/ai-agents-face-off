package dev.elainedb.ytdash_android_gemini.ui.viewmodel

import dev.elainedb.ytdash_android_gemini.data.model.Video

sealed class VideoListUiState {
    object Loading : VideoListUiState()
    object Empty : VideoListUiState()
    data class Success(val videos: List<Video>, val totalCount: Int) : VideoListUiState()
    data class Error(val message: String) : VideoListUiState()
}
