package com.example.ytdash.config

import android.content.Intent

class AppConfig {
    var isUiTestMode: Boolean = false
    var mockAuthEmail: String? = null
    var apiBaseUrl: String? = null
    var apiKey: String? = null
    var authorizedEmails: String? = null
    var captureExternalLinks: Boolean = false

    fun updateFromIntent(intent: Intent?) {
        val e = intent?.extras ?: return
        if (e.containsKey("uiTestMode")) {
            isUiTestMode = e.getBoolean("uiTestMode", false)
        }
        if (e.containsKey("mockAuthEmail")) {
            mockAuthEmail = e.getString("mockAuthEmail")
        }
        if (e.containsKey("apiBaseUrl")) {
            val url = e.getString("apiBaseUrl")
            if (url != null && !url.endsWith("/")) {
                apiBaseUrl = "$url/"
            } else {
                apiBaseUrl = url
            }
        }
        if (e.containsKey("apiKey")) {
            apiKey = e.getString("apiKey")
        }
        if (e.containsKey("authorizedEmails")) {
            authorizedEmails = e.getString("authorizedEmails")
        }
        if (e.containsKey("captureExternalLinks")) {
            captureExternalLinks = e.getBoolean("captureExternalLinks", false)
        }
    }
}
