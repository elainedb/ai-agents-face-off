package dev.elainedb.android_gemini.presentation.map

import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.elainedb.android_gemini.data.database.YoutubeVideoWithTagsAndLocation
import dev.elainedb.android_gemini.domain.usecase.GetVideosWithLocationUseCase
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

class MapViewModel(private val getVideosWithLocationUseCase: GetVideosWithLocationUseCase) : ViewModel() {

    private val _videosWithLocation = MutableStateFlow<List<YoutubeVideoWithTagsAndLocation>>(emptyList())
    val videosWithLocation: StateFlow<List<YoutubeVideoWithTagsAndLocation>> = _videosWithLocation

    init {
        loadVideosWithLocation()
    }

    private fun loadVideosWithLocation() {
        viewModelScope.launch {
            _videosWithLocation.value = getVideosWithLocationUseCase()
        }
    }
}
