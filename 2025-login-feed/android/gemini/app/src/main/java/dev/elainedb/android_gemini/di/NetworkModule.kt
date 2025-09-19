package dev.elainedb.android_gemini.di

import android.content.Context
import com.jakewharton.retrofit2.converter.kotlinx.serialization.asConverterFactory
import dev.elainedb.android_gemini.R
import dev.elainedb.android_gemini.data.youtube.YoutubeApiService
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import org.koin.android.ext.koin.androidContext
import org.koin.core.qualifier.named
import org.koin.dsl.module
import retrofit2.Retrofit
import java.util.Properties

val networkModule = module {

    single {
        val logging = HttpLoggingInterceptor()
        logging.setLevel(HttpLoggingInterceptor.Level.BODY)
        OkHttpClient.Builder()
            .addInterceptor(logging)
            .build()
    }

    single {
        val json = Json { ignoreUnknownKeys = true }
        Retrofit.Builder()
            .baseUrl("https://www.googleapis.com/")
            .client(get())
            .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
            .build()
    }

    single {
        get<Retrofit>().create(YoutubeApiService::class.java)
    }

    single(named("youtubeApiKey")) {
        val properties = Properties()
        val rawResource = androidContext().resources.openRawResource(R.raw.config)
        properties.load(rawResource)
        properties.getProperty("youtubeApiKey")
    }
}