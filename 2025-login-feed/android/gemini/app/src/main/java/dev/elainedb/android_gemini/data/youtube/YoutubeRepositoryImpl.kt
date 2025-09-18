package dev.elainedb.android_gemini.data.youtube

import dev.elainedb.android_gemini.domain.youtube.YoutubeRepository
import dev.elainedb.android_gemini.domain.youtube.YoutubeVideo
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import javax.inject.Inject
import javax.inject.Named

class YoutubeRepositoryImpl @Inject constructor(
    private val youtubeApiService: YoutubeApiService,
    @Named("youtubeApiKey") private val apiKey: String
) : YoutubeRepository {

    override suspend fun getVideos(channelIds: List<String>): List<YoutubeVideo> = coroutineScope {
        val videoItems = channelIds.map {
            async {
                youtubeApiService.search(apiKey, it).items
            }
        }.awaitAll().flatten()

        videoItems.map {
            YoutubeVideo(
                videoId = it.id.videoId,
                title = it.snippet.title,
                thumbnailUrl = it.snippet.thumbnails.high.url,
                channelTitle = it.snippet.channelTitle,
                publishedAt = it.snippet.publishedAt
            )
        }.sortedByDescending { it.publishedAt }
    }
}
