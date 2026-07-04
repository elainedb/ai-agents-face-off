package com.example.ytdash

import android.content.Context
import com.example.ytdash.data.api.YouTubeApi
import com.example.ytdash.data.cache.VideoCache
import com.example.ytdash.data.repository.AuthRepository
import com.example.ytdash.data.repository.ConfigRepository
import com.example.ytdash.data.repository.VideoRepository
import com.example.ytdash.domain.auth.WhitelistManager
import com.jakewharton.retrofit2.converter.kotlinx.serialization.asConverterFactory
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import retrofit2.Retrofit

class AppContainer(private val applicationContext: Context) {

    private val json = Json { ignoreUnknownKeys = true }
    
    val configRepository by lazy { ConfigRepository(applicationContext) }
    val whitelistManager by lazy { WhitelistManager() }
    val authRepository by lazy { AuthRepository(applicationContext, whitelistManager) }
    val videoCache by lazy { VideoCache(applicationContext) }

    var videoRepository: VideoRepository? = null
        private set

    fun initializeNetwork(testConfig: TestConfig) {
        val baseUrl = testConfig.apiBaseUrl ?: "https://www.googleapis.com"
        val apiKey = testConfig.apiKey ?: BuildConfig.YOUTUBE_API_KEY
        
        val retrofit = Retrofit.Builder()
            .baseUrl(if (baseUrl.endsWith("/")) baseUrl else baseUrl + "/")
            .client(OkHttpClient.Builder().build())
            .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
            .build()
            
        val api = retrofit.create(YouTubeApi::class.java)
        
        videoRepository = VideoRepository(
            api = api,
            cache = videoCache,
            configRepository = configRepository,
            apiKey = apiKey
        )
    }
}
