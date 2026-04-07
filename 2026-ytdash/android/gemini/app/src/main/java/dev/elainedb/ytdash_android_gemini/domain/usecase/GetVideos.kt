package dev.elainedb.ytdash_android_gemini.domain.usecase

import dev.elainedb.ytdash_android_gemini.core.error.Result
import dev.elainedb.ytdash_android_gemini.core.usecases.UseCase
import dev.elainedb.ytdash_android_gemini.domain.repository.YouTubeRepository
import javax.inject.Inject

data class GetVideosParams(val channelIds: List<String>, val forceRefresh: Boolean)

class GetVideos @Inject constructor(
    private val repository: YouTubeRepository
) : UseCase<Unit, GetVideosParams>() {
    override suspend fun invoke(params: GetVideosParams): Result<Unit> {
        return repository.getVideos(params.channelIds, params.forceRefresh)
    }
}
