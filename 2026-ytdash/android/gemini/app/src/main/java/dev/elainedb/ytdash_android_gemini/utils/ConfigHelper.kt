package dev.elainedb.ytdash_android_gemini.utils

import android.content.Context
import java.io.InputStream
import java.util.Properties

object ConfigHelper {
    private const val FALLBACK_API_KEY = "dummy_api_key"
    private const val FALLBACK_EMAILS = "dummy@example.com"

    fun getConfigValue(context: Context, key: String, defaultValue: String): String {
        val filesToTry = listOf(
            "config.properties",
            "config.properties.ci",
            "config.properties.template"
        )

        for (fileName in filesToTry) {
            try {
                val inputStream: InputStream = context.assets.open(fileName)
                val properties = Properties()
                properties.load(inputStream)
                val value = properties.getProperty(key)
                if (value != null && !value.contains("YOUR_YOUTUBE_API_KEY") && value.isNotBlank()) {
                    return value
                }
            } catch (e: Exception) {
                // Ignore and try next file
            }
        }
        return defaultValue
    }

    fun getAuthorizedEmails(context: Context): List<String> {
        val emailsString = getConfigValue(context, "authorized_emails", FALLBACK_EMAILS)
        return emailsString.split(",").map { it.trim() }.filter { it.isNotEmpty() }
    }

    fun getYouTubeApiKey(context: Context): String {
        return getConfigValue(context, "youtubeApiKey", FALLBACK_API_KEY)
    }
}