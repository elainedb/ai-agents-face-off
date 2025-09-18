package dev.elainedb.android_gemini.domain.youtube

data class YoutubeVideo(
    val videoId: String,
    val title: String,
    val thumbnailUrl: String,
    val channelTitle: String,
    val publishedAt: String
)

interface YoutubeRepository {
    suspend fun getVideos(channelIds: List<String>): List<YoutubeVideo>
}
