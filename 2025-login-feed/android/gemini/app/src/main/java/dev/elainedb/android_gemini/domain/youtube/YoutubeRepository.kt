package dev.elainedb.android_gemini.domain.youtube

import dev.elainedb.android_gemini.data.database.YoutubeVideoWithTagsAndLocation
import kotlinx.serialization.Serializable

data class YoutubeVideo(
    val videoId: String,
    val title: String,
    val thumbnailUrl: String,
    val channelTitle: String,
    val publishedAt: String,
    val tags: List<String>? = null,
    val location: Location? = null,
    val recordingDate: String? = null,
    val country: String? = null,
    val city: String? = null
)

@Serializable
data class Location(
    val latitude: Double,
    val longitude: Double
)

interface YoutubeRepository {
    suspend fun getVideos(channelIds: List<String>): List<YoutubeVideo>
    suspend fun getVideosWithLocation(): List<YoutubeVideoWithTagsAndLocation>
}