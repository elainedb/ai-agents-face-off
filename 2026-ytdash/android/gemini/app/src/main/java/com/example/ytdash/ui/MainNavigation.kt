package com.example.ytdash.ui

import androidx.compose.runtime.Composable
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import com.example.ytdash.App
import com.example.ytdash.di.AppViewModelFactory
import com.example.ytdash.ui.login.LoginScreen
import com.example.ytdash.ui.login.LoginViewModel
import com.example.ytdash.ui.home.HomeScreen

@Composable
fun MainNavigation() {
    val navController = rememberNavController()
    val app = LocalContext.current.applicationContext as App
    val factory = AppViewModelFactory(app.container)
    
    NavHost(navController = navController, startDestination = "login") {
        composable("login") {
            val viewModel: LoginViewModel = viewModel(factory = factory)
            LoginScreen(viewModel = viewModel, onLoginSuccess = {
                navController.navigate("home") {
                    popUpTo("login") { inclusive = true }
                }
            })
        }
        composable("home") {
            val viewModel: com.example.ytdash.ui.home.HomeViewModel = viewModel(factory = factory)
            HomeScreen(
                viewModel = viewModel,
                onLogout = {
                    navController.navigate("login") {
                        popUpTo("home") { inclusive = true }
                    }
                },
                onNavigateToMap = {
                    navController.navigate("map")
                }
            )
        }
        composable("map") {
            val viewModel: com.example.ytdash.ui.home.HomeViewModel = viewModel(factory = factory)
            com.example.ytdash.ui.home.MapScreen(
                viewModel = viewModel,
                onBack = { navController.popBackStack() }
            )
        }
    }
}
