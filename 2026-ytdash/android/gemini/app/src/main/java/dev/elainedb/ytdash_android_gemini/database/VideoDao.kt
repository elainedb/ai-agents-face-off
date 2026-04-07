package dev.elainedb.ytdash_android_gemini.database

import androidx.room.Dao
import androidx.room.Insert
import androidx.room.OnConflictStrategy
import androidx.room.Query
import kotlinx.coroutines.flow.Flow

@Dao
interface VideoDao {
    @Query("""
        SELECT * FROM videos 
        WHERE (:channelName IS NULL OR :channelName = 'All Channels' OR channelName = :channelName)
        AND (:country IS NULL OR :country = 'All Countries' OR locationCountry = :country)
        ORDER BY 
            CASE WHEN :sortBy = 'Publication Date (Newest First)' THEN publishedAt END DESC,
            CASE WHEN :sortBy = 'Publication Date (Oldest First)' THEN publishedAt END ASC,
            CASE WHEN :sortBy = 'Recording Date (Newest First)' THEN recordingDate END DESC,
            CASE WHEN :sortBy = 'Recording Date (Oldest First)' THEN recordingDate END ASC
    """)
    fun getVideosWithFiltersAndSort(channelName: String?, country: String?, sortBy: String?): Flow<List<VideoEntity>>

    @Query("SELECT DISTINCT locationCountry FROM videos WHERE locationCountry IS NOT NULL ORDER BY locationCountry ASC")
    fun getDistinctCountries(): Flow<List<String>>

    @Query("SELECT DISTINCT channelName FROM videos ORDER BY channelName ASC")
    fun getDistinctChannels(): Flow<List<String>>

    @Query("SELECT * FROM videos WHERE locationLatitude IS NOT NULL AND locationLongitude IS NOT NULL")
    suspend fun getVideosWithLocation(): List<VideoEntity>

    @Query("SELECT * FROM videos WHERE cacheTimestamp > :threshold")
    suspend fun getVideosNewerThan(threshold: Long): List<VideoEntity>

    @Query("SELECT COUNT(*) FROM videos")
    fun getTotalVideoCount(): Flow<Int>

    @Insert(onConflict = OnConflictStrategy.REPLACE)
    suspend fun insertVideos(videos: List<VideoEntity>)

    @Query("DELETE FROM videos WHERE cacheTimestamp < :threshold")
    suspend fun deleteOldVideos(threshold: Long)

    @Query("DELETE FROM videos")
    suspend fun deleteAllVideos()
}