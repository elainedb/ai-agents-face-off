package dev.elainedb.ytdash_android_gemini.data.database

import dev.elainedb.ytdash_android_gemini.domain.model.Video

fun dev.elainedb.ytdash_android_gemini.data.model.YouTubeVideoItem.toVideo(): Video? {
    val videoId = id.videoId ?: return null
    val thumbUrl = snippet.thumbnails.high?.url 
        ?: snippet.thumbnails.medium?.url 
        ?: snippet.thumbnails.default?.url 
        ?: ""
        
    return Video(
        id = videoId,
        title = snippet.title,
        channelName = snippet.channelTitle,
        channelId = snippet.channelId,
        publishedAt = snippet.publishedAt,
        thumbnailUrl = thumbUrl,
        description = snippet.description
    )
}

fun Video.toEntity(timestamp: Long): VideoEntity {
    return VideoEntity(
        id = id,
        title = title,
        channelName = channelName,
        channelId = channelId,
        publishedAt = publishedAt,
        thumbnailUrl = thumbnailUrl,
        description = description,
        tags = tags.joinToString(","),
        locationCity = locationCity,
        locationCountry = locationCountry,
        locationLatitude = locationLatitude,
        locationLongitude = locationLongitude,
        recordingDate = recordingDate,
        cacheTimestamp = timestamp
    )
}

fun VideoEntity.toVideo(): Video {
    return Video(
        id = id,
        title = title,
        channelName = channelName,
        channelId = channelId,
        publishedAt = publishedAt,
        thumbnailUrl = thumbnailUrl,
        description = description,
        tags = if (tags.isBlank()) emptyList() else tags.split(","),
        locationCity = locationCity,
        locationCountry = locationCountry,
        locationLatitude = locationLatitude,
        locationLongitude = locationLongitude,
        recordingDate = recordingDate
    )
}
