package dev.elainedb.android_gemini.data.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import androidx.room.Transaction

@Dao
interface YoutubeVideoDao {
    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertAll(videos: List<YoutubeVideoEntity>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertTags(tags: List<TagEntity>)

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertLocation(location: LocationEntity)

    @Transaction
    @Query("SELECT * FROM videos")
    suspend fun getVideosWithTagsAndLocation(): List<YoutubeVideoWithTagsAndLocation>

    @Transaction
    @Query("SELECT * FROM videos WHERE videoId IN (SELECT videoId FROM locations)")
    suspend fun getVideosWithLocation(): List<YoutubeVideoWithTagsAndLocation>
}