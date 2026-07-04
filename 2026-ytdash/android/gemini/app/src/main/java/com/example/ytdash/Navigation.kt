package com.example.ytdash

import androidx.compose.runtime.Composable
import androidx.compose.ui.Modifier
import androidx.compose.ui.platform.LocalContext
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation3.runtime.entryProvider
import androidx.navigation3.runtime.rememberNavBackStack
import androidx.navigation3.ui.NavDisplay
import com.example.ytdash.ui.home.HomeScreen
import com.example.ytdash.ui.home.HomeViewModel
import com.example.ytdash.ui.home.HomeViewModelFactory
import com.example.ytdash.ui.login.LoginScreen
import com.example.ytdash.ui.login.LoginViewModel
import com.example.ytdash.ui.login.LoginViewModelFactory
import com.example.ytdash.ui.map.MapScreen

@Composable
fun MainNavigation() {
    val backStack = rememberNavBackStack(Login)
    val context = LocalContext.current
    val app = context.applicationContext as YtDashApplication
    val container = app.container!!

    val testConfig = LocalTestConfig.current

    val loginViewModel: LoginViewModel = viewModel(factory = LoginViewModelFactory(testConfig))
    val homeViewModel: HomeViewModel = viewModel(factory = HomeViewModelFactory(container.repository))

    NavDisplay(
        backStack = backStack,
        onBack = { backStack.removeLastOrNull() },
        entryProvider = entryProvider {
            entry<Login> {
                LoginScreen(
                    onNavigateToHome = {
                        backStack.clear()
                        backStack.add(Home)
                    },
                    viewModel = loginViewModel
                )
            }
            entry<Home> {
                HomeScreen(
                    onNavigateToMap = { backStack.add(Map) },
                    onLogout = {
                        backStack.clear()
                        backStack.add(Login)
                    },
                    viewModel = homeViewModel,
                    loginViewModel = loginViewModel
                )
            }
            entry<Map> {
                MapScreen(
                    onNavigateBack = { backStack.removeLast() },
                    viewModel = homeViewModel
                )
            }
        }
    )
}
