package com.example.ytdash.data.repository

import com.example.ytdash.data.api.YouTubeApi
import com.example.ytdash.data.cache.VideoCache
import com.example.ytdash.domain.models.Channel
import com.example.ytdash.domain.models.Video
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext

class VideoRepository(
    private val api: YouTubeApi,
    private val cache: VideoCache,
    private val configRepository: ConfigRepository,
    private val apiKey: String
) {
    suspend fun fetchVideos(): Result<List<Video>> = withContext(Dispatchers.IO) {
        try {
            val channels = configRepository.getChannels()
            val allVideos = mutableListOf<Video>()

            for (channel in channels) {
                var pageToken: String? = null
                val channelVideoIds = mutableListOf<String>()
                
                // Fetch all pages for the channel
                do {
                    val response = api.searchList(
                        key = apiKey,
                        channelId = channel.id,
                        pageToken = pageToken
                    )
                    
                    val ids = response.items.map { it.id.videoId }
                    channelVideoIds.addAll(ids)
                    
                    pageToken = response.nextPageToken
                } while (pageToken != null)

                // Fetch details for all video IDs in chunks of 50
                val chunkedIds = channelVideoIds.chunked(50)
                for (chunk in chunkedIds) {
                    val detailsResponse = api.videosList(
                        key = apiKey,
                        ids = chunk.joinToString(",")
                    )
                    
                    val mappedVideos = detailsResponse.items.map { item ->
                        Video(
                            id = item.id,
                            title = item.snippet.title,
                            description = item.snippet.description,
                            publishedAt = item.snippet.publishedAt,
                            category = channel.label,
                            thumbnailUrl = item.snippet.thumbnails.medium?.url,
                            lat = item.recordingDetails?.location?.latitude,
                            lng = item.recordingDetails?.location?.longitude
                        )
                    }
                    allVideos.addAll(mappedVideos)
                }
            }

            // Deduplicate by ID
            val uniqueVideos = allVideos.distinctBy { it.id }
            
            // Save to cache
            cache.saveVideos(uniqueVideos)
            
            Result.success(uniqueVideos)
        } catch (e: Exception) {
            // Fallback to cache on error
            val cached = cache.getVideos()
            if (cached != null && cached.isNotEmpty()) {
                Result.success(cached)
            } else {
                Result.failure(e)
            }
        }
    }
}
