package dev.elainedb.ytdash_android_gemini.repository

import android.content.Context
import android.util.Log
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext
import kotlinx.coroutines.Dispatchers
import dev.elainedb.ytdash_android_gemini.ConfigHelper
import dev.elainedb.ytdash_android_gemini.data.VideoDao
import dev.elainedb.ytdash_android_gemini.data.VideoDatabase
import dev.elainedb.ytdash_android_gemini.data.toEntity
import dev.elainedb.ytdash_android_gemini.data.toVideo
import dev.elainedb.ytdash_android_gemini.models.Video
import dev.elainedb.ytdash_android_gemini.models.mergeWithDetails
import dev.elainedb.ytdash_android_gemini.models.toVideo
import dev.elainedb.ytdash_android_gemini.network.YouTubeApiService
import dev.elainedb.ytdash_android_gemini.utils.LocationUtils
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit

class YouTubeRepository(private val context: Context) {
    private val TAG = "YouTubeRepository"
    private val apiKey = ConfigHelper.getYoutubeApiKey(context)
    private val videoDao: VideoDao = VideoDatabase.getDatabase(context).videoDao()
    
    private val json = Json { ignoreUnknownKeys = true }
    
    private val okHttpClient = OkHttpClient.Builder()
        .addInterceptor(HttpLoggingInterceptor().apply { level = HttpLoggingInterceptor.Level.BODY })
        .addInterceptor { chain ->
            val request = chain.request().newBuilder()
                .addHeader("X-Android-Package", context.packageName)
                // Add Cert header if required for restricted API key
                // .addHeader("X-Android-Cert", "SHA1")
                .build()
            chain.proceed(request)
        }
        .build()

    private val apiService = Retrofit.Builder()
        .baseUrl("https://www.googleapis.com/youtube/v3/")
        .client(okHttpClient)
        .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
        .build()
        .create(YouTubeApiService::class.java)

    private val channels = listOf(
        "UCynoa1DjwnvHAowA_jiMEAQ",
        "UCK0KOjX3beyB9nzonls0cuw",
        "UCACkIrvrGAQ7kuc0hMVwvmA",
        "UCtWRAKKvOEA0CXOue9BG8ZA"
    )

    private val CACHE_EXPIRY_HOURS = 24
    private val CACHE_EXPIRY_MILLIS = CACHE_EXPIRY_HOURS * 60 * 60 * 1000L

    suspend fun getLatestVideos(): List<Video> {
        val threshold = System.currentTimeMillis() - CACHE_EXPIRY_MILLIS
        val cachedEntities = videoDao.getVideosNewerThan(threshold)
        
        if (cachedEntities.isNotEmpty()) {
            Log.d(TAG, "Returning \${cachedEntities.size} cached videos.")
            return cachedEntities.map { it.toVideo() }
        }

        Log.d(TAG, "Cache miss or expired. Refreshing videos...")
        return refreshVideos()
    }

    suspend fun refreshVideos(): List<Video> {
        val allVideos = coroutineScope {
            channels.map { channelId ->
                async { fetchChannelVideos(channelId) }
            }.awaitAll().flatten()
        }

        val enrichedVideos = enrichVideoDetails(allVideos)
        
        val cacheTimestamp = System.currentTimeMillis()
        videoDao.deleteAllVideos()
        videoDao.insertVideos(enrichedVideos.map { it.toEntity(cacheTimestamp) })
        
        return enrichedVideos
    }

    fun getVideosWithFiltersAndSort(channelName: String?, country: String?, sortBy: String): Flow<List<Video>> {
        return videoDao.getVideosWithFiltersAndSort(channelName, country, sortBy).map { list -> list.map { it.toVideo() } }
    }

    fun getDistinctCountries(): Flow<List<String>> = videoDao.getDistinctCountries()

    fun getDistinctChannels(): Flow<List<String>> = videoDao.getDistinctChannels()

    suspend fun getVideosWithLocation(): List<Video> {
        return withContext(Dispatchers.IO) {
            videoDao.getVideosWithLocation().map { it.toVideo() }
        }
    }

    private suspend fun fetchChannelVideos(channelId: String): List<Video> {
        val videos = mutableListOf<Video>()
        var pageToken: String? = null
        var pageCount = 0

        try {
            do {
                val response = apiService.searchVideos(
                    channelId = channelId,
                    pageToken = pageToken,
                    key = apiKey
                )
                videos.addAll(response.items.map { it.toVideo() })
                pageToken = response.nextPageToken
                pageCount++
            } while (pageToken != null && pageCount < 5)
        } catch (e: Exception) {
            Log.e(TAG, "Error fetching videos for channel \$channelId", e)
        }
        
        return videos
    }

    private suspend fun enrichVideoDetails(videos: List<Video>): List<Video> {
        if (videos.isEmpty()) return emptyList()
        val enriched = mutableListOf<Video>()
        val chunkedIds = videos.map { it.id }.chunked(50)
        
        try {
            for (chunk in chunkedIds) {
                val idString = chunk.joinToString(",")
                val response = apiService.getVideoDetails(id = idString, key = apiKey)
                
                val detailsMap = response.items.associateBy { it.id }
                
                for (video in videos.filter { chunk.contains(it.id) }) {
                    val detail = detailsMap[video.id]
                    if (detail != null) {
                        var city: String? = null
                        var country: String? = null
                        val loc = detail.recordingDetails?.location
                        if (loc != null) {
                            val cityAndCountry = LocationUtils.getCityAndCountry(context, loc.latitude, loc.longitude)
                            city = cityAndCountry.first
                            country = cityAndCountry.second
                        }
                        enriched.add(video.mergeWithDetails(detail, city, country))
                    } else {
                        enriched.add(video)
                    }
                }
            }
        } catch (e: Exception) {
            Log.e(TAG, "Error enriching video details", e)
            return videos
        }
        return enriched
    }
}
