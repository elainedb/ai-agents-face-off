package com.example.ytdash.data.local

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import com.example.ytdash.data.model.VideoEntity

@Dao
interface VideoDao {
    @Query("SELECT * FROM videos ORDER BY insertionIndex ASC")
    fun getAllVideos(): List<VideoEntity>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    fun insertAll(videos: List<VideoEntity>)

    @Query("DELETE FROM videos")
    fun clearAll()
}
