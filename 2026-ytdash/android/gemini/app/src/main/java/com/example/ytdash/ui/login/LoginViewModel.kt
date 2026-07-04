package com.example.ytdash.ui.login

import androidx.lifecycle.ViewModel
import com.example.ytdash.config.AppConfig
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow

class LoginViewModel(private val appConfig: AppConfig) : ViewModel() {

    private val _uiState = MutableStateFlow(LoginUiState())
    val uiState: StateFlow<LoginUiState> = _uiState

    init {
        // Do not auto-login. The mockAuthEmail is used when the user taps the login button.
    }
    
    fun getConfig(): AppConfig = appConfig

    fun onGoogleSignInResult(email: String) {
        val authorized = appConfig.authorizedEmails?.split(",")?.map { it.trim() } ?: emptyList()
        if (authorized.isNotEmpty() && !authorized.contains(email)) {
            _uiState.value = LoginUiState(isLoggedIn = false, errorMessage = "Unauthorized email")
        } else {
            _uiState.value = LoginUiState(isLoggedIn = true, userEmail = email)
        }
    }
}

data class LoginUiState(
    val isLoggedIn: Boolean = false,
    val userEmail: String? = null,
    val errorMessage: String? = null
)
