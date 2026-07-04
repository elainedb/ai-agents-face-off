package com.example.ytdash.data

import android.content.Context
import android.content.SharedPreferences
import com.example.ytdash.TestConfig
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import java.io.IOException

class AppContainer(private val context: Context, val testConfig: TestConfig) {

    private val json = Json { ignoreUnknownKeys = true }

    private val okHttpClient = OkHttpClient.Builder()
        .addInterceptor(HttpLoggingInterceptor().apply { level = HttpLoggingInterceptor.Level.BODY })
        .build()

    private val retrofit: Retrofit by lazy {
        val baseUrl = testConfig.apiBaseUrl ?: "https://www.googleapis.com"
        // Ensure trailing slash
        val urlWithSlash = if (baseUrl.endsWith("/")) baseUrl else "$baseUrl/"
        Retrofit.Builder()
            .baseUrl(urlWithSlash)
            .client(okHttpClient)
            .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
            .build()
    }

    val youtubeApi: YouTubeApi by lazy {
        retrofit.create(YouTubeApi::class.java)
    }

    val prefs: SharedPreferences by lazy {
        context.getSharedPreferences("ytdash_prefs", Context.MODE_PRIVATE)
    }

    val repository: VideoRepository by lazy {
        VideoRepository(youtubeApi, testConfig, prefs, ConfigLoader.loadChannels(context))
    }
}

class VideoRepository(
    private val api: YouTubeApi,
    private val testConfig: TestConfig,
    private val prefs: SharedPreferences,
    private val channels: List<ChannelConfig>
) {
    private val json = Json { ignoreUnknownKeys = true }

    suspend fun getVideos(forceRefresh: Boolean = false): List<Video> = withContext(Dispatchers.IO) {
        val cached = getCachedVideos()
        if (cached.isNotEmpty() && !forceRefresh) {
            return@withContext cached
        }

        try {
            val key = testConfig.apiKey ?: "DUMMY_KEY"
            val allVideos = mutableListOf<Video>()

            for (channel in channels) {
                var pageToken: String? = null
                do {
                    val response = api.searchList(
                        key = key,
                        channelId = channel.id,
                        pageToken = pageToken
                    )
                    
                    val items = response.items
                    if (items.isNotEmpty()) {
                        // We fetch video details in batches of 50 to get locations
                        val ids = items.joinToString(",") { it.id.videoId }
                        val videosResponse = api.videosList(key = key, ids = ids)
                        val detailsMap = videosResponse.items.associateBy { it.id }

                        items.forEach { searchItem ->
                            val detail = detailsMap[searchItem.id.videoId]
                            allVideos.add(
                                Video(
                                    id = searchItem.id.videoId,
                                    title = searchItem.snippet.title,
                                    description = searchItem.snippet.description,
                                    publishedAt = searchItem.snippet.publishedAt,
                                    thumbnailUrl = searchItem.snippet.thumbnails.medium?.url 
                                        ?: searchItem.snippet.thumbnails.default?.url ?: "",
                                    category = channel.label,
                                    lat = detail?.recordingDetails?.location?.latitude,
                                    lng = detail?.recordingDetails?.location?.longitude
                                )
                            )
                        }
                    }
                    pageToken = response.nextPageToken
                } while (pageToken != null)
            }

            // Deduplicate and save
            val deduplicated = allVideos.distinctBy { it.id }
            saveVideos(deduplicated)
            deduplicated
        } catch (e: Exception) {
            // If network fails but we have cache, fallback to stale cache
            if (cached.isNotEmpty()) {
                cached
            } else {
                throw e
            }
        }
    }

    private fun getCachedVideos(): List<Video> {
        val str = prefs.getString("videos_cache", null) ?: return emptyList()
        return try {
            json.decodeFromString(str)
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun saveVideos(videos: List<Video>) {
        prefs.edit().putString("videos_cache", json.encodeToString(videos)).apply()
    }
}
