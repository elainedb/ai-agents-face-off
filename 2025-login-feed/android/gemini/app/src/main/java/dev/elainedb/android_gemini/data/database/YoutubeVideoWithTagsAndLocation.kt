
package dev.elainedb.android_gemini.data.database

import androidx.room.Embedded
import androidx.room.Relation

data class YoutubeVideoWithTagsAndLocation(
    @Embedded val video: YoutubeVideoEntity,
    @Relation(
        parentColumn = "videoId",
        entityColumn = "videoId"
    )
    val tags: List<TagEntity>,
    @Relation(
        parentColumn = "videoId",
        entityColumn = "videoId"
    )
    val location: LocationEntity?
)
