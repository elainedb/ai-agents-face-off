package dev.elainedb.ytdash_android_gemini.usecases

import dev.elainedb.ytdash_android_gemini.core.error.Result
import dev.elainedb.ytdash_android_gemini.core.usecases.UseCase
import dev.elainedb.ytdash_android_gemini.model.Video
import dev.elainedb.ytdash_android_gemini.repository.YouTubeRepository
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.first
import javax.inject.Inject

data class GetVideosParams(val channelIds: List<String>, val forceRefresh: Boolean)

class GetVideos @Inject constructor(
    private val repository: YouTubeRepository
) : UseCase<List<Video>, GetVideosParams>() {
    override suspend fun invoke(params: GetVideosParams): Result<List<Video>> {
        return repository.getVideos(params.channelIds, params.forceRefresh)
    }
}

class GetVideosByChannel @Inject constructor(
    private val repository: YouTubeRepository
) : UseCase<List<Video>, String>() {
    override suspend fun invoke(params: String): Result<List<Video>> {
        return try {
            val videos = repository.getVideosWithFiltersAndSort(params, null, null).first()
            Result.Success(videos)
        } catch (e: Exception) {
            Result.Error(dev.elainedb.ytdash_android_gemini.core.error.Failure.Unexpected(e.message ?: "Unknown Error"))
        }
    }
}

class GetVideosByCountry @Inject constructor(
    private val repository: YouTubeRepository
) : UseCase<List<Video>, String>() {
    override suspend fun invoke(params: String): Result<List<Video>> {
        return try {
            val videos = repository.getVideosWithFiltersAndSort(null, params, null).first()
            Result.Success(videos)
        } catch (e: Exception) {
            Result.Error(dev.elainedb.ytdash_android_gemini.core.error.Failure.Unexpected(e.message ?: "Unknown Error"))
        }
    }
}