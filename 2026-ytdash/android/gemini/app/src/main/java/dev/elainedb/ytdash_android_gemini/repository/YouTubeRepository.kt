package dev.elainedb.ytdash_android_gemini.repository

import android.content.Context
import dev.elainedb.ytdash_android_gemini.core.error.Failure
import dev.elainedb.ytdash_android_gemini.core.error.Result
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
import javax.inject.Inject
import javax.inject.Singleton

interface YouTubeRepository {
    suspend fun getVideos(channelIds: List<String>, forceRefresh: Boolean): Result<List<Video>>
    fun getVideosWithFiltersAndSort(channelName: String?, country: String?, sortBy: String?): Flow<List<Video>>
    fun getAvailableCountries(): Flow<List<String>>
    fun getAvailableChannels(): Flow<List<String>>
    fun getTotalVideoCount(): Flow<Int>
}

@Singleton
class YouTubeRepositoryImpl @Inject constructor(
    private val apiService: YouTubeApiService,
    private val videoDao: VideoDao,
    @dagger.hilt.android.qualifiers.ApplicationContext private val context: Context
) : YouTubeRepository {

    private val CACHE_EXPIRY_HOURS = 24L

    override suspend fun getVideos(channelIds: List<String>, forceRefresh: Boolean): Result<List<Video>> {
        return try {
            val threshold = System.currentTimeMillis() - (CACHE_EXPIRY_HOURS * 60 * 60 * 1000)
            
            if (!forceRefresh) {
                val cached = videoDao.getVideosNewerThan(threshold)
                if (cached.isNotEmpty()) {
                    return Result.Success(cached.map { it.toVideo() })
                }
            }

            val apiKey = ConfigHelper.getYouTubeApiKey(context)
            val allVideos = mutableListOf<Video>()

            coroutineScope {
                val deferreds = channelIds.map { channelId ->
                    async {
                        val channelVideos = mutableListOf<Video>()
                        var pageToken: String? = null
                        do {
                            val response = apiService.searchVideos(
                                channelId = channelId,
                                pageToken = pageToken,
                                key = apiKey
                            )
                            val fetchedVideos = response.items.map { it.toVideo() }
                            
                            // Fetch details
                            val videoIds = fetchedVideos.joinToString(",") { it.id }
                            if (videoIds.isNotEmpty()) {
                                val detailsResponse = apiService.getVideoDetails(id = videoIds, key = apiKey)
                                val detailedVideos = fetchedVideos.map { video ->
                                    val details = detailsResponse.items.find { it.id == video.id }
                                    if (details != null) {
                                        val lat = details.recordingDetails?.location?.latitude
                                        val lon = details.recordingDetails?.location?.longitude
                                        var city: String? = null
                                        var country: String? = null
                                        if (lat != null && lon != null) {
                                            val loc = LocationUtils.reverseGeocode(context, lat, lon, video.description)
                                            city = loc.first
                                            country = loc.second
                                        }
                                        video.mergeWithDetails(details, city, country)
                                    } else {
                                        video
                                    }
                                }
                                channelVideos.addAll(detailedVideos)
                            }
                            pageToken = response.nextPageToken
                        } while (pageToken != null)
                        channelVideos
                    }
                }
                deferreds.awaitAll().forEach { allVideos.addAll(it) }
            }

            val cacheTime = System.currentTimeMillis()
            videoDao.deleteOldVideos(threshold)
            videoDao.insertVideos(allVideos.map { it.toEntity(cacheTime) })

            Result.Success(allVideos)
        } catch (e: Exception) {
            Result.Error(Failure.Network(e.message ?: "Network error"))
        }
    }

    override fun getVideosWithFiltersAndSort(channelName: String?, country: String?, sortBy: String?): Flow<List<Video>> {
        return videoDao.getVideosWithFiltersAndSort(channelName, country, sortBy).map { list -> list.map { it.toVideo() } }
    }

    override fun getAvailableCountries(): Flow<List<String>> = videoDao.getDistinctCountries()

    override fun getAvailableChannels(): Flow<List<String>> = videoDao.getDistinctChannels()
    
    override fun getTotalVideoCount(): Flow<Int> = videoDao.getTotalVideoCount()
}