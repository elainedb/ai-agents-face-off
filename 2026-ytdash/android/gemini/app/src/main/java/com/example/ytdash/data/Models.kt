package com.example.ytdash.data

import kotlinx.serialization.Serializable

@Serializable
data class ChannelConfig(
    val id: String,
    val label: String
)

@Serializable
data class SearchResponse(
    val items: List<SearchItem> = emptyList(),
    val nextPageToken: String? = null
)

@Serializable
data class SearchItem(
    val id: SearchItemId,
    val snippet: SearchSnippet
)

@Serializable
data class SearchItemId(
    val videoId: String? = null
)

@Serializable
data class SearchSnippet(
    val publishedAt: String,
    val title: String,
    val description: String,
    val channelId: String? = null,
    val channelTitle: String? = null,
    val thumbnails: Thumbnails? = null
)

@Serializable
data class Thumbnails(
    val default: ThumbnailDetails? = null,
    val medium: ThumbnailDetails? = null,
    val high: ThumbnailDetails? = null
)

@Serializable
data class ThumbnailDetails(
    val url: String
)

@Serializable
data class VideoListResponse(
    val items: List<VideoItem> = emptyList()
)

@Serializable
data class VideoItem(
    val id: String,
    val snippet: SearchSnippet? = null,
    val recordingDetails: RecordingDetails? = null
)

@Serializable
data class RecordingDetails(
    val location: LocationDetails? = null
)

@Serializable
data class LocationDetails(
    val latitude: Double,
    val longitude: Double
)

@Serializable
data class Video(
    val id: String,
    val title: String,
    val description: String,
    val publishedAt: String, // ISO-8601 string
    val category: String, // channel label from config
    val thumbnailUrl: String,
    val lat: Double? = null,
    val lng: Double? = null
) {
    val youtubeUrl: String
        get() = "https://www.youtube.com/watch?v=$id"
}
