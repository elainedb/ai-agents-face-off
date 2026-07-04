package com.example.ytdash

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.runtime.CompositionLocalProvider
import androidx.compose.runtime.staticCompositionLocalOf
import androidx.compose.ui.ExperimentalComposeUiApi
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.testTagsAsResourceId
import com.example.ytdash.theme.YtdashTheme

val LocalTestConfig = staticCompositionLocalOf<TestConfig> { error("No TestConfig provided") }

class MainActivity : ComponentActivity() {
  @OptIn(ExperimentalComposeUiApi::class)
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    val testConfig = TestConfig.fromIntent(intent)
    
    val app = application as YtDashApplication
    if (app.container == null) {
        app.container = com.example.ytdash.data.AppContainer(applicationContext, testConfig)
    }

    enableEdgeToEdge()
    setContent {
      CompositionLocalProvider(LocalTestConfig provides testConfig) {
        YtdashTheme {
          Surface(
            modifier = Modifier.fillMaxSize().semantics { testTagsAsResourceId = true },
            color = MaterialTheme.colorScheme.background
          ) {
            MainNavigation()
          }
        }
      }
    }
  }
}
