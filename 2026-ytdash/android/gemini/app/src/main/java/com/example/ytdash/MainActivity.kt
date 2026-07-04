package com.example.ytdash

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.testTagsAsResourceId
import com.example.ytdash.theme.YtdashTheme

class MainActivity : ComponentActivity() {
  
  lateinit var testConfig: TestConfig
      private set
      
  override fun onCreate(savedInstanceState: Bundle?) {
    super.onCreate(savedInstanceState)
    
    testConfig = TestConfig.fromIntent(intent)
    val appContainer = (application as MyApplication).appContainer
    appContainer.initializeNetwork(testConfig)

    enableEdgeToEdge()
    setContent {
      YtdashTheme { 
        Surface(
          modifier = Modifier.fillMaxSize().semantics { testTagsAsResourceId = true }, 
          color = MaterialTheme.colorScheme.background
        ) { 
          MainNavigation(appContainer, testConfig) 
        } 
      }
    }
  }
}
