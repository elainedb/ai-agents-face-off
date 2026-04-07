package dev.elainedb.ytdash_android_gemini.data.repository

import android.content.Context
import dagger.hilt.android.qualifiers.ApplicationContext
import dev.elainedb.ytdash_android_gemini.core.error.Failure
import dev.elainedb.ytdash_android_gemini.core.error.Result
import dev.elainedb.ytdash_android_gemini.data.database.VideoDao
import dev.elainedb.ytdash_android_gemini.data.database.toEntity
import dev.elainedb.ytdash_android_gemini.data.database.toVideo
import dev.elainedb.ytdash_android_gemini.data.network.YouTubeApiService
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
    @ApplicationContext private val context: Context
) : YouTubeRepository {

    private val CACHE_EXPIRY_MS = 24 * 60 * 60 * 1000L // 24 hours

    override suspend fun fetchAndCacheVideos(channelIds: List<String>, forceRefresh: Boolean): Result<Unit> {
        return try {
            val threshold = System.currentTimeMillis() - CACHE_EXPIRY_MS
            val cached = videoDao.getVideosNewerThan(threshold)
            
            if (!forceRefresh && cached.isNotEmpty()) {
                return Result.Success(Unit)
            }

            coroutineScope {
                val videosLists = channelIds.map { channelId ->
                    async { fetchAllVideosForChannel(channelId) }
                }.awaitAll()

                val allVideos = videosLists.flatten()
                
                // Fetch details in batches of 50
                val enrichedVideos = allVideos.chunked(50).map { batch ->
                    val ids = batch.joinToString(",") { it.id }
                    val detailsResponse = apiService.getVideoDetails(ids = ids, key = ConfigHelper.youtubeApiKey)
                    
                    batch.map { video ->
                        val details = detailsResponse.items.find { it.id == video.id }
                        val loc = details?.recordingDetails?.location
                        var city: String? = null
                        var country: String? = null
                        
                        if (loc?.latitude != null && loc?.longitude != null) {
                            val cityCountry = LocationUtils.getCityCountry(context, loc.latitude, loc.longitude, loc.locationDescription)
                            city = cityCountry.first
                            country = cityCountry.second
                        }

                        video.mergeWithDetails(
                            tags = details?.snippet?.tags,
                            lat = loc?.latitude,
                            lng = loc?.longitude,
                            city = city,
                            country = country,
                            recDate = details?.recordingDetails?.recordingDate
                        )
                    }
                }.flatten()

                val timestamp = System.currentTimeMillis()
                val entities = enrichedVideos.map { it.toEntity(timestamp) }
                
                videoDao.insertVideos(entities)
            }
            Result.Success(Unit)
        } catch (e: Exception) {
            Result.Error(Failure.Network(e.message ?: "Unknown error fetching videos"))
        }
    }

    private suspend fun fetchAllVideosForChannel(channelId: String): List<Video> {
        val videos = mutableListOf<Video>()
        var pageToken: String? = null

        do {
            val response = apiService.searchVideos(
                channelId = channelId,
                pageToken = pageToken,
                key = ConfigHelper.youtubeApiKey
            )
            val batch = response.items.mapNotNull { it.toVideo() }
            videos.addAll(batch)
            pageToken = response.nextPageToken
        } while (pageToken != null)

        return videos
    }

    override fun observeVideos(channelName: String?, country: String?, sortBy: String): Flow<List<Video>> {
        return videoDao.getVideosWithFiltersAndSort(
            channelName = if (channelName == "All Channels") null else channelName,
            country = if (country == "All Countries") null else country,
            sortBy = sortBy
        ).map { entities -> entities.map { it.toVideo() } }
    }

    override fun observeDistinctCountries(): Flow<List<String>> {
        return videoDao.getDistinctCountries()
    }

    override fun observeDistinctChannels(): Flow<List<String>> {
        return videoDao.getDistinctChannels()
    }

    override fun observeTotalVideoCount(): Flow<Int> {
        return videoDao.getTotalVideoCount()
    }

    override suspend fun getVideosWithLocation(): List<Video> {
        return videoDao.getVideosWithLocation().map { it.toVideo() }
    }
}
