package com.example.ytdash.data.repository

import android.content.Context
import com.example.ytdash.data.model.TestConfig

class AuthRepository(
    private val context: Context,
    private val testConfig: TestConfig
) {
    // Default whitelisted emails
    private val defaultWhitelist = listOf(
        "user1@example.com",
        "user2@example.com"
    )

    private var currentUserEmail: String? = null

    /**
     * Set the current signed in email
     */
    fun setCurrentUser(email: String?) {
        currentUserEmail = email
    }

    /**
     * Get the current signed in email
     */
    fun getCurrentUserEmail(): String? = currentUserEmail

    /**
     * Returns whether the given email is whitelisted.
     */
    fun isEmailWhitelisted(email: String): Boolean {
        val whitelist = if (testConfig.uiTestMode && testConfig.authorizedEmails != null) {
            testConfig.authorizedEmails
        } else {
            defaultWhitelist
        }
        return whitelist.contains(email.trim())
    }

    /**
     * Log out current user
     */
    fun logout() {
        currentUserEmail = null
    }
}
