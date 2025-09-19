package dev.elainedb.android_gemini.data.youtube

import android.content.Context
import android.location.Geocoder
import dev.elainedb.android_gemini.data.database.LocationEntity
import dev.elainedb.android_gemini.data.database.TagEntity
import dev.elainedb.android_gemini.data.database.YoutubeVideoDao
import dev.elainedb.android_gemini.data.database.YoutubeVideoEntity
import dev.elainedb.android_gemini.domain.youtube.Location
import dev.elainedb.android_gemini.domain.youtube.YoutubeRepository
import dev.elainedb.android_gemini.domain.youtube.YoutubeVideo
import kotlinx.coroutines.async
import kotlinx.coroutines.awaitAll
import kotlinx.coroutines.coroutineScope
import java.util.Locale
import java.util.concurrent.TimeUnit

class YoutubeRepositoryImpl(
    private val youtubeApiService: YoutubeApiService,
    private val apiKey: String,
    private val youtubeVideoDao: YoutubeVideoDao,
    private val context: Context
) : YoutubeRepository {

    override suspend fun getVideos(channelIds: List<String>): List<YoutubeVideo> = coroutineScope {
        val cachedVideos = youtubeVideoDao.getVideosWithTagsAndLocation()
        val firstVideo = cachedVideos.firstOrNull()?.video

        if (cachedVideos.isNotEmpty() && firstVideo != null && System.currentTimeMillis() - firstVideo.lastRefreshed < TimeUnit.HOURS.toMillis(24)) {
            return@coroutineScope cachedVideos.map {
                YoutubeVideo(
                    videoId = it.video.videoId,
                    title = it.video.title,
                    thumbnailUrl = it.video.thumbnailUrl,
                    channelTitle = it.video.channelTitle,
                    publishedAt = it.video.publishedAt,
                    tags = it.tags.map { it.tag },
                    location = it.location?.let { Location(it.latitude, it.longitude) },
                    recordingDate = it.video.recordingDate,
                    country = it.location?.country,
                    city = it.location?.city
                )
            }
        }

        val videoItems = channelIds.map { channelId ->
            async {
                var nextPageToken: String? = null
                val channelVideos = mutableListOf<YoutubeVideoItem>()
                do {
                    val response = youtubeApiService.search(apiKey, channelId, pageToken = nextPageToken)
                    channelVideos.addAll(response.items)
                    nextPageToken = response.nextPageToken
                } while (nextPageToken != null)
                channelVideos
            }
        }.awaitAll().flatten()

        val videoIds = videoItems.map { it.id.videoId }.chunked(50).map { it.joinToString(",") }
        val videoDetails = videoIds.map {
            async {
                youtubeApiService.videos(apiKey, it).items
            }
        }.awaitAll().flatten().associateBy { it.id }

        val geocoder = Geocoder(context, Locale.getDefault())

        val videos = videoItems.map {
            val details = videoDetails[it.id.videoId]
            val location = details?.recordingDetails?.location
            var country: String? = null
            var city: String? = null
            if (location != null) {
                try {
                    val addresses = geocoder.getFromLocation(location.latitude, location.longitude, 1)
                    if (addresses?.isNotEmpty() == true) {
                        val address = addresses[0]
                        country = address.countryName
                        city = address.locality
                    }
                } catch (e: Exception) {
                    // Handle exception
                }
            }

            YoutubeVideo(
                videoId = it.id.videoId,
                title = it.snippet.title,
                thumbnailUrl = it.snippet.thumbnails.high.url,
                channelTitle = it.snippet.channelTitle,
                publishedAt = it.snippet.publishedAt,
                tags = details?.snippet?.tags,
                location = location,
                recordingDate = details?.recordingDetails?.recordingDate,
                country = country,
                city = city
            )
        }

        val videoEntities = videos.map {
            YoutubeVideoEntity(
                videoId = it.videoId,
                title = it.title,
                thumbnailUrl = it.thumbnailUrl,
                channelTitle = it.channelTitle,
                publishedAt = it.publishedAt,
                recordingDate = it.recordingDate
            )
        }
        youtubeVideoDao.insertAll(videoEntities)

        videos.forEach { video ->
            video.tags?.let {
                val tagEntities = it.map { tag ->
                    TagEntity(videoId = video.videoId, tag = tag)
                }
                youtubeVideoDao.insertTags(tagEntities)
            }
            video.location?.let {
                val locationEntity = LocationEntity(
                    videoId = video.videoId,
                    latitude = it.latitude,
                    longitude = it.longitude,
                    country = video.country,
                    city = video.city
                )
                youtubeVideoDao.insertLocation(locationEntity)
            }
        }

        videos.sortedByDescending { it.publishedAt }
    }
}
