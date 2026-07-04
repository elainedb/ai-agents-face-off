package com.example.ytdash.ui.login

import androidx.compose.foundation.layout.Box
import androidx.compose.foundation.layout.Column
import androidx.compose.foundation.layout.Spacer
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.foundation.layout.height
import androidx.compose.material3.Button
import androidx.compose.material3.Text
import androidx.compose.runtime.Composable
import androidx.compose.runtime.LaunchedEffect
import androidx.compose.runtime.collectAsState
import androidx.compose.ui.Alignment
import androidx.compose.ui.Modifier
import androidx.compose.ui.graphics.Color
import androidx.compose.ui.platform.testTag
import androidx.compose.ui.unit.dp

@Composable
fun LoginScreen(
    viewModel: LoginViewModel,
    onLoginSuccess: () -> Unit
) {
    val uiState = viewModel.uiState.collectAsState().value
    
    LaunchedEffect(uiState.isLoggedIn) {
        if (uiState.isLoggedIn) {
            onLoginSuccess()
        }
    }

    Box(
        modifier = Modifier
            .fillMaxSize()
            .testTag("screen_login"),
        contentAlignment = Alignment.Center
    ) {
        Column(horizontalAlignment = Alignment.CenterHorizontally) {
            Button(
                onClick = {
                    val config = viewModel.getConfig()
                    if (config.isUiTestMode) {
                        viewModel.onGoogleSignInResult(config.mockAuthEmail ?: "test@example.com")
                    } else {
                        // Real Google Sign in here later
                        viewModel.onGoogleSignInResult("test@example.com")
                    }
                },
                modifier = Modifier.testTag("login_google_button")
            ) {
                Text("Sign in with Google")
            }
            
            if (uiState.errorMessage != null) {
                Spacer(modifier = Modifier.height(16.dp))
                Text(
                    text = uiState.errorMessage,
                    color = Color.Red,
                    modifier = Modifier.testTag("login_error_message")
                )
            }
        }
    }
}
