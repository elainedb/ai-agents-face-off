package dev.elainedb.ytdash_android_gemini.data.repository

import android.content.Context
import android.content.pm.PackageManager
import android.os.Build
import android.util.Log
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import dev.elainedb.ytdash_android_gemini.ConfigHelper
import dev.elainedb.ytdash_android_gemini.data.api.YouTubeApiService
import dev.elainedb.ytdash_android_gemini.data.local.VideoDatabase
import dev.elainedb.ytdash_android_gemini.data.local.toEntity
import dev.elainedb.ytdash_android_gemini.data.local.toVideo
import dev.elainedb.ytdash_android_gemini.data.model.Video
import dev.elainedb.ytdash_android_gemini.data.model.mergeWithDetails
import dev.elainedb.ytdash_android_gemini.data.model.toVideo
import dev.elainedb.ytdash_android_gemini.utils.LocationUtils
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.map
import kotlinx.serialization.json.Json
import okhttp3.Interceptor
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import java.security.MessageDigest
import java.util.Formatter

class YouTubeRepository(private val context: Context) {
    private val json = Json { ignoreUnknownKeys = true; coerceInputValues = true }
    
    private val loggingInterceptor = HttpLoggingInterceptor().apply {
        level = HttpLoggingInterceptor.Level.BODY
    }

    private val headerInterceptor = Interceptor { chain ->
        val original = chain.request()
        val requestBuilder = original.newBuilder()
            .header("X-Android-Package", context.packageName)
            .header("X-Android-Cert", getSHA1(context))
        chain.proceed(requestBuilder.build())
    }

    private val okHttpClient = OkHttpClient.Builder()
        .addInterceptor(loggingInterceptor)
        .addInterceptor(headerInterceptor)
        .build()

    private val retrofit = Retrofit.Builder()
        .baseUrl("https://www.googleapis.com/youtube/v3/")
        .client(okHttpClient)
        .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
        .build()

    private val apiService = retrofit.create(YouTubeApiService::class.java)

    private val videoDao = VideoDatabase.getDatabase(context).videoDao()
    private val CACHE_EXPIRY_HOURS = 24

    private val channelIds = listOf(
        "UCynoa1DjwnvHAowA_jiMEAQ",
        "UCK0KOjX3beyB9nzonls0cuw",
        "UCACkIrvrGAQ7kuc0hMVwvmA",
        "UCtWRAKKvOEA0CXOue9BG8ZA"
    )

    fun getVideosWithFiltersAndSort(
        channelName: String?,
        country: String?,
        sortBy: String
    ): Flow<List<Video>> {
        return videoDao.getVideosWithFiltersAndSort(channelName, country, sortBy)
            .map { entities -> entities.map { it.toVideo() } }
    }

    fun getDistinctCountries(): Flow<List<String>> = videoDao.getDistinctCountries()
    
    fun getDistinctChannels(): Flow<List<String>> = videoDao.getDistinctChannels()
    
    fun getTotalVideoCount(): Flow<Int> = videoDao.getTotalVideoCount()

    suspend fun getLatestVideos() {
        val threshold = System.currentTimeMillis() - (CACHE_EXPIRY_HOURS * 60 * 60 * 1000L)
        val recentVideo = videoDao.getVideosNewerThan(threshold)
        if (recentVideo == null) {
            refreshVideos()
        }
    }

    suspend fun refreshVideos() = coroutineScope {
        val apiKey = ConfigHelper.getYoutubeApiKey()
        
        val deferredVideos = channelIds.map { channelId ->
            async {
                fetchChannelVideos(channelId, apiKey)
            }
        }
        
        val allVideos = deferredVideos.awaitAll().flatten()
        val detailedVideos = mutableListOf<Video>()

        val chunks = allVideos.chunked(50)
        for (batch in chunks) {
            val ids = batch.joinToString(",") { it.id }
            try {
                val response = apiService.getVideosDetails(id = ids, key = apiKey)
                val detailsMap = response.items.associateBy { it.id }
                for (video in batch) {
                    val details = detailsMap[video.id]
                    var city: String? = null
                    var country: String? = null
                    val lat = details?.recordingDetails?.location?.latitude
                    val lng = details?.recordingDetails?.location?.longitude
                    if (lat != null && lng != null) {
                        val locationInfo = LocationUtils.getCityAndCountry(context, lat, lng)
                        city = locationInfo.first
                        country = locationInfo.second
                    }
                    detailedVideos.add(video.mergeWithDetails(details, city, country))
                }
            } catch (e: Exception) {
                Log.e("YouTubeRepository", "Error fetching video details", e)
                detailedVideos.addAll(batch)
            }
        }

        val entities = detailedVideos.map { it.toEntity(System.currentTimeMillis()) }
        videoDao.insertVideos(entities)
    }

    private suspend fun fetchChannelVideos(channelId: String, apiKey: String): List<Video> {
        val allVideos = mutableListOf<Video>()
        var pageToken: String? = null
        var pagesFetched = 0
        
        try {
            while (pagesFetched < 5) {
                val response = apiService.searchVideos(
                    channelId = channelId,
                    pageToken = pageToken,
                    key = apiKey
                )
                
                val videos = response.items.mapNotNull { it.toVideo() }
                allVideos.addAll(videos)
                
                pageToken = response.nextPageToken
                pagesFetched++
                
                if (pageToken.isNullOrEmpty()) {
                    break
                }
            }
        } catch (e: Exception) {
            Log.e("YouTubeRepository", "Error fetching videos for channel $channelId", e)
        }
        
        return allVideos
    }

    @Suppress("DEPRECATION")
    private fun getSHA1(context: Context): String {
        try {
            val info = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                context.packageManager.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNING_CERTIFICATES
                )
            } else {
                context.packageManager.getPackageInfo(
                    context.packageName,
                    PackageManager.GET_SIGNATURES
                )
            }
            
            val signatures = if (Build.VERSION.SDK_INT >= Build.VERSION_CODES.P) {
                info.signingInfo?.apkContentsSigners
            } else {
                info.signatures
            }
            
            if (!signatures.isNullOrEmpty()) {
                val md = MessageDigest.getInstance("SHA1")
                md.update(signatures[0].toByteArray())
                val digest = md.digest()
                val formatter = Formatter()
                for (b in digest) {
                    formatter.format("%02x", b)
                }
                return formatter.toString().uppercase()
            }
        } catch (e: Exception) {
            Log.e("YouTubeRepository", "Error getting SHA1", e)
        }
        return ""
    }
}