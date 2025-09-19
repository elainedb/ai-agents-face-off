
package dev.elainedb.android_gemini.data.youtube

import dev.elainedb.android_gemini.domain.youtube.Location
import kotlinx.serialization.Serializable

@Serializable
data class YoutubeVideosListResponse(
    val items: List<YoutubeVideoDetailsItem>
)

@Serializable
data class YoutubeVideoDetailsItem(
    val id: String,
    val snippet: VideoSnippet,
    val recordingDetails: RecordingDetails? = null
)

@Serializable
data class VideoSnippet(
    val publishedAt: String,
    val channelTitle: String,
    val title: String,
    val thumbnails: Thumbnails,
    val tags: List<String>? = null
)

@Serializable
data class RecordingDetails(
    val location: Location? = null,
    val recordingDate: String? = null
)
