package dev.elainedb.ytdash_android_gemini.utils

import android.content.Context
import android.util.Log
import java.util.Properties

object ConfigHelper {
    private const val TAG = "ConfigHelper"
    var authorizedEmails: List<String> = emptyList()
        private set
    var youtubeApiKey: String = ""
        private set

    fun init(context: Context) {
        val properties = Properties()
        val filesToTry = listOf(
            "config.properties",
            "config.properties.ci",
            "config.properties.template"
        )

        var loaded = false
        for (file in filesToTry) {
            try {
                context.assets.open(file).use {
                    properties.load(it)
                }
                loaded = true
                Log.d(TAG, "Loaded config from $file")
                break
            } catch (e: Exception) {
                Log.d(TAG, "Could not load $file: ${e.message}")
            }
        }

        if (!loaded) {
            Log.w(TAG, "No config file found. Using hardcoded fallbacks.")
        }

        val emailsStr = properties.getProperty("authorized_emails", "default@domain.com")
        authorizedEmails = emailsStr.split(",").map { it.trim() }
        youtubeApiKey = properties.getProperty("youtubeApiKey", "HARDCODED_KEY")
    }
}
