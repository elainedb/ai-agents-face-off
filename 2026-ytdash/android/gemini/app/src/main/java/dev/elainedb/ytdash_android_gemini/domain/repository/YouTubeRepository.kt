package dev.elainedb.ytdash_android_gemini.domain.repository

import dev.elainedb.ytdash_android_gemini.core.error.Result
import dev.elainedb.ytdash_android_gemini.domain.model.Video
import kotlinx.coroutines.flow.Flow

interface YouTubeRepository {
    suspend fun fetchAndCacheVideos(channelIds: List<String>, forceRefresh: Boolean): Result<Unit>
    fun observeVideos(channelName: String?, country: String?, sortBy: String): Flow<List<Video>>
    fun observeDistinctCountries(): Flow<List<String>>
    fun observeDistinctChannels(): Flow<List<String>>
    fun observeTotalVideoCount(): Flow<Int>
    suspend fun getVideosWithLocation(): List<Video>
}
