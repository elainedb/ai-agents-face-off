package dev.elainedb.ytdash_android_gemini.repository

import android.content.Context
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

    private val apiKey = ConfigHelper.getYoutubeApiKey(context)

    private val channelIds = listOf(
        "UCynoa1DjwnvHAowA_jiMEAQ",
        "UCK0KOjX3beyB9nzonls0cuw",
        "UCACkIrvrGAQ7kuc0hMVwvmA",
        "UCtWRAKKvOEA0CXOue9BG8ZA"
    )

    private val CACHE_EXPIRY_HOURS = 24
    private val CACHE_EXPIRY_MILLIS = CACHE_EXPIRY_HOURS * 60 * 60 * 1000L

    suspend fun getLatestVideos() {
        val threshold = System.currentTimeMillis() - CACHE_EXPIRY_MILLIS
        val cached = videoDao.getVideosNewerThan(threshold)
        if (cached.isEmpty()) {
            refreshVideos()
        }
    }

    suspend fun refreshVideos() {
        if (apiKey.isEmpty() || apiKey == "YOUR_YOUTUBE_API_KEY") return // Handle missing API key gracefully

        val allVideos = coroutineScope {
            channelIds.map { channelId ->
                async { fetchChannelVideos(channelId) }
            }.awaitAll().flatten()
        }

        val enrichedVideos = fetchVideoDetailsInBatches(allVideos)

        val videosWithLocation = enrichedVideos.map { video ->
            if (video.locationLatitude != null && video.locationLongitude != null) {
                val (city, country) = LocationUtils.getCityAndCountry(
                    context,
                    video.locationLatitude,
                    video.locationLongitude
                )
                video.copy(locationCity = city, locationCountry = country)
            } else {
                video
            }
        }

        val timestamp = System.currentTimeMillis()
        val entities = videosWithLocation.map { it.toEntity(timestamp) }

        videoDao.deleteAllVideos()
        videoDao.insertVideos(entities)
    }

    private suspend fun fetchChannelVideos(channelId: String): List<Video> {
        val videos = mutableListOf<Video>()
        var pageToken: String? = null
        var pageCount = 0

        try {
            while (pageCount < 5) {
                val response = apiService.searchVideos(
                    channelId = channelId,
                    pageToken = pageToken,
                    apiKey = apiKey
                )

                videos.addAll(response.items.map { it.toVideo() })
                pageToken = response.nextPageToken
                pageCount++

                if (pageToken == null) break
            }
        } catch (e: Exception) {
            e.printStackTrace()
        }

        return videos
    }

    private suspend fun fetchVideoDetailsInBatches(videos: List<Video>): List<Video> {
        val chunkedVideos = videos.chunked(50)
        val enrichedVideos = mutableListOf<Video>()

        for (chunk in chunkedVideos) {
            val ids = chunk.joinToString(",") { it.id }
            try {
                val response = apiService.getVideoDetails(id = ids, apiKey = apiKey)
                val detailsMap = response.items.associateBy { it.id }

                val enrichedChunk = chunk.map { video ->
                    val details = detailsMap[video.id]
                    video.mergeWithDetails(
                        tags = details?.snippet?.tags,
                        latitude = details?.recordingDetails?.location?.latitude,
                        longitude = details?.recordingDetails?.location?.longitude,
                        recordingDate = details?.recordingDetails?.recordingDate,
                        city = null,
                        country = null
                    )
                }
                enrichedVideos.addAll(enrichedChunk)
            } catch (e: Exception) {
                e.printStackTrace()
                enrichedVideos.addAll(chunk) // Fallback to basic details if details fetch fails
            }
        }

        return enrichedVideos
    }

    fun observeVideos(channelName: String?, country: String?, sortBy: String): Flow<List<Video>> {
        return videoDao.getVideosWithFiltersAndSort(channelName, country, sortBy)
            .map { entities -> entities.map { it.toVideo() } }
    }

    fun getDistinctCountries() = videoDao.getDistinctCountries()
    fun getDistinctChannels() = videoDao.getDistinctChannels()
    fun getTotalVideoCount() = videoDao.getTotalVideoCount()
}
