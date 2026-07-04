package com.example.ytdash.data

import kotlinx.serialization.Serializable

@Serializable
data class Video(
    val id: String,
    val title: String,
    val description: String,
    val publishedAt: String,
    val thumbnailUrl: String,
    val category: String, // From the source channel label
    val lat: Double? = null,
    val lng: Double? = null
)

@Serializable
data class SearchResponse(
    val nextPageToken: String? = null,
    val items: List<SearchItem> = emptyList()
)

@Serializable
data class SearchItem(
    val id: SearchItemId,
    val snippet: SearchSnippet
)

@Serializable
data class SearchItemId(
    val videoId: String
)

@Serializable
data class SearchSnippet(
    val publishedAt: String,
    val channelId: String,
    val title: String,
    val description: String,
    val thumbnails: SearchThumbnails
)

@Serializable
data class SearchThumbnails(
    val medium: Thumbnail? = null,
    val default: Thumbnail? = null
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
