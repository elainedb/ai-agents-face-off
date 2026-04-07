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
        tags: List<String>?,
        lat: Double?,
        lng: Double?,
        city: String?,
        country: String?,
        recDate: String?
    ): Video {
        return this.copy(
            tags = tags ?: this.tags,
            locationLatitude = lat ?: this.locationLatitude,
            locationLongitude = lng ?: this.locationLongitude,
            locationCity = city ?: this.locationCity,
            locationCountry = country ?: this.locationCountry,
            recordingDate = recDate ?: this.recordingDate
        )
    }
}
