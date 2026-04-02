package dev.elainedb.ytdash_android_gemini.model

import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class YouTubeSearchResponse(
    val items: List<YouTubeVideoItem>,
    val nextPageToken: String? = null
)

@Serializable
data class YouTubeVideoItem(
    val id: YouTubeVideoId,
    val snippet: YouTubeVideoSnippet
)

@Serializable
data class YouTubeVideoId(
    val videoId: String
)

@Serializable
data class YouTubeVideoSnippet(
    val publishedAt: String,
    val channelId: String,
    val title: String,
    val description: String,
    val thumbnails: YouTubeThumbnails,
    val channelTitle: String
)

@Serializable
data class YouTubeThumbnails(
    val default: YouTubeThumbnail? = null,
    val medium: YouTubeThumbnail? = null,
    val high: YouTubeThumbnail? = null
)

@Serializable
data class YouTubeThumbnail(
    val url: String
)

@Serializable
data class YouTubeVideosResponse(
    val items: List<YouTubeVideoDetails>
)

@Serializable
data class YouTubeVideoDetails(
    val id: String,
    val snippet: YouTubeVideoDetailsSnippet? = null,
    val recordingDetails: YouTubeRecordingDetails? = null
)

@Serializable
data class YouTubeVideoDetailsSnippet(
    val tags: List<String>? = null
)

@Serializable
data class YouTubeRecordingDetails(
    val recordingDate: String? = null,
    val location: YouTubeLocation? = null
)

@Serializable
data class YouTubeLocation(
    val latitude: Double? = null,
    val longitude: Double? = null
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
    return Video(
        id = id.videoId,
        title = snippet.title,
        channelName = snippet.channelTitle,
        channelId = snippet.channelId,
        publishedAt = snippet.publishedAt,
        thumbnailUrl = snippet.thumbnails.high?.url ?: snippet.thumbnails.medium?.url ?: snippet.thumbnails.default?.url ?: "",
        description = snippet.description
    )
}

fun Video.mergeWithDetails(details: YouTubeVideoDetails): Video {
    return this.copy(
        tags = details.snippet?.tags ?: emptyList(),
        locationLatitude = details.recordingDetails?.location?.latitude,
        locationLongitude = details.recordingDetails?.location?.longitude,
        recordingDate = details.recordingDetails?.recordingDate
    )
}
