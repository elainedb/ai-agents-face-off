package dev.elainedb.android_gemini

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.runtime.Composable
import androidx.navigation.compose.NavHost
import androidx.navigation.compose.composable
import androidx.navigation.compose.rememberNavController
import dev.elainedb.android_gemini.presentation.login.LoginScreen
import dev.elainedb.android_gemini.presentation.login.LoginViewModel
import dev.elainedb.android_gemini.presentation.main.MainScreen
import dev.elainedb.android_gemini.ui.theme.AndroidGeminiTheme
import org.koin.androidx.compose.koinViewModel

class MainActivity : ComponentActivity() {
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        enableEdgeToEdge()
        setContent {
            AndroidGeminiTheme {
                AppNavigation()
            }
        }
    }
}

@Composable
fun AppNavigation() {
    val navController = rememberNavController()
    val loginViewModel: LoginViewModel = koinViewModel()

    NavHost(navController = navController, startDestination = "login") {
        composable("login") {
            LoginScreen(onLoginSuccess = {
                navController.navigate("home") {
                    popUpTo("login") {
                        inclusive = true
                    }
                }
            })
        }
        composable("home") {
            MainScreen(
                onLogout = {
                    loginViewModel.signOut {
                        navController.navigate("login") {
                            popUpTo("home") {
                                inclusive = true
                            }
                        }
                    }
                },
                onNavigateToMap = {
                    navController.navigate("map")
                }
            )
        }
        composable("map") {
            dev.elainedb.android_gemini.presentation.map.MapScreen(
                onBack = {
                    navController.popBackStack()
                }
            )
        }
    }
}

