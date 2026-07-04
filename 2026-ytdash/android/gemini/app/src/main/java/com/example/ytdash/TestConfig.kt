package com.example.ytdash

import android.content.Intent

data class TestConfig(
    val uiTestMode: Boolean,
    val mockAuthEmail: String?,
    val apiBaseUrl: String?,
    val apiKey: String?,
    val authorizedEmails: String?,
    val captureExternalLinks: Boolean
) {
    companion object {
        fun fromIntent(intent: Intent?): TestConfig {
            val extras = intent?.extras
            val uiTestMode = extras?.get("uiTestMode")?.toString()?.toBoolean() ?: false
            val captureExternalLinks = extras?.get("captureExternalLinks")?.toString()?.toBoolean() ?: false
            
            return TestConfig(
                uiTestMode = uiTestMode,
                mockAuthEmail = extras?.getString("mockAuthEmail"),
                apiBaseUrl = extras?.getString("apiBaseUrl"),
                apiKey = extras?.getString("apiKey"),
                authorizedEmails = extras?.getString("authorizedEmails"),
                captureExternalLinks = captureExternalLinks
            )
        }
    }
}
