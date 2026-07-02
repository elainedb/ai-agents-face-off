package com.example.ytdash

import androidx.compose.animation.Crossfade
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.runtime.Composable
import androidx.compose.runtime.getValue
import androidx.compose.runtime.mutableStateOf
import androidx.compose.runtime.remember
import androidx.compose.runtime.setValue
import androidx.compose.ui.Modifier
import com.example.ytdash.ui.auth.LoginScreen
import com.example.ytdash.ui.list.ListScreen
import com.example.ytdash.ui.map.MapScreen

sealed interface Screen {
    object Login : Screen
    object Home : Screen
    object Map : Screen
}

@Composable
fun MainNavigation() {
    var currentScreen by remember { mutableStateOf<Screen>(Screen.Login) }
    var authenticatedEmail by remember { mutableStateOf<String?>(null) }

    Crossfade(targetState = currentScreen, modifier = Modifier.fillMaxSize(), label = "NavigationCrossfade") { screen ->
        when (screen) {
            Screen.Login -> {
                LoginScreen(
                    onLoginSuccess = { email ->
                        authenticatedEmail = email
                        currentScreen = Screen.Home
                    }
                )
            }
            Screen.Home -> {
                ListScreen(
                    authenticatedEmail = authenticatedEmail ?: "",
                    onNavigateToMap = {
                        currentScreen = Screen.Map
                    },
                    onLogout = {
                        authenticatedEmail = null
                        currentScreen = Screen.Login
                    }
                )
            }
            Screen.Map -> {
                MapScreen(
                    onBack = {
                        currentScreen = Screen.Home
                    }
                )
            }
        }
    }
}
