package com.example.ytdash.data.api

import kotlinx.serialization.Serializable

@Serializable
data class SearchListResponse(
    val nextPageToken: String? = null,
    val items: List<SearchResultItem> = emptyList()
)

@Serializable
data class SearchResultItem(
    val id: SearchResultId,
    val snippet: Snippet
)

@Serializable
data class SearchResultId(
    val videoId: String
)

@Serializable
data class Snippet(
    val publishedAt: String,
    val channelId: String,
    val title: String,
    val description: String,
    val channelTitle: String,
    val thumbnails: Thumbnails
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
data class VideoListResponse(
    val items: List<VideoItem> = emptyList()
)

@Serializable
data class VideoItem(
    val id: String,
    val snippet: Snippet,
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
