package com.example.ytdash.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.ytdash.data.model.VideoEntity
import com.example.ytdash.data.repository.VideoRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class HomeViewModel(
    private val repository: VideoRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow(HomeUiState())
    val uiState: StateFlow<HomeUiState> = _uiState

    init {
        loadVideos()
    }
    
    fun getConfig() = repository.appConfig
    fun getChannels() = repository.channels

    fun loadVideos() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isLoading = true, error = null)
            try {
                var videos = repository.getVideos()
                if (videos.isEmpty()) {
                    repository.refreshVideos()
                    videos = repository.getVideos()
                } else {
                    // Refresh in background
                    launch {
                        try {
                            repository.refreshVideos()
                            val refreshed = repository.getVideos()
                            applyFiltersAndSort(refreshed)
                        } catch (e: Exception) {
                            // Silent fail for background refresh, keep cached
                        }
                    }
                }
                applyFiltersAndSort(videos)
            } catch (e: Exception) {
                android.util.Log.e("YTDash", "Error loading videos", e)
                _uiState.value = _uiState.value.copy(isLoading = false, error = e.message ?: "Unknown error")
            }
        }
    }

    fun refresh() {
        viewModelScope.launch {
            _uiState.value = _uiState.value.copy(isRefreshing = true, error = null)
            try {
                repository.refreshVideos()
                val videos = repository.getVideos()
                applyFiltersAndSort(videos)
            } catch (e: Exception) {
                _uiState.value = _uiState.value.copy(isRefreshing = false, error = e.message ?: "Unknown error")
            }
        }
    }

    fun setFilter(category: String?) {
        _uiState.value = _uiState.value.copy(selectedCategory = category)
        applyFiltersAndSort(_uiState.value.allVideos)
    }

    fun setSortOrder(order: SortOrder) {
        _uiState.value = _uiState.value.copy(sortOrder = order)
        applyFiltersAndSort(_uiState.value.allVideos)
    }

    private fun applyFiltersAndSort(allVideos: List<VideoEntity>) {
        val state = _uiState.value
        var filtered = allVideos
        if (state.selectedCategory != null) {
            filtered = filtered.filter { it.category == state.selectedCategory }
        }
        
        filtered = when (state.sortOrder) {
            SortOrder.ASC -> filtered.sortedBy { it.publishedAt }
            SortOrder.DESC -> filtered.sortedByDescending { it.publishedAt }
            SortOrder.NONE -> filtered
        }
        
        android.util.Log.d("YTDash", "Sorted videos, first is: ${filtered.firstOrNull()?.title}")

        _uiState.value = state.copy(
            isLoading = false,
            isRefreshing = false,
            allVideos = allVideos,
            videos = filtered
        )
    }
}

enum class SortOrder {
    NONE, ASC, DESC
}

data class HomeUiState(
    val isLoading: Boolean = false,
    val isRefreshing: Boolean = false,
    val error: String? = null,
    val allVideos: List<VideoEntity> = emptyList(),
    val videos: List<VideoEntity> = emptyList(),
    val selectedCategory: String? = null,
    val sortOrder: SortOrder = SortOrder.NONE
)
