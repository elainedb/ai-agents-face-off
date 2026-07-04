package com.example.ytdash

import android.app.Application
import com.example.ytdash.config.AppConfig
import com.example.ytdash.di.DependencyContainer

class App : Application() {
    val appConfig = AppConfig()
    lateinit var container: DependencyContainer

    override fun onCreate() {
        super.onCreate()
        container = DependencyContainer(this, appConfig)
    }
}
