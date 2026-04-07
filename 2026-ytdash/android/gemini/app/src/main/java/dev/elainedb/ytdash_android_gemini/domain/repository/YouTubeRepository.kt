package dev.elainedb.ytdash_android_gemini.domain.repository

import dev.elainedb.ytdash_android_gemini.core.error.Result
import dev.elainedb.ytdash_android_gemini.domain.model.Video
import kotlinx.coroutines.flow.Flow

interface YouTubeRepository {
    suspend fun getVideos(channelIds: List<String>, forceRefresh: Boolean): Result<Unit>
    fun getVideosFlow(channelName: String?, country: String?, sortBy: String?): Flow<List<Video>>
    fun getAvailableCountries(): Flow<List<String>>
    fun getAvailableChannels(): Flow<List<String>>
    fun getVideosWithLocation(): Flow<List<Video>>
    fun getTotalVideoCount(): Flow<Int>
}
