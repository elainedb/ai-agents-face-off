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
    @SerialName("videoId") val videoId: String = ""
)

@Serializable
data class YouTubeVideoSnippet(
    @SerialName("title") val title: String = "",
    @SerialName("channelTitle") val channelTitle: String = "",
    @SerialName("channelId") val channelId: String = "",
    @SerialName("publishedAt") val publishedAt: String = "",
    @SerialName("thumbnails") val thumbnails: YouTubeThumbnails,
    @SerialName("description") val description: String = ""
)

@Serializable
data class YouTubeThumbnails(
    @SerialName("medium") val medium: YouTubeThumbnail? = null,
    @SerialName("high") val high: YouTubeThumbnail? = null,
    @SerialName("default") val defaultThumbnail: YouTubeThumbnail? = null
)

@Serializable
data class YouTubeThumbnail(
    @SerialName("url") val url: String = ""
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

@Serializable
data class YouTubeVideosResponse(
    @SerialName("items") val items: List<YouTubeVideoDetails> = emptyList()
)

@Serializable
data class YouTubeVideoDetails(
    @SerialName("id") val id: String = "",
    @SerialName("snippet") val snippet: YouTubeVideoDetailsSnippet? = null,
    @SerialName("recordingDetails") val recordingDetails: YouTubeRecordingDetails? = null
)

@Serializable
data class YouTubeVideoDetailsSnippet(
    @SerialName("tags") val tags: List<String> = emptyList()
)

@Serializable
data class YouTubeRecordingDetails(
    @SerialName("recordingDate") val recordingDate: String? = null,
    @SerialName("location") val location: YouTubeLocation? = null
)

@Serializable
data class YouTubeLocation(
    @SerialName("latitude") val latitude: Double? = null,
    @SerialName("longitude") val longitude: Double? = null
)

fun YouTubeVideoItem.toVideo(): Video {
    val thumbnailUrl = snippet.thumbnails.high?.url
        ?: snippet.thumbnails.medium?.url
        ?: snippet.thumbnails.defaultThumbnail?.url
        ?: ""

    return Video(
        id = id.videoId,
        title = snippet.title,
        channelName = snippet.channelTitle,
        channelId = snippet.channelId,
        publishedAt = snippet.publishedAt.substringBefore("T"),
        thumbnailUrl = thumbnailUrl,
        description = snippet.description
    )
}

fun Video.mergeWithDetails(
    details: YouTubeVideoDetails?,
    locationCity: String?,
    locationCountry: String?
): Video {
    if (details == null) return this
    
    val tags = details.snippet?.tags ?: this.tags
    val latitude = details.recordingDetails?.location?.latitude ?: this.locationLatitude
    val longitude = details.recordingDetails?.location?.longitude ?: this.locationLongitude
    val recordingDate = details.recordingDetails?.recordingDate?.substringBefore("T") ?: this.recordingDate
    
    return this.copy(
        tags = tags,
        locationLatitude = latitude,
        locationLongitude = longitude,
        locationCity = locationCity ?: this.locationCity,
        locationCountry = locationCountry ?: this.locationCountry,
        recordingDate = recordingDate
    )
}
