package com.example.ytdash.di

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import com.example.ytdash.ui.login.LoginViewModel

class AppViewModelFactory(private val container: DependencyContainer) : ViewModelProvider.Factory {
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        if (modelClass.isAssignableFrom(LoginViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return LoginViewModel(container.appConfig) as T
        }
        if (modelClass.isAssignableFrom(com.example.ytdash.ui.home.HomeViewModel::class.java)) {
            @Suppress("UNCHECKED_CAST")
            return com.example.ytdash.ui.home.HomeViewModel(container.videoRepository) as T
        }
        throw IllegalArgumentException("Unknown ViewModel class")
    }
}
