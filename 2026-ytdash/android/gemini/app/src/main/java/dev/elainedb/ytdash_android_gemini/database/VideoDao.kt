package dev.elainedb.ytdash_android_gemini.database

import androidx.room.*
import kotlinx.coroutines.flow.Flow

@Dao
interface VideoDao {

    @Query("""
        SELECT * FROM videos 
        WHERE (:channelName IS NULL OR channelName = :channelName)
        AND (:country IS NULL OR locationCountry = :country)
        ORDER BY 
        CASE WHEN :sortBy = 'pub_newest' THEN publishedAt END DESC,
        CASE WHEN :sortBy = 'pub_oldest' THEN publishedAt END ASC,
        CASE WHEN :sortBy = 'rec_newest' THEN recordingDate END DESC,
        CASE WHEN :sortBy = 'rec_oldest' THEN recordingDate END ASC,
        publishedAt DESC
    """)
    fun getVideosWithFiltersAndSort(
        channelName: String?,
        country: String?,
        sortBy: String
    ): Flow<List<VideoEntity>>

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

    @Query("DELETE FROM videos")
    suspend fun deleteAllVideos()

    @Query("DELETE FROM videos WHERE cacheTimestamp <= :threshold")
    suspend fun deleteOldVideos(threshold: Long)
}
