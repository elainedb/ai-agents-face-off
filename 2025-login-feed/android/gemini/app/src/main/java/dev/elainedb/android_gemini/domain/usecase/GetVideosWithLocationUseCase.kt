package dev.elainedb.android_gemini.domain.usecase

import dev.elainedb.android_gemini.data.database.YoutubeVideoWithTagsAndLocation
import dev.elainedb.android_gemini.domain.youtube.YoutubeRepository

class GetVideosWithLocationUseCase(private val youtubeRepository: YoutubeRepository) {
    suspend operator fun invoke(): List<YoutubeVideoWithTagsAndLocation> {
        return youtubeRepository.getVideosWithLocation()
    }
}
