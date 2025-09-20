package dev.elainedb.android_gemini

import android.app.Application
import androidx.preference.PreferenceManager
import dev.elainedb.android_gemini.di.appModule
import dev.elainedb.android_gemini.di.databaseModule
import dev.elainedb.android_gemini.di.networkModule
import org.koin.android.ext.koin.androidContext
import org.koin.android.ext.koin.androidLogger
import org.koin.core.context.startKoin
import org.osmdroid.config.Configuration
import org.osmdroid.library.BuildConfig

class GeminiApplication : Application() {
    override fun onCreate() {
        super.onCreate()
        Configuration.getInstance().load(this, PreferenceManager.getDefaultSharedPreferences(this))
        Configuration.getInstance().userAgentValue = BuildConfig.APPLICATION_ID
        startKoin {
            androidLogger()
            androidContext(this@GeminiApplication)
            modules(appModule, networkModule, databaseModule)
        }
    }
}
