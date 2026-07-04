package com.example.ytdash.ui.home

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.ytdash.data.Video
import com.example.ytdash.data.VideoRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

sealed interface HomeUiState {
    data object Loading : HomeUiState
    data class Content(
        val videos: List<Video>, 
        val allCategories: List<String>,
        val currentCategory: String? = null,
        val currentSort: SortOption = SortOption.DateDesc,
        val totalCount: Int = 0
    ) : HomeUiState
    data class Error(val message: String) : HomeUiState
}

enum class SortOption(val label: String) {
    DateDesc("Date — newest"),
    DateAsc("Date — oldest"),
    TitleAsc("Title (A-Z)"),
    TitleDesc("Title (Z-A)")
}

class HomeViewModel(private val repository: VideoRepository) : ViewModel() {

    private val _uiState = MutableStateFlow<HomeUiState>(HomeUiState.Loading)
    val uiState: StateFlow<HomeUiState> = _uiState.asStateFlow()

    private var allVideos = emptyList<Video>()
    private var currentCategory: String? = null
    private var currentSort: SortOption = SortOption.DateDesc

    init {
        loadVideos()
    }

    fun loadVideos(forceRefresh: Boolean = false) {
        viewModelScope.launch {
            _uiState.value = HomeUiState.Loading
            try {
                allVideos = repository.getVideos(forceRefresh)
                updateContentState()
            } catch (e: Exception) {
                _uiState.value = HomeUiState.Error(e.message ?: "Unknown error")
            }
        }
    }

    fun setCategory(category: String?) {
        currentCategory = category
        updateContentState()
    }

    fun setSort(sort: SortOption) {
        currentSort = sort
        updateContentState()
    }

    private fun updateContentState() {
        var filtered = if (currentCategory != null) {
            allVideos.filter { it.category.equals(currentCategory, ignoreCase = true) }
        } else {
            allVideos
        }

        filtered = when (currentSort) {
            SortOption.DateDesc -> filtered.sortedByDescending { it.publishedAt }
            SortOption.DateAsc -> filtered.sortedBy { it.publishedAt }
            SortOption.TitleAsc -> filtered.sortedBy { it.title }
            SortOption.TitleDesc -> filtered.sortedByDescending { it.title }
        }

        val categories = allVideos.map { it.category }.distinct()
        _uiState.value = HomeUiState.Content(filtered, categories, currentCategory, currentSort, allVideos.size)
    }
}

class HomeViewModelFactory(private val repository: VideoRepository) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        return HomeViewModel(repository) as T
    }
}
