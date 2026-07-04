package com.example.ytdash

import android.os.Bundle
import androidx.activity.ComponentActivity
import androidx.activity.compose.setContent
import androidx.activity.enableEdgeToEdge
import androidx.compose.foundation.layout.fillMaxSize
import androidx.compose.material3.MaterialTheme
import androidx.compose.material3.Surface
import androidx.compose.ui.Modifier
import com.example.ytdash.theme.YtdashTheme
import com.example.ytdash.config.AppConfig
import com.example.ytdash.ui.MainNavigation

import androidx.compose.ui.semantics.semantics
import androidx.compose.ui.semantics.testTagsAsResourceId
import androidx.compose.ui.ExperimentalComposeUiApi

class MainActivity : ComponentActivity() {

    lateinit var appConfig: AppConfig

    @OptIn(ExperimentalComposeUiApi::class)
    override fun onCreate(savedInstanceState: Bundle?) {
        super.onCreate(savedInstanceState)
        appConfig = (application as App).appConfig
        appConfig.updateFromIntent(intent)

        enableEdgeToEdge()
        setContent {
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
