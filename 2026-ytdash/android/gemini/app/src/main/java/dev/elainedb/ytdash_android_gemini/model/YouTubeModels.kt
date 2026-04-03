package dev.elainedb.ytdash_android_gemini.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class YouTubeSearchResponse(
    @SerialName("nextPageToken") val nextPageToken: String? = null,
    @SerialName("items") val items: List<YouTubeVideoItem> = emptyList()
)

@Serializable
data class YouTubeVideoItem(
    @SerialName("id") val id: YouTubeVideoId,
    @SerialName("snippet") val snippet: YouTubeVideoSnippet
)

@Serializable
data class YouTubeVideoId(
    @SerialName("videoId") val videoId: String
)

@Serializable
data class YouTubeVideoSnippet(
    @SerialName("title") val title: String,
    @SerialName("description") val description: String,
    @SerialName("channelTitle") val channelTitle: String,
    @SerialName("channelId") val channelId: String,
    @SerialName("publishedAt") val publishedAt: String,
    @SerialName("thumbnails") val thumbnails: YouTubeThumbnails
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
    @SerialName("items") val items: List<YouTubeVideoDetails> = emptyList()
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
    @SerialName("longitude") val longitude: Double? = null
)

data class Video(
    val id: String,
    val title: String,
    val channelName: String,
    val channelId: String,
    val publishedAt: String,
    val thumbnailUrl: String,
    val description: String,
    val tags: List<String> = emptyList(),
    val locationCity: String? = null,
    val locationCountry: String? = null,
    val locationLatitude: Double? = null,
    val locationLongitude: Double? = null,
    val recordingDate: String? = null
)

fun YouTubeVideoItem.toVideo(): Video {
    val thumbnailUrl = snippet.thumbnails.high?.url 
        ?: snippet.thumbnails.medium?.url 
        ?: snippet.thumbnails.default?.url 
        ?: ""

    return Video(
        id = id.videoId,
        title = snippet.title,
        channelName = snippet.channelTitle,
        channelId = snippet.channelId,
        publishedAt = snippet.publishedAt,
        thumbnailUrl = thumbnailUrl,
        description = snippet.description
    )
}

fun Video.mergeWithDetails(
    tags: List<String>?,
    latitude: Double?,
    longitude: Double?,
    recordingDate: String?,
    city: String?,
    country: String?
): Video {
    return this.copy(
        tags = tags ?: this.tags,
        locationLatitude = latitude ?: this.locationLatitude,
        locationLongitude = longitude ?: this.locationLongitude,
        recordingDate = recordingDate ?: this.recordingDate,
        locationCity = city ?: this.locationCity,
        locationCountry = country ?: this.locationCountry
    )
}
