package dev.elainedb.android_gemini.di

import dev.elainedb.android_gemini.data.AuthorizedEmailsRepositoryImpl
import dev.elainedb.android_gemini.data.GoogleAuthRepositoryImpl
import dev.elainedb.android_gemini.data.youtube.YoutubeRepositoryImpl
import dev.elainedb.android_gemini.domain.AuthorizedEmailsRepository
import dev.elainedb.android_gemini.domain.GoogleAuthRepository
import dev.elainedb.android_gemini.domain.IsEmailAuthorizedUseCase
import dev.elainedb.android_gemini.domain.youtube.GetYoutubeVideosUseCase
import dev.elainedb.android_gemini.domain.youtube.YoutubeRepository
import dev.elainedb.android_gemini.presentation.login.LoginViewModel
import dev.elainedb.android_gemini.presentation.main.MainViewModel
import org.koin.android.ext.koin.androidContext
import org.koin.androidx.viewmodel.dsl.viewModel
import org.koin.core.qualifier.named
import org.koin.dsl.module

val appModule = module {
    single<AuthorizedEmailsRepository> { AuthorizedEmailsRepositoryImpl(androidContext()) }
    single<GoogleAuthRepository> { GoogleAuthRepositoryImpl(androidContext()) }
    single<YoutubeRepository> { YoutubeRepositoryImpl(get(), get(named("youtubeApiKey")), get(), androidContext()) }
    single { IsEmailAuthorizedUseCase(get()) }
    single { GetYoutubeVideosUseCase(get()) }

    viewModel { LoginViewModel(get(), get()) }
    viewModel { MainViewModel(get()) }
}
