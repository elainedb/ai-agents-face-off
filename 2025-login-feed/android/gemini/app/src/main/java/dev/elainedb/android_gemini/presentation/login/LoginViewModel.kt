package dev.elainedb.android_gemini.presentation.login

import android.util.Log
import androidx.lifecycle.ViewModel
import androidx.lifecycle.viewModelScope
import dev.elainedb.android_gemini.domain.GoogleAuthRepository
import dev.elainedb.android_gemini.domain.IsEmailAuthorizedUseCase
import kotlinx.coroutines.flow.MutableStateFlow
import kotlinx.coroutines.flow.asStateFlow
import kotlinx.coroutines.launch

class LoginViewModel(
    private val isEmailAuthorizedUseCase: IsEmailAuthorizedUseCase,
    private val googleAuthRepository: GoogleAuthRepository
) : ViewModel() {

    private val _uiState = MutableStateFlow<LoginUiState>(LoginUiState.Idle)
    val uiState = _uiState.asStateFlow()

    fun onSignInSuccess(email: String?) {
        Log.d("LoginViewModel", "onSignInSuccess: email=$email")
        if (email == null) {
            _uiState.value = LoginUiState.Error("Google Sign-In failed.")
            return
        }

        viewModelScope.launch {
            val isAuthorized = isEmailAuthorizedUseCase(email)
            if (isAuthorized) {
                _uiState.value = LoginUiState.Success
            } else {
                _uiState.value = LoginUiState.Error("Access denied. Your email is not authorized.")
            }
        }
    }

    fun onSignInError() {
        _uiState.value = LoginUiState.Error("Google Sign-In failed.")
    }

    fun signOut(onSignedOut: () -> Unit) {
        Log.d("LoginViewModel", "signOut started")
        viewModelScope.launch {
            googleAuthRepository.signOut()
            _uiState.value = LoginUiState.Idle
            Log.d("LoginViewModel", "signOut completed")
            onSignedOut()
        }
    }
}

sealed class LoginUiState {
    object Idle : LoginUiState()
    object Success : LoginUiState()
    data class Error(val message: String) : LoginUiState()
}
