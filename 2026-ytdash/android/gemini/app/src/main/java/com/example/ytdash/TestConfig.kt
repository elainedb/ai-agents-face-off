package com.example.ytdash

import android.content.Intent
import android.util.Log

object TestConfig {
    var uiTestMode: Boolean = false
    var mockAuthEmail: String? = null
    var apiBaseUrl: String = "https://www.googleapis.com"
    var apiKey: String = ""
    var authorizedEmails: List<String> = listOf("user1@example.com", "user2@example.com")
    var captureExternalLinks: Boolean = false

    fun initFromIntent(intent: Intent?) {
        if (intent == null) return
        val extras = intent.extras ?: return
        
        // Read values checking both boolean and string types for safety
        uiTestMode = if (extras.containsKey("uiTestMode")) {
            val v = extras.get("uiTestMode")
            v == true || v?.toString()?.lowercase() == "true"
        } else {
            false
        }
        
        mockAuthEmail = extras.getString("mockAuthEmail")
        
        val baseUrlExtra = extras.getString("apiBaseUrl")
        if (!baseUrlExtra.isNullOrBlank()) {
            apiBaseUrl = baseUrlExtra.trim().removeSuffix("/")
        } else {
            apiBaseUrl = "https://www.googleapis.com"
        }
        
        apiKey = extras.getString("apiKey") ?: ""
        
        val emailsCsv = extras.getString("authorizedEmails")
        if (!emailsCsv.isNullOrBlank()) {
            authorizedEmails = emailsCsv.split(",").map { it.trim() }.filter { it.isNotEmpty() }
        } else {
            authorizedEmails = listOf("user1@example.com", "user2@example.com")
        }
        
        captureExternalLinks = if (extras.containsKey("captureExternalLinks")) {
            val v = extras.get("captureExternalLinks")
            v == true || v?.toString()?.lowercase() == "true"
        } else {
            false
        }
        
        Log.d("TestConfig", "Parsed configuration: uiTestMode=$uiTestMode, mockAuthEmail=$mockAuthEmail, apiBaseUrl=$apiBaseUrl, apiKey=$apiKey, authorizedEmails=$authorizedEmails, captureExternalLinks=$captureExternalLinks")
    }
}
