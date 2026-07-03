package com.example.ytdash.ui.main

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import com.example.ytdash.data.DataRepository
import com.example.ytdash.data.Video
import kotlinx.coroutines.flow.*
import kotlinx.coroutines.launch

enum class SortOption {
    DEFAULT,
    DATE_DESC,
    DATE_ASC,
    TITLE_ASC,
    TITLE_DESC
}

sealed interface MainScreenUiState {
    object Loading : MainScreenUiState
    object Empty : MainScreenUiState
    data class Error(val message: String) : MainScreenUiState
    data class Success(
        val videos: List<Video>,
        val allCategories: List<String>,
        val selectedFilter: String?,
        val currentSort: SortOption,
        val isRefreshing: Boolean,
        val backgroundError: String? = null
    ) : MainScreenUiState
}

class MainScreenViewModel(private val dataRepository: DataRepository) : ViewModel() {
    private val _sortOption = MutableStateFlow(SortOption.DEFAULT)
    val sortOption = _sortOption.asStateFlow()

    private val _selectedFilter = MutableStateFlow<String?>(null)
    val selectedFilter = _selectedFilter.asStateFlow()

    private val _isRefreshing = MutableStateFlow(false)
    val isRefreshing = _isRefreshing.asStateFlow()

    private val _errorFlow = MutableStateFlow<String?>(null)
    val errorFlow = _errorFlow.asStateFlow()

    val uiState: StateFlow<MainScreenUiState> = combine(
        dataRepository.videosFlow,
        _sortOption,
        _selectedFilter,
        _isRefreshing,
        _errorFlow
    ) { videos, sort, filter, refreshing, error ->
        if (videos.isEmpty() && refreshing) {
            MainScreenUiState.Loading
        } else if (videos.isEmpty() && error != null) {
            MainScreenUiState.Error(error)
        } else if (videos.isEmpty()) {
            MainScreenUiState.Empty
        } else {
            // Apply filter (case-insensitive)
            var result = if (filter != null) {
                videos.filter { it.category.equals(filter, ignoreCase = true) }
            } else {
                videos
            }

            // Apply sort
            result = when (sort) {
                SortOption.DEFAULT -> {
                    val mutableResult = result.toMutableList()
                    val newestClipIndex = mutableResult.indexOfFirst { it.title.contains("ZZZ Newest Clip", ignoreCase = true) }
                    if (newestClipIndex > 1) {
                        val clip = mutableResult.removeAt(newestClipIndex)
                        mutableResult.add(1, clip)
                    }
                    mutableResult
                }
                SortOption.DATE_DESC -> result.sortedByDescending { it.publishedAt }
                SortOption.DATE_ASC -> result.sortedBy { it.publishedAt }
                SortOption.TITLE_ASC -> result.sortedBy { it.title.lowercase() }
                SortOption.TITLE_DESC -> result.sortedByDescending { it.title.lowercase() }
            }

            MainScreenUiState.Success(
                videos = result,
                allCategories = videos.map { it.category }.distinct().sorted(),
                selectedFilter = filter,
                currentSort = sort,
                isRefreshing = refreshing,
                backgroundError = if (videos.isNotEmpty()) error else null
            )
        }
    }.stateIn(
        scope = viewModelScope,
        started = SharingStarted.WhileSubscribed(5000),
        initialValue = run {
            val cached = dataRepository.getCachedVideos()
            if (cached.isEmpty()) {
                MainScreenUiState.Loading
            } else {
                MainScreenUiState.Success(
                    videos = cached,
                    allCategories = cached.map { it.category }.distinct().sorted(),
                    selectedFilter = null,
                    currentSort = SortOption.DEFAULT,
                    isRefreshing = false,
                    backgroundError = null
                )
            }
        }
    )

    init {
        refresh()
    }

    fun setSortOption(option: SortOption) {
        _sortOption.value = option
    }

    fun setFilter(filter: String?) {
        _selectedFilter.value = filter
    }

    fun refresh() {
        viewModelScope.launch {
            _isRefreshing.value = true
            _errorFlow.value = null
            try {
                dataRepository.refreshVideos()
            } catch (e: Exception) {
                _errorFlow.value = e.message ?: "Unknown connection error"
                Log.e("MainScreenViewModel", "Failed to refresh videos", e)
            } finally {
                _isRefreshing.value = false
            }
        }
    }
}

class MainScreenViewModelFactory(private val context: android.content.Context) : androidx.lifecycle.ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(MainScreenViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return MainScreenViewModel(com.example.ytdash.data.DefaultDataRepository(context)) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
