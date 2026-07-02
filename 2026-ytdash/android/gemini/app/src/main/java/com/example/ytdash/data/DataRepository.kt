package com.example.ytdash.data

import android.content.Context
import android.util.Log
import com.example.ytdash.BuildConfig
import com.example.ytdash.TestConfig
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.Flow
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.withContext
import kotlinx.serialization.json.Json
import kotlinx.serialization.encodeToString
import okhttp3.HttpUrl
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import okhttp3.OkHttpClient
import okhttp3.Request

interface DataRepository {
    val videos: Flow<List<Video>>
    suspend fun refresh(): Result<Unit>
}

class DefaultDataRepository(private val context: Context) : DataRepository {

    private val json = Json {
        ignoreUnknownKeys = true
        coerceInputValues = true
    }

    private val client = OkHttpClient.Builder()
        .connectTimeout(15, java.util.concurrent.TimeUnit.SECONDS)
        .readTimeout(15, java.util.concurrent.TimeUnit.SECONDS)
        .build()

    private val prefs = context.getSharedPreferences("ytdash_cache", Context.MODE_PRIVATE)

    private val _videos = MutableStateFlow<List<Video>>(loadCache())
    override val videos: Flow<List<Video>> = _videos.asStateFlow()

    private fun loadChannelsFromAssets(): List<ChannelConfig> {
        return try {
            context.assets.open("channels.json").bufferedReader().use { reader ->
                val jsonStr = reader.readText()
                json.decodeFromString<List<ChannelConfig>>(jsonStr)
            }
        } catch (e: Exception) {
            Log.e("DataRepository", "Error reading channels.json from assets", e)
            emptyList()
        }
    }

    private fun saveCache(videosList: List<Video>) {
        try {
            val jsonStr = json.encodeToString(videosList)
            prefs.edit().putString("cached_videos", jsonStr).apply()
            Log.d("DataRepository", "Cache saved successfully with ${videosList.size} items")
        } catch (e: Exception) {
            Log.e("DataRepository", "Error saving cache", e)
        }
    }

    private fun loadCache(): List<Video> {
        try {
            val jsonStr = prefs.getString("cached_videos", null)
            if (!jsonStr.isNullOrEmpty()) {
                val cached = json.decodeFromString<List<Video>>(jsonStr)
                Log.d("DataRepository", "Loaded ${cached.size} cached items from disk")
                return cached
            }
        } catch (e: Exception) {
            Log.e("DataRepository", "Error loading cache from SharedPreferences", e)
        }
        return emptyList()
    }

