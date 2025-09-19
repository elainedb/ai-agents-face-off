package dev.elainedb.android_gemini.data.youtube

import retrofit2.http.GET
import retrofit2.http.Query

interface YoutubeApiService {

    @GET("youtube/v3/search")
    suspend fun search(
        @Query("key") apiKey: String,
        @Query("channelId") channelId: String,
        @Query("part") part: String = "snippet",
        @Query("maxResults") maxResults: Int = 50,
        @Query("order") order: String = "date",
        @Query("type") type: String = "video",
        @Query("pageToken") pageToken: String? = null
    ): YoutubeSearchListResponse

    @GET("youtube/v3/videos")
    suspend fun videos(
        @Query("key") apiKey: String,
        @Query("id") ids: String,
        @Query("part") part: String = "snippet,recordingDetails"
    ): YoutubeVideosListResponse
}
