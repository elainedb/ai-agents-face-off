package dev.elainedb.ytdash_android_gemini.utils

import android.content.Context
import java.io.IOException
import java.util.Properties
import javax.inject.Inject
import javax.inject.Singleton

@Singleton
class ConfigHelper @Inject constructor() {
    fun getAuthorizedEmails(context: Context): List<String> {
        val props = loadProperties(context)
        val emails = props.getProperty("authorized_emails") ?: ""
        return emails.split(",").map { it.trim() }.filter { it.isNotEmpty() }
    }

    fun getYouTubeApiKey(context: Context): String {
        val props = loadProperties(context)
        return props.getProperty("youtubeApiKey") ?: ""
    }

    private fun loadProperties(context: Context): Properties {
        val properties = Properties()
        val filesToTry = listOf("config.properties", "config.properties.ci", "config.properties.template")

        for (file in filesToTry) {
            try {
                context.assets.open(file).use { inputStream ->
                    properties.load(inputStream)
                    return properties
                }
            } catch (e: IOException) {
                // Ignore and try next file
            }
        }
        return properties
    }
}
