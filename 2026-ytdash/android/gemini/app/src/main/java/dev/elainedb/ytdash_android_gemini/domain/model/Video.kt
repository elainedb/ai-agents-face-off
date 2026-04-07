package dev.elainedb.ytdash_android_gemini.domain.model

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
) {
    fun mergeWithDetails(
        tags: List<String>,
        latitude: Double?,
        longitude: Double?,
        recordingDate: String?
    ): Video {
        return this.copy(
            tags = tags,
            locationLatitude = latitude,
            locationLongitude = longitude,
            recordingDate = recordingDate
        )
    }
}
