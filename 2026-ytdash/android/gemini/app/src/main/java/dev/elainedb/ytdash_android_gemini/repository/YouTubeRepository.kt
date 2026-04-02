package dev.elainedb.ytdash_android_gemini.repository

import android.content.Context
import android.util.Log
import dev.elainedb.ytdash_android_gemini.database.VideoDao
import dev.elainedb.ytdash_android_gemini.database.toEntity
import dev.elainedb.ytdash_android_gemini.database.toVideo
import dev.elainedb.ytdash_android_gemini.model.Video
import dev.elainedb.ytdash_android_gemini.model.mergeWithDetails
import dev.elainedb.ytdash_android_gemini.model.toVideo
import dev.elainedb.ytdash_android_gemini.network.YouTubeApiService
import dev.elainedb.ytdash_android_gemini.utils.ConfigHelper
import dev.elainedb.ytdash_android_gemini.utils.LocationUtils
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class YouTubeRepository(
    private val apiService: YouTubeApiService,
    private val videoDao: VideoDao,
    private val context: Context
) {
    private val channelIds = listOf(
        "UCynoa1DjwnvHAowA_jiMEAQ",
        "UCK0KOjX3beyB9nzonls0cuw",
        "UCACkIrvrGAQ7kuc0hMVwvmA",
        "UCtWRAKKvOEA0CXOue9BG8ZA"
    )

    private val CACHE_EXPIRY_HOURS = 24L

    fun getVideos(
        channelName: String?,
        country: String?,
        sortBy: String
    ): Flow<List<Video>> {
        val actualChannelName = if (channelName == "All Channels") null else channelName
        val actualCountry = if (country == "All Countries") null else country
        
        return videoDao.getVideosWithFiltersAndSort(actualChannelName, actualCountry, sortBy)
            .map { entities -> entities.map { it.toVideo() } }
    }

    suspend fun refreshVideos() {
        try {
            val apiKey = ConfigHelper.getYoutubeApiKey()
            val allVideos = coroutineScope {
                channelIds.map { channelId ->
                    async { fetchChannelVideos(channelId, apiKey) }
                }.awaitAll().flatten()
            }

            if (allVideos.isNotEmpty()) {
                val enrichedVideos = enrichVideos(allVideos, apiKey)
                val timestamp = System.currentTimeMillis()
                videoDao.insertVideos(enrichedVideos.map { it.toEntity(timestamp) })
                videoDao.deleteOldVideos(timestamp - CACHE_EXPIRY_HOURS * 60 * 60 * 1000)
            }
        } catch (e: Exception) {
            Log.e("YouTubeRepository", "Failed to refresh videos", e)
            throw e
        }
    }

    private suspend fun fetchChannelVideos(channelId: String, apiKey: String): List<Video> {
        val videos = mutableListOf<Video>()
        var nextPageToken: String? = null
        var pagesFetched = 0
        
        while (pagesFetched < 5) {
            val response = apiService.searchVideos(
                channelId = channelId,
                pageToken = nextPageToken,
                apiKey = apiKey
            )
            videos.addAll(response.items.map { it.toVideo() })
            nextPageToken = response.nextPageToken
            pagesFetched++
            if (nextPageToken == null) break
        }
        return videos
    }

    private suspend fun enrichVideos(videos: List<Video>, apiKey: String): List<Video> {
        return videos.chunked(50).flatMap { chunk ->
            val ids = chunk.joinToString(",") { it.id }
            val detailsResponse = apiService.getVideoDetails(ids = ids, apiKey = apiKey)
            val detailsMap = detailsResponse.items.associateBy { it.id }
            
            chunk.map { video ->
                val details = detailsMap[video.id]
                val enriched = if (details != null) video.mergeWithDetails(details) else video
                
                if (enriched.locationLatitude != null && enriched.locationLongitude != null) {
                    val (city, country) = LocationUtils.reverseGeocode(
                        context, 
                        enriched.locationLatitude, 
                        enriched.locationLongitude
                    )
                    enriched.copy(locationCity = city, locationCountry = country)
                } else {
                    enriched
                }
            }
        }
    }

    suspend fun getVideosWithLocation(): List<Video> {
        return videoDao.getVideosWithLocation().map { it.toVideo() }
    }

    fun getDistinctCountries(): Flow<List<String>> = videoDao.getDistinctCountries()
    fun getDistinctChannels(): Flow<List<String>> = videoDao.getDistinctChannels()
    fun getTotalVideoCount(): Flow<Int> = videoDao.getTotalVideoCount()

    suspend fun isCacheValid(): Boolean {
        val threshold = System.currentTimeMillis() - CACHE_EXPIRY_HOURS * 60 * 60 * 1000
        return videoDao.getVideosNewerThan(threshold).isNotEmpty()
    }
}
