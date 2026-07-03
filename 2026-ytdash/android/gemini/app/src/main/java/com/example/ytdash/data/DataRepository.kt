package com.example.ytdash.data

import android.content.Context
import android.util.Log
import com.example.ytdash.TestConfig
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.withContext
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.IOException

interface DataRepository {
    val videosFlow: StateFlow<List<Video>>
    fun getCachedVideos(): List<Video>
    suspend fun refreshVideos()
}

class DefaultDataRepository(private val context: Context) : DataRepository {
    private val sharedPrefs = context.getSharedPreferences("ytdash_cache", Context.MODE_PRIVATE)
    private val json = Json { ignoreUnknownKeys = true; coerceInputValues = true }
    private val client = OkHttpClient()

    private val _videosFlow = MutableStateFlow<List<Video>>(getCachedVideos())
    override val videosFlow: StateFlow<List<Video>> = _videosFlow.asStateFlow()

    override fun getCachedVideos(): List<Video> {
        val jsonString = sharedPrefs.getString("cached_videos", null) ?: return emptyList()
        return try {
            json.decodeFromString<List<Video>>(jsonString)
        } catch (e: Exception) {
            Log.e("DataRepository", "Error parsing cached videos", e)
            emptyList()
        }
    }

    private fun saveCachedVideos(videos: List<Video>) {
        try {
            val jsonString = json.encodeToString(videos)
            sharedPrefs.edit().putString("cached_videos", jsonString).apply()
            Log.d("DataRepository", "Successfully saved ${videos.size} videos to cache")
        } catch (e: Exception) {
            Log.e("DataRepository", "Error saving videos to cache", e)
        }
    }

    private suspend fun fetchUrl(url: String): String = withContext(Dispatchers.IO) {
        val request = Request.Builder().url(url).build()
        try {
            client.newCall(request).execute().use { response ->
                if (!response.isSuccessful) {
                    throw IOException("HTTP error: ${response.code} for URL: $url")
                }
                response.body?.string() ?: throw IOException("Empty response body for URL: $url")
            }
        } catch (e: Exception) {
            Log.e("DataRepository", "Network error fetching URL: $url", e)
            throw e
        }
    }

    override suspend fun refreshVideos() {
        val baseUrl = TestConfig.apiBaseUrl
        val apiKey = TestConfig.apiKey

        // 1. Load channels from assets
        val channels = withContext(Dispatchers.IO) {
            try {
                val jsonString = context.assets.open("channels.json").bufferedReader().use { it.readText() }
                json.decodeFromString<List<ChannelConfig>>(jsonString)
            } catch (e: Exception) {
                Log.e("DataRepository", "Failed to load channels.json from assets", e)
                emptyList()
            }
        }

        if (channels.isEmpty()) {
            throw IOException("No channels configured")
        }

        val channelMap = channels.associate { it.id to it.label }
        val allSearchItems = mutableListOf<SearchItem>()

        // 2. Fetch search list for each channel following pagination
        for (channel in channels) {
            var pageToken: String? = null
            do {
                var url = "$baseUrl/youtube/v3/search?key=$apiKey&channelId=${channel.id}&part=snippet&order=date&type=video&maxResults=50"
                if (pageToken != null) {
                    url += "&pageToken=$pageToken"
                }
                
                Log.d("DataRepository", "Fetching search list: channel=${channel.label}, page=$pageToken")
                val responseJson = fetchUrl(url)
                val searchResponse = json.decodeFromString<SearchResponse>(responseJson)
                allSearchItems.addAll(searchResponse.items)
                pageToken = searchResponse.nextPageToken
            } while (!pageToken.isNullOrBlank())
        }

        // 3. Deduplicate by videoId
        val uniqueVideoItems = allSearchItems.filter { it.id.videoId != null }
            .distinctBy { it.id.videoId }

        val uniqueVideoIds = uniqueVideoItems.mapNotNull { it.id.videoId }
        val videosDetailsMap = mutableMapOf<String, VideoItem>()

        // 4. Fetch details/recordingDetails in chunks of 50
        for (idChunk in uniqueVideoIds.chunked(50)) {
            val joinedIds = idChunk.joinToString(",")
            val url = "$baseUrl/youtube/v3/videos?key=$apiKey&id=$joinedIds&part=snippet,contentDetails,recordingDetails"
            
            Log.d("DataRepository", "Fetching details for ${idChunk.size} videos")
            val responseJson = fetchUrl(url)
            val videoListResponse = json.decodeFromString<VideoListResponse>(responseJson)
            videoListResponse.items.forEach { videoItem ->
                videosDetailsMap[videoItem.id] = videoItem
            }
        }

        // 5. Map network objects to domain models
        val mappedVideos = uniqueVideoItems.mapNotNull { searchItem ->
            val videoId = searchItem.id.videoId ?: return@mapNotNull null
            val detail = videosDetailsMap[videoId]
            val location = detail?.recordingDetails?.location
            val snippet = detail?.snippet ?: searchItem.snippet
            
            val channelId = searchItem.snippet.channelId ?: ""
            val categoryLabel = channelMap[channelId] ?: "unknown"

            Video(
                id = videoId,
                title = snippet.title,
                description = snippet.description,
                publishedAt = snippet.publishedAt,
                category = categoryLabel,
                thumbnailUrl = snippet.thumbnails?.medium?.url
                    ?: snippet.thumbnails?.high?.url
                    ?: snippet.thumbnails?.default?.url
                    ?: "",
                lat = location?.latitude,
                lng = location?.longitude
            )
        }

        // 6. Save to cache and update state flow
        if (mappedVideos.isNotEmpty()) {
            saveCachedVideos(mappedVideos)
            _videosFlow.value = mappedVideos
        } else {
            Log.w("DataRepository", "Refreshed list is empty, keeping previous cached list")
        }
    }
}
