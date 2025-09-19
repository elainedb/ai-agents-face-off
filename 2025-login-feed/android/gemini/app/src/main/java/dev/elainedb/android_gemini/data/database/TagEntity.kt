
package dev.elainedb.android_gemini.data.database

import androidx.room.Entity
import androidx.room.ForeignKey
import androidx.room.Index
import androidx.room.PrimaryKey

@Entity(
    tableName = "tags",
    foreignKeys = [
        ForeignKey(
            entity = YoutubeVideoEntity::class,
            parentColumns = ["videoId"],
            childColumns = ["videoId"],
            onDelete = ForeignKey.CASCADE
        )
    ],
    indices = [Index(value = ["videoId"])]
)
data class TagEntity(
    @PrimaryKey(autoGenerate = true)
    val id: Int = 0,
    val videoId: String,
    val tag: String
)
