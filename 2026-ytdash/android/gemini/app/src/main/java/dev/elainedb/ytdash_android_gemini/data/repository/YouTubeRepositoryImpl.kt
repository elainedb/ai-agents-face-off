package dev.elainedb.ytdash_android_gemini.data.repository

import android.content.Context
import dagger.hilt.android.qualifiers.ApplicationContext
import dev.elainedb.ytdash_android_gemini.core.error.Failure
import dev.elainedb.ytdash_android_gemini.core.error.Result
import dev.elainedb.ytdash_android_gemini.data.database.VideoDao
import dev.elainedb.ytdash_android_gemini.data.database.toEntity
import dev.elainedb.ytdash_android_gemini.data.database.toVideo
import dev.elainedb.ytdash_android_gemini.data.network.YouTubeApiService
import dev.elainedb.ytdash_android_gemini.data.network.model.toVideo
import dev.elainedb.ytdash_android_gemini.domain.model.Video
import dev.elainedb.ytdash_android_gemini.domain.repository.YouTubeRepository
import dev.elainedb.ytdash_android_gemini.utils.ConfigHelper
import dev.elainedb.ytdash_android_gemini.utils.LocationUtils
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import javax.inject.Inject

class YouTubeRepositoryImpl @Inject constructor(
    private val apiService: YouTubeApiService,
    private val videoDao: VideoDao,
    private val locationUtils: LocationUtils,
    private val configHelper: ConfigHelper,
    @ApplicationContext private val context: Context
) : YouTubeRepository {

    override suspend fun getVideos(channelIds: List<String>, forceRefresh: Boolean): Result<Unit> {
        try {
            val cacheThreshold = System.currentTimeMillis() - 24 * 60 * 60 * 1000L
            if (!forceRefresh) {
                val cachedVideos = videoDao.getVideosNewerThan(cacheThreshold)
                if (cachedVideos.isNotEmpty()) {
                    return Result.Success(Unit)
                }
            }

            val apiKey = configHelper.getYouTubeApiKey(context)
            if (apiKey.isEmpty()) return Result.Error(Failure.Validation("YouTube API key is missing"))

            coroutineScope {
                val allVideosDeferred = channelIds.map { channelId ->
                    async {
                        fetchChannelVideos(channelId, apiKey)
                    }
                }
                val allVideos = allVideosDeferred.awaitAll().flatten()

                val timestamp = System.currentTimeMillis()
                videoDao.deleteOldVideos(cacheThreshold)

                // Batch fetching video details (max 50 per request)
                val enrichedVideos = fetchAndMergeVideoDetails(allVideos, apiKey)

                val entities = enrichedVideos.map { it.toEntity(timestamp) }
                videoDao.insertVideos(entities)
            }
            return Result.Success(Unit)
        } catch (e: Exception) {
            return Result.Error(Failure.Unexpected(e.message ?: "Failed to fetch videos"))
        }
    }

    private suspend fun fetchChannelVideos(channelId: String, apiKey: String): List<Video> {
        val videos = mutableListOf<Video>()
        var pageToken: String? = null
        do {
            val response = apiService.searchVideos(
                channelId = channelId,
                pageToken = pageToken,
                key = apiKey
            )
            videos.addAll(response.items.filter { it.id.videoId != null }.map { it.toVideo() })
            pageToken = response.nextPageToken
        } while (pageToken != null)
        return videos
    }

    private suspend fun fetchAndMergeVideoDetails(videos: List<Video>, apiKey: String): List<Video> {
        val chunkedIds = videos.map { it.id }.chunked(50)
        val enrichedVideosMap = mutableMapOf<String, Video>()

        for (chunk in chunkedIds) {
            val response = apiService.getVideoDetails(
                id = chunk.joinToString(","),
                key = apiKey
            )
            for (item in response.items) {
                val tags = item.snippet?.tags ?: emptyList()
                val lat = item.recordingDetails?.location?.latitude
                val lng = item.recordingDetails?.location?.longitude
                val recDate = item.recordingDetails?.recordingDate
                
                val originalVideo = videos.find { it.id == item.id }
                if (originalVideo != null) {
                    var city: String? = null
                    var country: String? = null
                    if (lat != null && lng != null) {
                        val location = locationUtils.getCityAndCountry(lat, lng, originalVideo.description)
                        city = location.first
                        country = location.second
                    }
                    val enriched = originalVideo.mergeWithDetails(tags, lat, lng, recDate)
                        .copy(locationCity = city, locationCountry = country)
                    enrichedVideosMap[item.id] = enriched
                }
            }
        }
        
        return videos.map { enrichedVideosMap[it.id] ?: it }
    }

    override fun getVideosFlow(
        channelName: String?,
        country: String?,
        sortBy: String?
    ): Flow<List<Video>> {
        return videoDao.getVideosWithFiltersAndSort(channelName, country, sortBy)
            .map { list -> list.map { it.toVideo() } }
    }

    override fun getAvailableCountries(): Flow<List<String>> = videoDao.getDistinctCountries()

    override fun getAvailableChannels(): Flow<List<String>> = videoDao.getDistinctChannels()

    override fun getVideosWithLocation(): Flow<List<Video>> {
        return videoDao.getVideosWithLocation().map { list -> list.map { it.toVideo() } }
    }

    override fun getTotalVideoCount(): Flow<Int> = videoDao.getTotalVideoCount()
}
