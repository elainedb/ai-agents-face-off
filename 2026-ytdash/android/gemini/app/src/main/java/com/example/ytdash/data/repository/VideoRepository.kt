package com.example.ytdash.data.repository

import com.example.ytdash.config.AppConfig
import com.example.ytdash.data.local.VideoDao
import com.example.ytdash.data.model.VideoEntity
import com.example.ytdash.data.network.YoutubeApi

import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import com.example.ytdash.config.ChannelConfig

class VideoRepository(
    private val api: YoutubeApi,
    private val dao: VideoDao,
    val appConfig: AppConfig,
    val channels: List<ChannelConfig>
) {
    suspend fun getVideos(): List<VideoEntity> = withContext(Dispatchers.IO) {
        return@withContext dao.getAllVideos()
    }

    suspend fun refreshVideos() = withContext(Dispatchers.IO) {
        val key = appConfig.apiKey ?: "DUMMY_API_KEY"
        val allEntities = mutableListOf<VideoEntity>()

        for (channel in channels) {
            var pageToken: String? = null
            do {
                val searchResponse = api.listUploads(key = key, channelId = channel.id, pageToken = pageToken)
                android.util.Log.d("YTDash", "Fetched ${searchResponse.items.size} items for channel ${channel.id}")
                
                val videoIds = searchResponse.items.map { it.id.videoId }
                if (videoIds.isNotEmpty()) {
                    val idChunks = videoIds.chunked(50)
                    for (chunk in idChunks) {
                        val idsStr = chunk.joinToString(",")
                        val videosResponse = api.getVideos(key = key, id = idsStr)
                        val locationMap = videosResponse.items.associate { it.id to it.recordingDetails?.location }
                        
                        val entities = searchResponse.items.filter { chunk.contains(it.id.videoId) }.mapIndexed { index, item ->
                            val loc = locationMap[item.id.videoId]
                            VideoEntity(
                                id = item.id.videoId,
                                title = item.snippet.title,
                                description = item.snippet.description,
                                publishedAt = item.snippet.publishedAt,
                                category = channel.label,
                                thumbnailUrl = item.snippet.thumbnails?.medium?.url,
                                lat = loc?.latitude,
                                lng = loc?.longitude,
                                channelId = channel.id,
                                insertionIndex = allEntities.size + index
                            )
                        }
                        allEntities.addAll(entities)
                    }
                }
                pageToken = searchResponse.nextPageToken
            } while (pageToken != null)
        }
        
        android.util.Log.d("YTDash", "Total videos fetched: ${allEntities.size}")
        if (allEntities.isNotEmpty()) {
            dao.insertAll(allEntities)
        }
    }
    
    suspend fun clearVideos() = withContext(Dispatchers.IO) {
        dao.clearAll()
    }
}
