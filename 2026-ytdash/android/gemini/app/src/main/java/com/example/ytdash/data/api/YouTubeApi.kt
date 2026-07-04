package com.example.ytdash.data.api

import retrofit2.http.GET
import retrofit2.http.Query

interface YouTubeApi {
    @GET("youtube/v3/search")
    suspend fun searchList(
        @Query("key") key: String,
        @Query("channelId") channelId: String,
        @Query("part") part: String = "snippet",
        @Query("order") order: String = "date",
        @Query("type") type: String = "video",
        @Query("maxResults") maxResults: Int = 50,
        @Query("pageToken") pageToken: String? = null
    ): SearchListResponse

    @GET("youtube/v3/videos")
    suspend fun videosList(
        @Query("key") key: String,
        @Query("id") ids: String, // comma-joined
        @Query("part") part: String = "snippet,contentDetails,recordingDetails"
    ): VideoListResponse
}
