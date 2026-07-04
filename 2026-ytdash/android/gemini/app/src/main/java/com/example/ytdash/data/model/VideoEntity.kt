package com.example.ytdash.data.model

import androidx.room.Entity
import androidx.room.PrimaryKey

@Entity(tableName = "videos")
data class VideoEntity(
    @PrimaryKey val id: String,
    val title: String,
    val description: String,
    val category: String,
    val publishedAt: String,
    val thumbnailUrl: String?,
    val lat: Double?,
    val lng: Double?,
    val channelId: String,
    val insertionIndex: Int = 0
)
