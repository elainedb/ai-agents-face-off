package com.example.ytdash.data.network

import android.content.Context
import com.example.ytdash.data.model.ChannelConfig
import com.example.ytdash.data.model.TestConfig
import com.example.ytdash.data.model.Video
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import okhttp3.HttpUrl.Companion.toHttpUrlOrNull
import okhttp3.OkHttpClient
import okhttp3.Request
import java.io.IOException

class YouTubeApiService(
    private val context: Context,
    private val testConfig: TestConfig
) {
    private val client = OkHttpClient.Builder()
        .build()
    private val gson = Gson()

    // Default base URL and default API key
    private val defaultBaseUrl = "https://www.googleapis.com"
    
    // We can read from secrets.env or the intent extra.
    // Wait, the prompt says: "read it at RUNTIME from the apiKey launch extra so the same build works against both mock and real...
    // A real key/google-services.json are also in config/secrets.env"
    // Let's load the default API key at runtime if needed, but first check TestConfig.
    private val defaultApiKey: String by lazy {
        try {
            val envString = context.assets.open("secrets.env").bufferedReader().use { it.readText() }
            val match = Regex("YOUTUBE_API_KEY=(.*)").find(envString)
            match?.groupValues?.get(1)?.trim() ?: ""
        } catch (e: Exception) {
            "DUMMY_API_KEY"
        }
    }

    private val apiBaseUrl: String
        get() = if (testConfig.uiTestMode && !testConfig.apiBaseUrl.isNullOrEmpty()) {
            testConfig.apiBaseUrl
        } else {
            defaultBaseUrl
        }

    private val apiKey: String
        get() = if (testConfig.uiTestMode && !testConfig.apiKey.isNullOrEmpty()) {
            testConfig.apiKey
        } else {
            defaultApiKey
        }

    /**
     * Load channel configurations from local assets
     */
    fun loadChannelsFromConfig(): List<ChannelConfig> {
        return try {
            val jsonString = context.assets.open("channels.json").bufferedReader().use { it.readText() }
            val type = object : TypeToken<List<ChannelConfig>>() {}.type
            gson.fromJson(jsonString, type)
        } catch (e: Exception) {
            emptyList()
        }
    }

    /**
     * Fetch and aggregate videos across all configured channels.
     */
    fun fetchAllVideos(channels: List<ChannelConfig>): List<Video> {
        val allVideos = mutableListOf<Video>()
        
        for (channel in channels) {
            try {
                val videosForChannel = fetchVideosForChannel(channel)
                allVideos.addAll(videosForChannel)
            } catch (e: Exception) {
                e.printStackTrace()
                // If any channel request fails, propagate the exception so the UI handles it as an overall error.
                throw e
            }
        }
        
        // Deduplicate videos by their ID
        return allVideos.distinctBy { it.id }
    }

    private fun fetchVideosForChannel(channel: ChannelConfig): List<Video> {
        val searchResults = mutableListOf<SearchItem>()
        var nextPageToken: String? = null
        
        // Follow pagination until exhausted (no more nextPageToken)
        do {
            val urlBuilder = (apiBaseUrl.trimEnd('/') + "/youtube/v3/search")
                .toHttpUrlOrNull()
                ?.newBuilder() ?: throw IOException("Invalid API Base URL: $apiBaseUrl")
                
            urlBuilder.addQueryParameter("key", apiKey)
            urlBuilder.addQueryParameter("channelId", channel.id)
            urlBuilder.addQueryParameter("part", "snippet")
            urlBuilder.addQueryParameter("type", "video")
            urlBuilder.addQueryParameter("order", "date")
            urlBuilder.addQueryParameter("maxResults", "50")
            if (nextPageToken != null) {
                urlBuilder.addQueryParameter("pageToken", nextPageToken)
            }
            
            val request = Request.Builder()
                .url(urlBuilder.build())
                .build()
                
            client.newCall(request).execute().use { response ->
                if (!response.isSuccessful) {
                    throw IOException("Search request failed with code: ${response.code}")
                }
                
                val responseBody = response.body?.string() ?: throw IOException("Empty search response body")
                val searchResponse = gson.fromJson(responseBody, SearchListResponse::class.java)
                
                searchResponse.items?.let { searchResults.addAll(it) }
                nextPageToken = searchResponse.nextPageToken
            }
        } while (!nextPageToken.isNullOrEmpty())
        
        if (searchResults.isEmpty()) {
            return emptyList()
        }
        
        // Fetch detailed information (including location/recordingDetails) for these video IDs
        val videoIds = searchResults.mapNotNull { it.id?.videoId }
        if (videoIds.isEmpty()) return emptyList()
        
        // Split IDs into chunks of 50 (API limit)
        val detailedVideos = mutableListOf<Video>()
        for (chunk in videoIds.chunked(50)) {
            val idsString = chunk.joinToString(",")
            val urlBuilder = (apiBaseUrl.trimEnd('/') + "/youtube/v3/videos")
                .toHttpUrlOrNull()
                ?.newBuilder() ?: throw IOException("Invalid API Base URL")
                
            urlBuilder.addQueryParameter("key", apiKey)
            urlBuilder.addQueryParameter("id", idsString)
            urlBuilder.addQueryParameter("part", "snippet,contentDetails,recordingDetails")
            
            val request = Request.Builder()
                .url(urlBuilder.build())
                .build()
                
            client.newCall(request).execute().use { response ->
                if (!response.isSuccessful) {
                    throw IOException("Videos details request failed with code: ${response.code}")
                }
                
                val responseBody = response.body?.string() ?: throw IOException("Empty videos response body")
                val videosResponse = gson.fromJson(responseBody, VideoListResponse::class.java)
                
                videosResponse.items?.forEach { item ->
                    val videoId = item.id ?: return@forEach
                    val snippet = item.snippet ?: return@forEach
                    
                    val title = snippet.title ?: ""
                    val description = snippet.description ?: ""
                    val publishedAt = snippet.publishedAt ?: ""
                    val thumbnailUrl = snippet.thumbnails?.medium?.url ?: snippet.thumbnails?.default?.url ?: ""
                    
                    val location = item.recordingDetails?.location
                    val lat = location?.latitude
                    val lng = location?.longitude
                    
                    detailedVideos.add(
                        Video(
                            id = videoId,
                            title = title,
                            description = description,
                            publishedAt = publishedAt,
                            category = channel.label, // Channel label acts as Category
                            thumbnailUrl = thumbnailUrl,
                            lat = lat,
                            lng = lng
                        )
                    )
                }
            }
        }
        
        return detailedVideos
    }

    // --- JSON Mapping Classes for YouTube API ---
    private data class SearchListResponse(
        val kind: String?,
        val nextPageToken: String?,
        val items: List<SearchItem>?
    )

    private data class SearchItem(
        val id: ResourceId?,
        val snippet: Snippet?
    )

    private data class ResourceId(
        val kind: String?,
        val videoId: String?
    )

    private data class VideoListResponse(
        val items: List<VideoItem>?
    )

    private data class VideoItem(
        val id: String?,
        val snippet: Snippet?,
        val recordingDetails: RecordingDetails?
    )

    private data class Snippet(
        val title: String?,
        val description: String?,
        val publishedAt: String?,
        val thumbnails: Thumbnails?
    )

    private data class Thumbnails(
        val default: Thumbnail?,
        val medium: Thumbnail?,
        val high: Thumbnail?
    )

    private data class Thumbnail(
        val url: String?
    )

    private data class RecordingDetails(
        val location: LocationDetails?
    )

    private data class LocationDetails(
        val latitude: Double?,
        val longitude: Double?
    )
}
