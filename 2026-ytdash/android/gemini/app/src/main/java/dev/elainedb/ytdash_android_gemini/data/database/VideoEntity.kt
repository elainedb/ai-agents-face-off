package dev.elainedb.ytdash_android_gemini.data.database

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "videos")
data class VideoEntity(
    @PrimaryKey val id: String,
    val title: String,
    val channelName: String,
    val channelId: String,
    val publishedAt: String,
    val thumbnailUrl: String,
    val description: String,
    val tags: String, // comma-separated
    val locationCity: String?,
    val locationCountry: String?,
    val locationLatitude: Double?,
    val locationLongitude: Double?,
    val recordingDate: String?,
    val cacheTimestamp: Long
)
