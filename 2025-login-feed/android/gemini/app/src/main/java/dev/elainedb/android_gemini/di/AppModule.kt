package dev.elainedb.android_gemini.di

import dagger.Binds
import dagger.Module
import dagger.hilt.InstallIn
import dagger.hilt.components.SingletonComponent
import dev.elainedb.android_gemini.data.AuthorizedEmailsRepositoryImpl
import dev.elainedb.android_gemini.data.GoogleAuthRepositoryImpl
import dev.elainedb.android_gemini.data.youtube.YoutubeRepositoryImpl
import dev.elainedb.android_gemini.domain.AuthorizedEmailsRepository
import dev.elainedb.android_gemini.domain.GoogleAuthRepository
import dev.elainedb.android_gemini.domain.youtube.YoutubeRepository
import javax.inject.Singleton

@Module
@InstallIn(SingletonComponent::class)
abstract class AppModule {

    @Binds
    @Singleton
    abstract fun bindAuthorizedEmailsRepository(
        authorizedEmailsRepositoryImpl: AuthorizedEmailsRepositoryImpl
    ): AuthorizedEmailsRepository

    @Binds
    @Singleton
    abstract fun bindGoogleAuthRepository(
        googleAuthRepositoryImpl: GoogleAuthRepositoryImpl
    ): GoogleAuthRepository

    @Binds
    @Singleton
    abstract fun bindYoutubeRepository(
        youtubeRepositoryImpl: YoutubeRepositoryImpl
    ): YoutubeRepository
}
