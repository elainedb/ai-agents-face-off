package dev.elainedb.ytdash_android_gemini.di

import android.content.Context
import androidx.room.Room
import retrofit2.converter.kotlinx.serialization.asConverterFactory
import dagger.Module
import dagger.Provides
import dagger.hilt.InstallIn
import dagger.hilt.android.qualifiers.ApplicationContext
import dagger.hilt.components.SingletonComponent
import dev.elainedb.ytdash_android_gemini.data.database.VideoDao
import dev.elainedb.ytdash_android_gemini.data.database.VideoDatabase
import dev.elainedb.ytdash_android_gemini.data.network.YouTubeApiService
import kotlinx.serialization.json.Json
import okhttp3.MediaType.Companion.toMediaType
import okhttp3.OkHttpClient
import okhttp3.logging.HttpLoggingInterceptor
import retrofit2.Retrofit
import java.util.concurrent.TimeUnit
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
object NetworkModule {

    @Provides
    @Singleton
    fun provideJson(): Json {
        return Json {
            ignoreUnknownKeys = true
            coerceInputValues = true
        }
    }

    @Provides
    @Singleton
    fun provideOkHttpClient(): OkHttpClient {
        val logging = HttpLoggingInterceptor().apply {
            level = HttpLoggingInterceptor.Level.BODY
        }
        return OkHttpClient.Builder()
            .addInterceptor(logging)
            // Add other interceptors if needed (e.g. X-Android-Package)
            .connectTimeout(30, TimeUnit.SECONDS)
            .readTimeout(30, TimeUnit.SECONDS)
            .build()
    }

    @Provides
    @Singleton
    fun provideRetrofit(okHttpClient: OkHttpClient, json: Json): Retrofit {
        val contentType = "application/json".toMediaType()
        @Suppress("DEPRECATION") // we actually use the native one in newer retrofit but fallback to this for now if ok
        // wait, I need to use the official one. Let's fix this in a moment via replace.
        // I will use retrofit2.converter.kotlinx.serialization.asConverterFactory
        return Retrofit.Builder()
            .baseUrl("https://www.googleapis.com/youtube/v3/")
            .client(okHttpClient)
            .addConverterFactory(json.asConverterFactory(contentType))
            .build()
    }

    @Provides
    @Singleton
    fun provideYouTubeApiService(retrofit: Retrofit): YouTubeApiService {
        return retrofit.create(YouTubeApiService::class.java)
    }
}

@Module
@InstallIn(SingletonComponent::class)
object DatabaseModule {

    @Provides
    @Singleton
    fun provideVideoDatabase(@ApplicationContext context: Context): VideoDatabase {
        return Room.databaseBuilder(
            context,
            VideoDatabase::class.java,
            "video_database"
        ).fallbackToDestructiveMigration().build()
    }

    @Provides
    fun provideVideoDao(database: VideoDatabase): VideoDao {
        return database.videoDao()
    }
}

@Module
@InstallIn(SingletonComponent::class)
object RepositoryModule {

    @Provides
    @Singleton
    fun provideYouTubeRepository(
        apiService: YouTubeApiService,
        videoDao: VideoDao,
        @ApplicationContext context: Context
    ): dev.elainedb.ytdash_android_gemini.domain.repository.YouTubeRepository {
        return dev.elainedb.ytdash_android_gemini.data.repository.YouTubeRepositoryImpl(apiService, videoDao, context)
    }
}
