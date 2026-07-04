package com.example.ytdash.data.network

import kotlinx.serialization.Serializable
import retrofit2.http.GET
import retrofit2.http.Query

@Serializable
data class SearchResponse(
    val nextPageToken: String? = null,
    val items: List<SearchItem> = emptyList()
)

@Serializable
data class SearchItem(
    val id: SearchItemId,
    val snippet: Snippet
)

@Serializable
data class SearchItemId(
    val videoId: String
)

@Serializable
data class Snippet(
    val publishedAt: String,
    val channelId: String,
    val title: String,
    val description: String,
    val thumbnails: Thumbnails? = null
)

@Serializable
data class Thumbnails(
    val medium: Thumbnail? = null
)

@Serializable
data class Thumbnail(
    val url: String
)

@Serializable
data class VideosResponse(
    val items: List<VideoItem> = emptyList()
)

@Serializable
data class VideoItem(
    val id: String,
    val recordingDetails: RecordingDetails? = null
)

@Serializable
data class RecordingDetails(
    val location: Location? = null
)

@Serializable
data class Location(
    val latitude: Double,
    val longitude: Double
)

interface YoutubeApi {
    @GET("youtube/v3/search")
    suspend fun listUploads(
        @Query("key") key: String,
        @Query("channelId") channelId: String,
        @Query("part") part: String = "snippet",
        @Query("order") order: String = "date",
        @Query("type") type: String = "video",
        @Query("maxResults") maxResults: Int = 50,
        @Query("pageToken") pageToken: String? = null
    ): SearchResponse

    @GET("youtube/v3/videos")
    suspend fun getVideos(
        @Query("key") key: String,
        @Query("id") id: String,
        @Query("part") part: String = "snippet,contentDetails,recordingDetails"
    ): VideosResponse
}
