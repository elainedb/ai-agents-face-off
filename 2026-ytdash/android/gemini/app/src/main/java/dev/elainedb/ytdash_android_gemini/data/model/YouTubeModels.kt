package dev.elainedb.ytdash_android_gemini.data.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class YouTubeSearchResponse(
    @SerialName("nextPageToken") val nextPageToken: String? = null,
    @SerialName("items") val items: List<YouTubeVideoItem>
)

@Serializable
data class YouTubeVideoItem(
    @SerialName("id") val id: YouTubeVideoId,
    @SerialName("snippet") val snippet: YouTubeVideoSnippet
)

@Serializable
data class YouTubeVideoId(
    @SerialName("videoId") val videoId: String? = null
)

@Serializable
data class YouTubeVideoSnippet(
    @SerialName("publishedAt") val publishedAt: String,
    @SerialName("channelId") val channelId: String,
    @SerialName("title") val title: String,
    @SerialName("description") val description: String,
    @SerialName("thumbnails") val thumbnails: YouTubeThumbnails,
    @SerialName("channelTitle") val channelTitle: String
)

@Serializable
data class YouTubeThumbnails(
    @SerialName("high") val high: YouTubeThumbnail? = null,
    @SerialName("medium") val medium: YouTubeThumbnail? = null,
    @SerialName("default") val default: YouTubeThumbnail? = null
)

@Serializable
data class YouTubeThumbnail(
    @SerialName("url") val url: String
)

@Serializable
data class YouTubeVideosResponse(
    @SerialName("items") val items: List<YouTubeVideoDetails>
)

@Serializable
data class YouTubeVideoDetails(
    @SerialName("id") val id: String,
    @SerialName("snippet") val snippet: YouTubeVideoDetailsSnippet? = null,
    @SerialName("recordingDetails") val recordingDetails: YouTubeRecordingDetails? = null
)

@Serializable
data class YouTubeVideoDetailsSnippet(
    @SerialName("tags") val tags: List<String>? = null
)

@Serializable
data class YouTubeRecordingDetails(
    @SerialName("location") val location: YouTubeLocation? = null,
    @SerialName("recordingDate") val recordingDate: String? = null
)

@Serializable
data class YouTubeLocation(
    @SerialName("latitude") val latitude: Double? = null,
    @SerialName("longitude") val longitude: Double? = null,
    @SerialName("locationDescription") val locationDescription: String? = null
)
