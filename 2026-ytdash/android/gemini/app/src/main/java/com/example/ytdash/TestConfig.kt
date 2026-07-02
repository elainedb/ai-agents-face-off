package com.example.ytdash

import android.content.Intent
import android.util.Log

object TestConfig {
    var uiTestMode: Boolean = false
    var mockAuthEmail: String? = null
    var apiBaseUrl: String = "https://www.googleapis.com"
    var apiKey: String? = null
    var authorizedEmails: List<String> = listOf("user1@example.com", "user2@example.com")
    var captureExternalLinks: Boolean = false

    // App global state to capture the last externally opened URL when captureExternalLinks = true
    var lastCapturedUrl: String? = null

    fun initFromIntent(intent: Intent?) {
        val extras = intent?.extras
        if (extras != null) {
            // Note: Maestro can sometimes pass extra values in different ways or types.
            // Check for both string or boolean for robust detection.
            uiTestMode = when (val value = extras.get("uiTestMode")) {
                is Boolean -> value
                is String -> value.toBoolean()
                else -> false
            }
            
            if (uiTestMode) {
                mockAuthEmail = extras.getString("mockAuthEmail")
                
                val rawUrl = extras.getString("apiBaseUrl")
                if (!rawUrl.isNullOrEmpty()) {
                    apiBaseUrl = rawUrl
                }
                
                val rawApiKey = extras.getString("apiKey")
                if (!rawApiKey.isNullOrEmpty()) {
                    apiKey = rawApiKey
                }
                
                val rawEmails = extras.getString("authorizedEmails")
                if (!rawEmails.isNullOrEmpty()) {
                    authorizedEmails = rawEmails.split(",").map { it.trim() }.filter { it.isNotEmpty() }
                }
                
                captureExternalLinks = when (val cap = extras.get("captureExternalLinks")) {
                    is Boolean -> cap
                    is String -> cap.toBoolean()
                    else -> false
                }
                
                Log.d("TestConfig", "Initialized in UI TEST MODE: apiBaseUrl=$apiBaseUrl, mockAuthEmail=$mockAuthEmail, captureExternalLinks=$captureExternalLinks, authorizedEmails=$authorizedEmails")
            } else {
                Log.d("TestConfig", "Initialized in REAL mode")
            }
        }
    }
}
