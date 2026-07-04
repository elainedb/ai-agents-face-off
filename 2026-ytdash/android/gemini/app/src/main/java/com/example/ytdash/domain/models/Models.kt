package com.example.ytdash.domain.models

import kotlinx.serialization.Serializable

@Serializable
data class Video(
    val id: String,
    val title: String,
    val description: String,
    val publishedAt: String,
    val category: String, // Source channel label
    val thumbnailUrl: String?,
    val lat: Double?,
    val lng: Double?
) {
    val youtubeUrl: String
        get() = "https://www.youtube.com/watch?v=$id"
}

@Serializable
data class Channel(
    val id: String,
    val label: String
)
