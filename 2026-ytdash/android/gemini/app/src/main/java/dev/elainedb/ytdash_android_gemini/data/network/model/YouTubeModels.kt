package dev.elainedb.ytdash_android_gemini.data.network.model

import dev.elainedb.ytdash_android_gemini.domain.model.Video
import kotlinx.serialization.SerialName
import kotlinx.serialization.Serializable

@Serializable
data class YouTubeSearchResponse(
    val nextPageToken: String? = null,
    val items: List<YouTubeVideoItem> = emptyList()
)

@Serializable
data class YouTubeVideoItem(
    val id: YouTubeVideoId,
    val snippet: YouTubeVideoSnippet
)

@Serializable
data class YouTubeVideoId(
    val videoId: String? = null
)

@Serializable
data class YouTubeVideoSnippet(
    val title: String,
    val description: String,
    val channelTitle: String,
    val channelId: String,
    val publishedAt: String,
    val thumbnails: YouTubeThumbnails
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
    val items: List<YouTubeVideoDetails> = emptyList()
)

@Serializable
data class YouTubeVideoDetails(
    val id: String,
    val snippet: YouTubeVideoDetailsSnippet? = null,
    val recordingDetails: YouTubeRecordingDetails? = null
)

@Serializable
data class YouTubeVideoDetailsSnippet(
    val tags: List<String> = emptyList()
)

@Serializable
data class YouTubeRecordingDetails(
    val location: YouTubeLocation? = null,
    val recordingDate: String? = null
)

@Serializable
data class YouTubeLocation(
    val latitude: Double,
    val longitude: Double
)

fun YouTubeVideoItem.toVideo(): Video {
    return Video(
        id = id.videoId ?: "",
        title = snippet.title,
        channelName = snippet.channelTitle,
        channelId = snippet.channelId,
        publishedAt = snippet.publishedAt,
        thumbnailUrl = snippet.thumbnails.high?.url ?: snippet.thumbnails.medium?.url ?: snippet.thumbnails.default?.url ?: "",
        description = snippet.description
    )
}
