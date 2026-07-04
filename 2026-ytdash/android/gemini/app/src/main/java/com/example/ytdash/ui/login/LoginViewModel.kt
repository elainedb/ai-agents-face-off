package com.example.ytdash.ui.login

import androidx.lifecycle.ViewModel
import androidx.lifecycle.ViewModelProvider
import androidx.lifecycle.viewModelScope
import com.example.ytdash.TestConfig
import com.example.ytdash.data.repository.AuthRepository
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.StateFlow
import kotlinx.coroutines.launch

sealed class LoginUiState {
    data object Idle : LoginUiState()
    data object Loading : LoginUiState()
    data object Success : LoginUiState()
    data class Error(val message: String) : LoginUiState()
}

class LoginViewModel(
    private val authRepository: AuthRepository,
    private val testConfig: TestConfig
) : ViewModel() {

    private val _uiState = MutableStateFlow<LoginUiState>(LoginUiState.Idle)
    val uiState: StateFlow<LoginUiState> = _uiState

    val isMockMode: Boolean
        get() = testConfig.uiTestMode && testConfig.mockAuthEmail != null

    fun loginMock() {
        _uiState.value = LoginUiState.Loading
        viewModelScope.launch {
            val result = authRepository.signInMock(testConfig)
            if (result.isSuccess) {
                _uiState.value = LoginUiState.Success
            } else {
                _uiState.value = LoginUiState.Error(result.exceptionOrNull()?.message ?: "Unknown error")
            }
        }
    }

    fun loginReal(email: String) {
        _uiState.value = LoginUiState.Loading
        viewModelScope.launch {
            val result = authRepository.signInReal(email, testConfig)
            if (result.isSuccess) {
                _uiState.value = LoginUiState.Success
            } else {
                _uiState.value = LoginUiState.Error(result.exceptionOrNull()?.message ?: "Unknown error")
            }
        }
    }

    companion object {
        fun provideFactory(
            authRepository: AuthRepository,
            testConfig: TestConfig
        ): ViewModelProvider.Factory = object : ViewModelProvider.Factory {
            @Suppress("UNCHECKED_CAST")
            override fun <T : ViewModel> create(modelClass: Class<T>): T {
                return LoginViewModel(authRepository, testConfig) as T
            }
        }
    }
}
