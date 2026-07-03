package com.example.ytdash

import android.content.Context
import android.util.Log

object AuthManager {
    private var currentUserEmail: String? = null

    fun init(context: Context) {
        val sharedPrefs = context.getSharedPreferences("ytdash_auth", Context.MODE_PRIVATE)
        if (TestConfig.uiTestMode) {
            currentUserEmail = null
        } else {
            currentUserEmail = sharedPrefs.getString("authenticated_email", null)
        }
    }

    fun getAuthenticatedEmail(): String? = currentUserEmail

    fun login(context: Context, email: String): Boolean {
        val whitelist = TestConfig.authorizedEmails
        Log.d("AuthManager", "Attempting login with email: $email, Whitelist: $whitelist")
        
        if (whitelist.contains(email)) {
            currentUserEmail = email
            val sharedPrefs = context.getSharedPreferences("ytdash_auth", Context.MODE_PRIVATE)
            sharedPrefs.edit().putString("authenticated_email", email).apply()
            return true
        }
        return false
    }

    fun logout(context: Context) {
        currentUserEmail = null
        val sharedPrefs = context.getSharedPreferences("ytdash_auth", Context.MODE_PRIVATE)
        sharedPrefs.edit().remove("authenticated_email").apply()
    }

    fun isAuthenticated(): Boolean {
        return currentUserEmail != null
    }
}
