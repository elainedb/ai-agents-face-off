package com.example.ytdash.ui.login

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.ytdash.TestConfig
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

sealed interface LoginUiState {
    data object Idle : LoginUiState
    data object Loading : LoginUiState
    data class Error(val message: String) : LoginUiState
    data object Success : LoginUiState
}

class LoginViewModel(private val testConfig: TestConfig) : ViewModel() {

    private val _uiState = MutableStateFlow<LoginUiState>(LoginUiState.Idle)
    val uiState: StateFlow<LoginUiState> = _uiState.asStateFlow()

    private val defaultWhitelist = listOf("user1@example.com", "user2@example.com")

    fun onSignIn(email: String) {
        viewModelScope.launch {
            _uiState.value = LoginUiState.Loading

            val whitelist = if (!testConfig.authorizedEmails.isNullOrEmpty()) {
                testConfig.authorizedEmails.split(",").map { it.trim() }
            } else {
                defaultWhitelist
            }

            if (whitelist.contains(email)) {
                _uiState.value = LoginUiState.Success
            } else {
                _uiState.value = LoginUiState.Error("Email not authorized")
            }
        }
    }

    fun getMockAuthEmail(): String? = testConfig.mockAuthEmail
    fun isUiTestMode(): Boolean = testConfig.uiTestMode

    fun onSignOut() {
        _uiState.value = LoginUiState.Idle
    }
}

class LoginViewModelFactory(private val testConfig: TestConfig) : ViewModelProvider.Factory {
    @Suppress("UNCHECKED_CAST")
    override fun <T : ViewModel> create(modelClass: Class<T>): T {
        return LoginViewModel(testConfig) as T
    }
}
