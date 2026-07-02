package com.example.ytdash.data.model

data class Video(
    val id: String,
    val title: String,
    val description: String,
    val publishedAt: String,
    val category: String, // Maps to the channel's label
    val thumbnailUrl: String,
    val lat: Double?,
    val lng: Double?
) {
    val youtubeWatchUrl: String
        get() = "https://www.youtube.com/watch?v=$id"
}
