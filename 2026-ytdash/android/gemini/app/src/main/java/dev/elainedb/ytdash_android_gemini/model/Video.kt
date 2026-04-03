package dev.elainedb.ytdash_android_gemini.model

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
    val recordingDate: String? = null,
    val cacheTimestamp: Long = 0
) {
    fun mergeWithDetails(
        tags: List<String>?,
        locationCity: String?,
        locationCountry: String?,
        latitude: Double?,
        longitude: Double?,
        recordingDate: String?
    ): Video {
        return this.copy(
            tags = tags ?: this.tags,
            locationCity = locationCity ?: this.locationCity,
            locationCountry = locationCountry ?: this.locationCountry,
            locationLatitude = latitude ?: this.locationLatitude,
            locationLongitude = longitude ?: this.locationLongitude,
            recordingDate = recordingDate ?: this.recordingDate
        )
    }
}

fun YouTubeVideoItem.toVideo(): Video? {
    val videoId = this.id.videoId ?: return null
    return Video(
        id = videoId,
        title = this.snippet.title,
        channelName = this.snippet.channelTitle,
        channelId = this.snippet.channelId,
        publishedAt = this.snippet.publishedAt,
        thumbnailUrl = this.snippet.thumbnails.high?.url ?: this.snippet.thumbnails.medium?.url ?: this.snippet.thumbnails.default?.url ?: "",
        description = this.snippet.description
    )
}
