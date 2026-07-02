package com.example.ytdash.data.repository

import android.content.Context
import com.example.ytdash.data.model.Video
import com.example.ytdash.data.network.YouTubeApiService
import com.google.gson.Gson
import com.google.gson.reflect.TypeToken
import kotlinx.coroutines.Dispatchers
import kotlinx.coroutines.withContext
import java.io.IOException

class VideoRepository(
    private val context: Context,
    private val apiService: YouTubeApiService
) {
    private val sharedPrefs = context.getSharedPreferences("ytdash_cache", Context.MODE_PRIVATE)
    private val gson = Gson()
    private val cacheKey = "cached_videos"

    /**
     * Fetch videos from network, update cache on success.
     * On failure (network error), returns cached videos if available (stale-fallback).
     * If no cache exists, throws the original exception so the UI can show an error view.
     */
    @Throws(Exception::class)
    suspend fun getVideos(forceRefresh: Boolean = false): List<Video> = withContext(Dispatchers.IO) {
        val channels = apiService.loadChannelsFromConfig()
        
        if (forceRefresh) {
            try {
                val videos = apiService.fetchAllVideos(channels)
                saveToCache(videos)
                videos
            } catch (e: IOException) {
                // Network error fallback
                val cached = getFromCache()
                if (cached.isNotEmpty()) {
                    cached
                } else {
                    throw e
                }
            }
        } else {
            // First check if we have cached videos, if empty fetch from network
            val cached = getFromCache()
            if (cached.isNotEmpty()) {
                cached
            } else {
                val videos = apiService.fetchAllVideos(channels)
                saveToCache(videos)
                videos
            }
        }
    }

    fun getFromCache(): List<Video> {
        val json = sharedPrefs.getString(cacheKey, null) ?: return emptyList()
        return try {
            val type = object : TypeToken<List<Video>>() {}.type
            gson.fromJson(json, type)
        } catch (e: Exception) {
            emptyList()
        }
    }

    private fun saveToCache(videos: List<Video>) {
        val json = gson.toJson(videos)
        sharedPrefs.edit().putString(cacheKey, json).apply()
    }

    fun clearCache() {
        sharedPrefs.edit().remove(cacheKey).apply()
    }
}
