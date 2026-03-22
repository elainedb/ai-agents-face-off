package dev.elainedb.ytdash_android_gemini.data.model

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

fun Video.mergeWithDetails(
    details: YouTubeVideoDetails?,
    city: String?,
    country: String?
): Video {
    if (details == null) return this
    return this.copy(
        tags = details.snippet?.tags ?: emptyList(),
        locationCity = city,
        locationCountry = country,
        locationLatitude = details.recordingDetails?.location?.latitude,
        locationLongitude = details.recordingDetails?.location?.longitude,
        recordingDate = details.recordingDetails?.recordingDate?.substringBefore("T")
    )
}
