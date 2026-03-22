package dev.elainedb.ytdash_android_gemini.data.api

import dev.elainedb.ytdash_android_gemini.data.model.YouTubeSearchResponse
import dev.elainedb.ytdash_android_gemini.data.model.YouTubeVideosResponse
import retrofit2.http.GET
import retrofit2.http.Query

interface YouTubeApiService {
    @GET("search")
    suspend fun searchVideos(
        @Query("part") part: String = "snippet",
        @Query("channelId") channelId: String,
        @Query("maxResults") maxResults: Int = 50,
        @Query("order") order: String = "date",
        @Query("type") type: String = "video",
        @Query("pageToken") pageToken: String? = null,
        @Query("key") key: String
    ): YouTubeSearchResponse

    @GET("videos")
    suspend fun getVideosDetails(
        @Query("part") part: String = "snippet,recordingDetails",
        @Query("id") id: String, // comma-separated, max 50
        @Query("key") key: String
    ): YouTubeVideosResponse
}
