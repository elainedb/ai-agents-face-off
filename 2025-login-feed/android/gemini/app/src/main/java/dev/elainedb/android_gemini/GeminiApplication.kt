package dev.elainedb.android_gemini

import android.app.Application
import dev.elainedb.android_gemini.di.appModule
import dev.elainedb.android_gemini.di.databaseModule
import dev.elainedb.android_gemini.di.networkModule
import org.koin.android.ext.koin.androidContext
import org.koin.android.ext.koin.androidLogger
import org.koin.core.context.startKoin

class GeminiApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        startKoin {
            androidLogger()
            androidContext(this@GeminiApplication)
            modules(appModule, networkModule, databaseModule)
        }
    }
}
