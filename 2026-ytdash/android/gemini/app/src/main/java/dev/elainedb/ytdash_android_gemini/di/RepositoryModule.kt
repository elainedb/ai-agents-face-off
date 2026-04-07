package dev.elainedb.ytdash_android_gemini.di

import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import dev.elainedb.ytdash_android_gemini.data.repository.YouTubeRepositoryImpl
import dev.elainedb.ytdash_android_gemini.domain.repository.YouTubeRepository
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class RepositoryModule {

    @Binds
    @Singleton
    abstract fun bindYouTubeRepository(
        youTubeRepositoryImpl: YouTubeRepositoryImpl
    ): YouTubeRepository
}