    override suspend fun refresh(): Result<Unit> = withContext(Dispatchers.IO) {
        try {
            val channels = loadChannelsFromAssets()
            if (channels.isEmpty()) {
                return@withContext Result.failure(Exception("No configured channels found in assets"))
            }

            // Retrieve API configuration at runtime (test mode vs production/real mode)
            val apiBaseUrl = if (TestConfig.uiTestMode) TestConfig.apiBaseUrl else "https://www.googleapis.com"
            val apiKey = if (TestConfig.uiTestMode) {
                TestConfig.apiKey ?: BuildConfig.YOUTUBE_API_KEY
            } else {
                BuildConfig.YOUTUBE_API_KEY
            }

            Log.d("DataRepository", "Refreshing data from API: apiBaseUrl=$apiBaseUrl, channelsToLoad=${channels.size}")

            val channelIdToLabel = channels.associate { it.id to it.label }
            val allVideoIds = mutableListOf<String>()
            val videoIdToChannelLabel = mutableMapOf<String, String>()

            // 1. Fetch videos from each channel following page tokens
            for (channel in channels) {
                var pageToken: String? = null
                var hasNextPage = true
                var pageCount = 0

                while (hasNextPage) {
                    pageCount++
                    val urlBuilder = "$apiBaseUrl/youtube/v3/search".toHttpUrlOrNull()?.newBuilder()
                        ?: throw Exception("Invalid API base URL: $apiBaseUrl")

                    urlBuilder.addQueryParameter("key", apiKey)
                    urlBuilder.addQueryParameter("channelId", channel.id)
                    urlBuilder.addQueryParameter("part", "snippet")
                    urlBuilder.addQueryParameter("order", "date")
                    urlBuilder.addQueryParameter("type", "video")
                    urlBuilder.addQueryParameter("maxResults", "50")
                    if (!pageToken.isNullOrEmpty()) {
                        urlBuilder.addQueryParameter("pageToken", pageToken)
                    }

                    val request = Request.Builder().url(urlBuilder.build()).build()
                    val response = client.newCall(request).execute()

                    if (!response.isSuccessful) {
                        val body = response.body?.string() ?: ""
                        Log.e("DataRepository", "Search failed for channel ${channel.label} (page $pageCount): code=${response.code}, body=$body")
                        throw Exception("Failed to search channel ${channel.label}: HTTP ${response.code}")
                    }

                    val bodyStr = response.body?.string() ?: ""
                    val searchResponse = json.decodeFromString<YouTubeSearchResponse>(bodyStr)

                    val items = searchResponse.items
                    Log.d("DataRepository", "Fetched channel ${channel.label} page $pageCount. Items in page: ${items.size}")

                    for (item in items) {
                        val videoId = item.id.videoId
                        if (!videoId.isNullOrEmpty()) {
                            allVideoIds.add(videoId)
                            videoIdToChannelLabel[videoId] = channel.label
                        }
                    }

                    pageToken = searchResponse.nextPageToken
                    hasNextPage = !pageToken.isNullOrEmpty()
                }
            }

            // Deduplicate accumulated video IDs
            val uniqueVideoIds = allVideoIds.distinct()
            Log.d("DataRepository", "Aggregated total ${allVideoIds.size} video IDs, unique IDs: ${uniqueVideoIds.size}")

            val aggregatedVideos = mutableListOf<Video>()

            // 2. Fetch full details and location for the unique video IDs in batches of 50
            if (uniqueVideoIds.isNotEmpty()) {
                val chunks = uniqueVideoIds.chunked(50)
                for (chunk in chunks) {
                    val idsParam = chunk.joinToString(",")
                    val urlBuilder = "$apiBaseUrl/youtube/v3/videos".toHttpUrlOrNull()?.newBuilder()
                        ?: throw Exception("Invalid API base URL: $apiBaseUrl")

                    urlBuilder.addQueryParameter("key", apiKey)
                    urlBuilder.addQueryParameter("id", idsParam)
                    urlBuilder.addQueryParameter("part", "snippet,contentDetails,recordingDetails")

                    val request = Request.Builder().url(urlBuilder.build()).build()
                    val response = client.newCall(request).execute()

                    if (!response.isSuccessful) {
                        val body = response.body?.string() ?: ""
                        Log.e("DataRepository", "Videos list failed: code=${response.code}, body=$body")
                        throw Exception("Failed to fetch video details: HTTP ${response.code}")
                    }

                    val bodyStr = response.body?.string() ?: ""
                    val videosResponse = json.decodeFromString<YouTubeVideosResponse>(bodyStr)

                    for (item in videosResponse.items) {
                        val videoId = item.id
                        val title = item.snippet?.title ?: ""
                        val description = item.snippet?.description ?: ""
                        val publishedAt = item.snippet?.publishedAt ?: ""
                        
                        // Extract high or medium or default thumbnail URL
                        val thumbUrl = item.snippet?.thumbnails?.medium?.url 
                            ?: item.snippet?.thumbnails?.default?.url 
                            ?: item.snippet?.thumbnails?.high?.url 
                            ?: ""

                        // Associate with the correct channel label
                        val channelId = item.snippet?.channelId
                        val category = channelIdToLabel[channelId] 
                            ?: videoIdToChannelLabel[videoId] 
                            ?: ""

                        val location = item.recordingDetails?.location?.let {
                            if (it.latitude != null && it.longitude != null) {
                                Location(it.latitude, it.longitude)
                            } else null
                        }

                        aggregatedVideos.add(
                            Video(
                                id = videoId,
                                title = title,
                                description = description,
                                category = category,
                                publishedAt = publishedAt,
                                thumbnailUrl = thumbUrl,
                                location = location
                            )
                        )
                    }
                }
            }

            Log.d("DataRepository", "Fully loaded details for ${aggregatedVideos.size} videos")

            // 3. Update memory state and disk cache
            _videos.value = aggregatedVideos
            saveCache(aggregatedVideos)

            Result.success(Unit)
        } catch (e: Exception) {
            Log.e("DataRepository", "Failed to refresh data", e)
            Result.failure(e)
        }
    }
}
