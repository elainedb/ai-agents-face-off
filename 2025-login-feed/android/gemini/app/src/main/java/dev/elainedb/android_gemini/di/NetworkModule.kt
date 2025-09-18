package dev.elainedb.android_gemini.di

import android.content.Context
import com.jakewharton.retrofit2.converter.kotlinx.serialization.asConverterFactory
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import dev.elainedb.android_gemini.R
import dev.elainedb.android_gemini.data.youtube.YoutubeApiService
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import java.util.Properties
import javax.inject.Named
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient {
        val logging = HttpLoggingInterceptor()
        logging.setLevel(HttpLoggingInterceptor.Level.BODY)
        return OkHttpClient.Builder()
            .addInterceptor(logging)
            .build()
    }

    @Provides
    @Singleton
    fun provideRetrofit(okHttpClient: OkHttpClient): Retrofit {
        val json = Json { ignoreUnknownKeys = true }
        return Retrofit.Builder()
            .baseUrl("https://www.googleapis.com/")
            .client(okHttpClient)
            .addConverterFactory(json.asConverterFactory("application/json".toMediaType()))
            .build()
    }

    @Provides
    @Singleton
    fun provideYoutubeApiService(retrofit: Retrofit): YoutubeApiService {
        return retrofit.create(YoutubeApiService::class.java)
    }

    @Provides
    @Singleton
    @Named("youtubeApiKey")
    fun provideYoutubeApiKey(@ApplicationContext context: Context): String {
        val properties = Properties()
        val rawResource = context.resources.openRawResource(R.raw.config)
        properties.load(rawResource)
        return properties.getProperty("youtubeApiKey")
    }
}
