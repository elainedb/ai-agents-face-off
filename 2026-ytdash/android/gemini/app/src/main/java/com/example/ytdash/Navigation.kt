package com.example.ytdash

import androidx.compose.foundation.layout.padding
import androidx.compose.foundation.layout.safeDrawingPadding
import androidx.compose.runtime.Composable
import androidx.compose.runtime.collectAsState
import androidx.compose.runtime.getValue
import androidx.compose.ui.Modifier
import androidx.compose.ui.unit.dp
import androidx.lifecycle.viewmodel.compose.viewModel
import androidx.navigation3.runtime.entryProvider
import androidx.navigation3.runtime.rememberNavBackStack
import androidx.navigation3.ui.NavDisplay
import com.example.ytdash.ui.login.LoginScreen
import com.example.ytdash.ui.login.LoginViewModel
import com.example.ytdash.ui.home.HomeScreen
import com.example.ytdash.ui.home.HomeViewModel
import com.example.ytdash.ui.map.MapScreen

@Composable
fun MainNavigation(appContainer: AppContainer, testConfig: TestConfig) {
  val backStack = rememberNavBackStack(Login)

  NavDisplay(
    backStack = backStack,
    onBack = { backStack.removeLastOrNull() },
    entryProvider =
      entryProvider {
        entry<Login> {
          val viewModel: LoginViewModel = viewModel(factory = LoginViewModel.provideFactory(appContainer.authRepository, testConfig))
          LoginScreen(
            viewModel = viewModel,
            onLoginSuccess = {
                backStack.clear()
                backStack.add(Home)
            }
          )
        }
        entry<Home> {
          val viewModel: HomeViewModel = viewModel(factory = HomeViewModel.provideFactory(appContainer.videoRepository!!, appContainer.authRepository))
          HomeScreen(
            viewModel = viewModel,
            testConfig = testConfig,
            onNavigateToMap = { backStack.add(MapScreenKey) },
            onLogout = {
                appContainer.authRepository.signOut()
                backStack.clear()
                backStack.add(Login)
            }
          )
        }
        entry<MapScreenKey> {
          val viewModel: HomeViewModel = viewModel(factory = HomeViewModel.provideFactory(appContainer.videoRepository!!, appContainer.authRepository))
          val videos by viewModel.videos.collectAsState()
          MapScreen(
            videos = videos,
            testConfig = testConfig,
            onBack = { backStack.removeLastOrNull() }
          )
        }
      },
  )
}
