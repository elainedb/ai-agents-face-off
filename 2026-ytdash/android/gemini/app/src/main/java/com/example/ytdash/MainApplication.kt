package com.example.ytdash

import android.app.Application
import com.example.ytdash.data.model.TestConfig
import com.example.ytdash.data.network.YouTubeApiService
import com.example.ytdash.data.repository.AuthRepository
import com.example.ytdash.data.repository.VideoRepository
import org.osmdroid.config.Configuration

class MainApplication : Application() {
    
    lateinit var testConfig: TestConfig
    lateinit var apiService: YouTubeApiService
    lateinit var authRepository: AuthRepository
    lateinit var videoRepository: VideoRepository

    override fun onCreate() {
        super.onCreate()
        // Initialize osmdroid configuration
        Configuration.getInstance().userAgentValue = packageName
        
        // Setup initial default dependencies (can be overridden when MainActivity starts with actual test extras)
        initializeDependencies(TestConfig())
    }

    fun initializeDependencies(config: TestConfig) {
        testConfig = config
        apiService = YouTubeApiService(this, testConfig)
        authRepository = AuthRepository(this, testConfig)
        videoRepository = VideoRepository(this, apiService)
    }
}
