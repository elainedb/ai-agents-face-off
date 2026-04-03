package dev.elainedb.ytdash_android_gemini.utils

import android.content.Context
import java.io.IOException
import java.util.Properties

object ConfigHelper {

    private const val CONFIG_FILE = "config.properties"
    private const val CONFIG_CI_FILE = "config.properties.ci"
    private const val CONFIG_TEMPLATE_FILE = "config.properties.template"

    private const val KEY_AUTHORIZED_EMAILS = "authorized_emails"
    private const val KEY_YOUTUBE_API_KEY = "youtubeApiKey"

    fun getAuthorizedEmails(context: Context): List<String> {
        val emailsString = getConfigValue(context, KEY_AUTHORIZED_EMAILS, "")
        return if (emailsString.isNotEmpty()) {
            emailsString.split(",").map { it.trim() }
        } else {
            emptyList()
        }
    }

    fun getYouTubeApiKey(context: Context): String {
        return getConfigValue(context, KEY_YOUTUBE_API_KEY, "DEFAULT_API_KEY")
    }

    private fun getConfigValue(context: Context, key: String, defaultValue: String): String {
        val filesToTry = listOf(CONFIG_FILE, CONFIG_CI_FILE, CONFIG_TEMPLATE_FILE)

        for (fileName in filesToTry) {
            try {
                context.assets.open(fileName).use { inputStream ->
                    val properties = Properties()
                    properties.load(inputStream)
                    val value = properties.getProperty(key)
                    if (value != null) {
                        return value
                    }
                }
            } catch (e: IOException) {
                // Ignore and try the next file
            }
        }

        return defaultValue
    }
}
