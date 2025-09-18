package dev.elainedb.android_gemini.domain.youtube

import javax.inject.Inject

class GetYoutubeVideosUseCase @Inject constructor(
    private val youtubeRepository: YoutubeRepository
) {
    suspend operator fun invoke(): List<YoutubeVideo> {
        val channelIds = listOf(
            "UCynoa1DjwnvHAowA_jiMEAQ",
            "UCK0KOjX3beyB9nzonls0cuw",
            "UCACkIrvrGAQ7kuc0hMVwvmA",
            "UCtWRAKKvOEA0CXOue9BG8ZA"
        )
        return youtubeRepository.getVideos(channelIds)
    }
}
