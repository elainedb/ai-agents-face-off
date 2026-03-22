package dev.elainedb.ytdash_android_gemini.repository

import android.content.Context
import android.content.pm.PackageManager
import android.util.Log
import dev.elainedb.ytdash_android_gemini.model.Video
import dev.elainedb.ytdash_android_gemini.model.toVideo
import dev.elainedb.ytdash_android_gemini.network.YouTubeApiService
import dev.elainedb.ytdash_android_gemini.utils.ConfigHelper
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.serialization.json.Json
import okhttp3.Interceptor
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import java.security.MessageDigest

import dev.elainedb.ytdash_android_gemini.database.VideoDatabase
import dev.elainedb.ytdash_android_gemini.database.VideoEntity
import dev.elainedb.ytdash_android_gemini.database.toEntity
import dev.elainedb.ytdash_android_gemini.model.mergeWithDetails
import dev.elainedb.ytdash_android_gemini.utils.LocationUtils
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map

class YouTubeRepository(private val context: Context) {

    private val apiService: YouTubeApiService
    private val videoDao = VideoDatabase.getDatabase(context).videoDao()
    private val CACHE_EXPIRY_HOURS = 24L

    init {
        val logging = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        }

        val headerInterceptor = Interceptor { chain ->
            val original = chain.request()
            val requestBuilder = original.newBuilder()
                .header("X-Android-Package", context.packageName)
                .header("X-Android-Cert", getSignature(context))
            chain.proceed(requestBuilder.build())
        }

        val client = OkHttpClient.Builder()
            .addInterceptor(logging)
            .addInterceptor(headerInterceptor)
            .build()

        val json = Json { ignoreUnknownKeys = true }
        val contentType = "application/json".toMediaType()

        val retrofit = Retrofit.Builder()
            .baseUrl("https://www.googleapis.com/youtube/v3/")
            .client(client)
            .addConverterFactory(json.asConverterFactory(contentType))
            .build()

        apiService = retrofit.create(YouTubeApiService::class.java)
    }

    @Suppress("DEPRECATION")
    private fun getSignature(context: Context): String {
        try {
            val packageInfo = context.packageManager.getPackageInfo(
                context.packageName,
                PackageManager.GET_SIGNATURES
            )
            val signatures = packageInfo.signatures
            if (signatures != null && signatures.isNotEmpty()) {
                val md = MessageDigest.getInstance("SHA1")
                md.update(signatures[0].toByteArray())
                val digest = md.digest()
                return digest.joinToString("") { "%02X".format(it) }
            }
        } catch (e: Exception) {
            Log.e("YouTubeRepository", "Failed to get signature", e)
        }
        return ""
    }

    suspend fun getLatestVideos() {
        val threshold = System.currentTimeMillis() - (CACHE_EXPIRY_HOURS * 60 * 60 * 1000)
        val cached = videoDao.getVideosNewerThan(threshold)
        if (cached.isEmpty()) {
            refreshVideos()
        }
    }

    suspend fun refreshVideos() {
        val channelIds = listOf(
            "UCynoa1DjwnvHAowA_jiMEAQ",
            "UCK0KOjX3beyB9nzonls0cuw",
            "UCACkIrvrGAQ7kuc0hMVwvmA",
            "UCtWRAKKvOEA0CXOue9BG8ZA"
        )
        val apiKey = ConfigHelper.youtubeApiKey
        val allVideos = mutableListOf<Video>()

        coroutineScope {
            val deferreds = channelIds.map { channelId ->
                async {
                    val channelVideos = mutableListOf<Video>()
                    var pageToken: String? = null
                    var pagesFetched = 0

                    try {
                        while (pagesFetched < 5) {
                            val response = apiService.searchVideos(
                                channelId = channelId,
                                pageToken = pageToken,
                                apiKey = apiKey
                            )
                            val videos = response.items.map { it.toVideo() }
                            channelVideos.addAll(videos)

                            pageToken = response.nextPageToken
                            pagesFetched++

                            if (pageToken == null) break
                        }
                    } catch (e: Exception) {
                        Log.e("YouTubeRepository", "Error fetching for channel $channelId", e)
                    }
                    channelVideos
                }
            }
            deferreds.awaitAll().forEach { allVideos.addAll(it) }
        }

        // Fetch details in chunks of 50
        val detailedVideos = mutableListOf<Video>()
        allVideos.chunked(50).forEach { chunk ->
            val ids = chunk.joinToString(",") { it.id }
            try {
                val detailsResponse = apiService.getVideos(id = ids, apiKey = apiKey)
                val detailsMap = detailsResponse.items.associateBy { it.id }
                
                chunk.forEach { video ->
                    val detail = detailsMap[video.id]
                    var city: String? = null
                    var country: String? = null
                    
                    if (detail?.recordingDetails?.location != null) {
                        val lat = detail.recordingDetails.location.latitude
                        val lng = detail.recordingDetails.location.longitude
                        val (c, cnt) = LocationUtils.getCityAndCountry(context, lat, lng)
                        city = c
                        country = cnt
                    }
                    detailedVideos.add(video.mergeWithDetails(detail, city, country))
                }
            } catch (e: Exception) {
                Log.e("YouTubeRepository", "Error fetching video details", e)
                detailedVideos.addAll(chunk) // Fallback to basic details if fetch fails
            }
        }

        val cacheTimestamp = System.currentTimeMillis()
        val entities = detailedVideos.map { it.toEntity(cacheTimestamp) }
        videoDao.insertVideos(entities)
    }

    fun getVideosWithFiltersAndSort(channelName: String?, country: String?, sortBy: String): Flow<List<Video>> {
        return videoDao.getVideosWithFiltersAndSort(channelName, country, sortBy).map { entities ->
            entities.map { it.toVideo() }
        }
    }

    fun getDistinctCountries(): Flow<List<String>> = videoDao.getDistinctCountries()
    
    fun getDistinctChannels(): Flow<List<String>> = videoDao.getDistinctChannels()
    
    fun getTotalVideoCount(): Flow<Int> = videoDao.getTotalVideoCount()
}
