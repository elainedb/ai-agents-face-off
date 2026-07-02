package com.example.ytdash.data

import kotlinx.serialization.Serializable

@Serializable
data class ChannelConfig(
    val id: String,
    val label: String
)

@Serializable
data class Location(
    val lat: Double,
    val lng: Double
)

@Serializable
data class Video(
    val id: String,
    val title: String,
    val description: String,
    val category: String, // Stores the label of the channel it was fetched from
    val publishedAt: String,
    val thumbnailUrl: String,
    val location: Location?
) {
    val youtubeUrl: String
        get() = "https://www.youtube.com/watch?v=$id"
}

// API Parsing Types

@Serializable
data class YouTubeSearchResponse(
    val nextPageToken: String? = null,
    val items: List<SearchItem> = emptyList()
)

@Serializable
data class SearchItem(
    val id: SearchId,
    val snippet: Snippet? = null
)

@Serializable
data class SearchId(
    val videoId: String? = null
)

@Serializable
data class Snippet(
    val publishedAt: String? = null,
    val title: String? = null,
    val description: String? = null,
    val channelTitle: String? = null,
    val channelId: String? = null,
    val thumbnails: Thumbnails? = null
)

@Serializable
data class Thumbnails(
    val default: Thumbnail? = null,
    val medium: Thumbnail? = null,
    val high: Thumbnail? = null
)

@Serializable
data class Thumbnail(
    val url: String? = null
)

@Serializable
data class YouTubeVideosResponse(
    val items: List<VideoItem> = emptyList()
)

@Serializable
data class VideoItem(
    val id: String,
    val snippet: Snippet? = null,
    val recordingDetails: RecordingDetails? = null
)

@Serializable
data class RecordingDetails(
    val location: RecordingLocation? = null
)

@Serializable
data class RecordingLocation(
    val latitude: Double? = null,
    val longitude: Double? = null
)
