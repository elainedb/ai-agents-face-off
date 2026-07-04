package com.example.ytdash.data.cache

import android.content.Context
import android.content.SharedPreferences
import com.example.ytdash.domain.models.Video
import kotlinx.serialization.encodeToString
import kotlinx.serialization.json.Json

class VideoCache(context: Context) {
    private val prefs: SharedPreferences = context.getSharedPreferences("ytdash_cache", Context.MODE_PRIVATE)
    private val json = Json { ignoreUnknownKeys = true }

    fun saveVideos(videos: List<Video>) {
        val serialized = json.encodeToString(videos)
        prefs.edit().putString("videos_key", serialized).apply()
    }

    fun getVideos(): List<Video>? {
        val serialized = prefs.getString("videos_key", null) ?: return null
        return try {
            json.decodeFromString<List<Video>>(serialized)
        } catch (e: Exception) {
            null
        }
    }
    
    fun clear() {
        prefs.edit().remove("videos_key").apply()
    }
}
