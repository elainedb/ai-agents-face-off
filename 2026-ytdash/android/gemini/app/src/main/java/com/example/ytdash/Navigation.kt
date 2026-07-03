package com.example.ytdash

import androidx.compose.runtime.*
import androidx.compose.ui.Modifier
import com.example.ytdash.ui.login.LoginScreen
import com.example.ytdash.ui.main.MainScreen

@Composable
fun MainNavigation() {
    var isAuthenticated by remember { mutableStateOf(AuthManager.isAuthenticated()) }

    if (!isAuthenticated) {
        LoginScreen(
            onLoginSuccess = { isAuthenticated = true }
        )
    } else {
        MainScreen(
            onLogout = { isAuthenticated = false }
        )
    }
}
