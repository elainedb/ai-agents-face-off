
package dev.elainedb.android_gemini.data.database

import androidx.room.Embedded
import androidx.room.Entity
import androidx.room.PrimaryKey
import dev.elainedb.android_gemini.domain.youtube.Location

@Entity(tableName = "videos")
data class YoutubeVideoEntity(
    @PrimaryKey
    val videoId: String,
    val title: String,
    val thumbnailUrl: String,
    val channelTitle: String,
    val publishedAt: String,
    val recordingDate: String? = null,
    val lastRefreshed: Long = System.currentTimeMillis()
)
