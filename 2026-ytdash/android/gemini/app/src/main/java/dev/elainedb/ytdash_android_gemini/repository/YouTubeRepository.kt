package dev.elainedb.ytdash_android_gemini.repository

import android.content.Context
import android.util.Log
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import dev.elainedb.ytdash_android_gemini.database.VideoDao
import dev.elainedb.ytdash_android_gemini.database.VideoDatabase
import dev.elainedb.ytdash_android_gemini.database.toEntity
import dev.elainedb.ytdash_android_gemini.database.toVideo
import dev.elainedb.ytdash_android_gemini.model.Video
import dev.elainedb.ytdash_android_gemini.model.toVideo
import dev.elainedb.ytdash_android_gemini.network.YouTubeApiService
import dev.elainedb.ytdash_android_gemini.utils.ConfigHelper
import dev.elainedb.ytdash_android_gemini.utils.LocationUtils
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit

class YouTubeRepository(private val context: Context) {
    
    private val apiKey = ConfigHelper.getYouTubeApiKey(context)
    private val videoDao: VideoDao = VideoDatabase.getDatabase(context).videoDao()
    
    private val channels = listOf(
        "UCynoa1DjwnvHAowA_jiMEAQ",
        "UCK0KOjX3beyB9nzonls0cuw",
        "UCACkIrvrGAQ7kuc0hMVwvmA",
        "UCtWRAKKvOEA0CXOue9BG8ZA"
    )

    private val apiService: YouTubeApiService by lazy {
        val logging = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        }
        
        val client = OkHttpClient.Builder()
            .addInterceptor(logging)
            // .addInterceptor { chain ->
            //     val request = chain.request().newBuilder()
            //         .header("X-Android-Package", context.packageName)
            //         .header("X-Android-Cert", "TODO_SHA1_IF_NEEDED")
            //         .build()
            //     chain.proceed(request)
            // }
            .build()

        val json = Json { ignoreUnknownKeys = true }
        
        Retrofit.Builder()
            .baseUrl("https://www.googleapis.com/youtube/v3/")
            .client(client)
            .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
            .build()
            .create(YouTubeApiService::class.java)
    }

    suspend fun getLatestVideos(): List<Video> = withContext(Dispatchers.IO) {
        val threshold = System.currentTimeMillis() - (24 * 60 * 60 * 1000)
        val cached = videoDao.getVideosNewerThan(threshold)
        if (cached.isNotEmpty()) {
            Log.d("YouTubeRepository", "Returning cached videos")
            return@withContext cached.map { it.toVideo() }
        }
        
        Log.d("YouTubeRepository", "Cache empty or expired, fetching from API")
        return@withContext refreshVideos()
    }

    suspend fun refreshVideos(): List<Video> = withContext(Dispatchers.IO) {
        val allVideos = mutableListOf<Video>()
        
        coroutineScope {
            val deferreds = channels.map { channelId ->
                async { fetchChannelVideos(channelId) }
            }
            val results = deferreds.awaitAll()
            results.forEach { allVideos.addAll(it) }
        }

        // Fetch details for all videos
        val enrichedVideos = fetchAndMergeVideoDetails(allVideos)
        
        // Cache to DB
        val timestamp = System.currentTimeMillis()
        val entities = enrichedVideos.map { it.copy(cacheTimestamp = timestamp).toEntity() }
        videoDao.insertVideos(entities)
        
        return@withContext enrichedVideos
    }

    private suspend fun fetchChannelVideos(channelId: String): List<Video> {
        val videos = mutableListOf<Video>()
        var pageToken: String? = null
        var pagesFetched = 0

        try {
            while (pagesFetched < 5) {
                val response = apiService.searchVideos(
                    channelId = channelId,
                    pageToken = pageToken,
                    apiKey = apiKey
                )
                
                response.items.mapNotNull { it.toVideo() }.let { videos.addAll(it) }
                
                pageToken = response.nextPageToken
                pagesFetched++
                
                if (pageToken == null) break
            }
        } catch (e: Exception) {
            Log.e("YouTubeRepository", "Error fetching channel $channelId", e)
        }
        
        return videos
    }
    
    private suspend fun fetchAndMergeVideoDetails(videos: List<Video>): List<Video> {
        if (videos.isEmpty()) return emptyList()
        
        val enriched = mutableListOf<Video>()
        val chunks = videos.chunked(50)
        
        for (chunk in chunks) {
            try {
                val ids = chunk.joinToString(",") { it.id }
                val response = apiService.getVideosDetails(id = ids, apiKey = apiKey)
                
                val detailsMap = response.items.associateBy { it.id }
                
                for (video in chunk) {
                    val details = detailsMap[video.id]
                    if (details != null) {
                        val tags = details.snippet?.tags
                        val location = details.recordingDetails?.location
                        val recordingDate = details.recordingDetails?.recordingDate
                        
                        var city: String? = null
                        var country: String? = null
                        
                        if (location != null) {
                            val pair = LocationUtils.getCityAndCountry(context, location.latitude, location.longitude)
                            city = pair.first
                            country = pair.second
                        }
                        
                        enriched.add(video.mergeWithDetails(
                            tags = tags,
                            locationCity = city,
                            locationCountry = country,
                            latitude = location?.latitude,
                            longitude = location?.longitude,
                            recordingDate = recordingDate
                        ))
                    } else {
                        enriched.add(video)
                    }
                }
            } catch (e: Exception) {
                Log.e("YouTubeRepository", "Error fetching details for chunk", e)
                enriched.addAll(chunk)
            }
        }
        
        return enriched
    }

    fun getVideosWithFiltersAndSort(channelName: String?, country: String?, sortBy: String): Flow<List<Video>> {
        return videoDao.getVideosWithFiltersAndSort(channelName, country, sortBy)
            .map { entities -> entities.map { it.toVideo() } }
    }

    fun getDistinctCountries() = videoDao.getDistinctCountries()
    fun getDistinctChannels() = videoDao.getDistinctChannels()
    fun getTotalVideoCount() = videoDao.getTotalVideoCount()
}
