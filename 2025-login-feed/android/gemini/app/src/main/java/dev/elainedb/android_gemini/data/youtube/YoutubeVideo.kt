package dev.elainedb.android_gemini.data.youtube

import kotlinx.serialization.Serializable

@Serializable
data class YoutubeSearchListResponse(
    val items: List<YoutubeVideoItem>
)

@Serializable
data class YoutubeVideoItem(
    val id: VideoId,
    val snippet: Snippet
)

@Serializable
data class VideoId(
    val videoId: String
)

@Serializable
data class Snippet(
    val publishedAt: String,
    val channelTitle: String,
    val title: String,
    val thumbnails: Thumbnails
)

@Serializable
data class Thumbnails(
    val high: Thumbnail
)

@Serializable
data class Thumbnail(
    val url: String
)
