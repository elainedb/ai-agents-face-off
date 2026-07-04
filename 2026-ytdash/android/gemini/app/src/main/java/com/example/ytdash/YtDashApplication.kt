package com.example.ytdash

import android.app.Application
import com.example.ytdash.data.AppContainer

class YtDashApplication : Application() {
    var container: AppContainer? = null

    // We will initialize it in MainActivity because we need intent.extras for TestConfig
}
