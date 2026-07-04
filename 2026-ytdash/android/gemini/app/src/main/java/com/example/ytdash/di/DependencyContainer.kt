package com.example.ytdash.di

import android.content.Context
import androidx.room.Room
import com.example.ytdash.config.AppConfig
import com.example.ytdash.data.local.AppDatabase
import com.example.ytdash.data.network.YoutubeApi
import com.example.ytdash.data.repository.VideoRepository
import com.jakewharton.retrofit2.converter.kotlinx.serialization.asConverterFactory
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import retrofit2.Retrofit

class DependencyContainer(private val context: Context, val appConfig: AppConfig) {
    
    val database: AppDatabase by lazy {
        Room.databaseBuilder(context, AppDatabase::class.java, "ytdash.db").build()
    }

    private val json = Json { ignoreUnknownKeys = true }

    val youtubeApi: YoutubeApi by lazy {
        val baseUrl = appConfig.apiBaseUrl ?: "https://www.googleapis.com/youtube/v3/"
        val retrofit = Retrofit.Builder()
            .baseUrl(baseUrl)
            .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
            .build()
        retrofit.create(YoutubeApi::class.java)
    }

    val channels: List<com.example.ytdash.config.ChannelConfig> by lazy {
        val jsonStr = context.assets.open("channels.json").bufferedReader().use { it.readText() }
        json.decodeFromString(jsonStr)
    }

    val videoRepository: VideoRepository by lazy {
        VideoRepository(youtubeApi, database.videoDao(), appConfig, channels)
    }
}
