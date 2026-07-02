package com.example.ytdash.data.model

import android.content.Intent

data class TestConfig(
    val uiTestMode: Boolean = false,
    val mockAuthEmail: String? = null,
    val apiBaseUrl: String? = null,
    val apiKey: String? = null,
    val authorizedEmails: List<String>? = null,
    val captureExternalLinks: Boolean = false
) {
    companion object {
        fun fromIntent(intent: Intent?): TestConfig {
            if (intent == null) return TestConfig()
            val extras = intent.extras ?: return TestConfig()
            
            val uiTestModeRaw = extras.get("uiTestMode")
            val uiTestMode = when (uiTestModeRaw) {
                is Boolean -> uiTestModeRaw
                is String -> uiTestModeRaw.toBoolean()
                else -> false
            }
            if (!uiTestMode) return TestConfig()
            
            val mockAuthEmail = extras.getString("mockAuthEmail")
            val apiBaseUrl = extras.getString("apiBaseUrl")
            val apiKey = extras.getString("apiKey")
            val authorizedEmailsStr = extras.getString("authorizedEmails")
            val authorizedEmails = authorizedEmailsStr?.split(",")?.map { it.trim() }?.filter { it.isNotEmpty() }
            
            val captureExternalLinksRaw = extras.get("captureExternalLinks")
            val captureExternalLinks = when (captureExternalLinksRaw) {
                is Boolean -> captureExternalLinksRaw
                is String -> captureExternalLinksRaw.toBoolean()
                else -> false
            }
            
            return TestConfig(
                uiTestMode = true,
                mockAuthEmail = mockAuthEmail,
                apiBaseUrl = apiBaseUrl,
                apiKey = apiKey,
                authorizedEmails = authorizedEmails,
                captureExternalLinks = captureExternalLinks
            )
        }
    }
}
