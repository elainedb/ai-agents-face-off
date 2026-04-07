package dev.elainedb.ytdash_android_gemini.domain.usecase

import dev.elainedb.ytdash_android_gemini.domain.model.Video
import dev.elainedb.ytdash_android_gemini.domain.repository.YouTubeRepository
import kotlinx.coroutines.flow.Flow
import javax.inject.Inject

class GetVideosByChannel @Inject constructor(
    private val repository: YouTubeRepository
) {
    operator fun invoke(channelName: String): Flow<List<Video>> {
        return repository.getVideosFlow(channelName = channelName, country = null, sortBy = null)
    }
}
