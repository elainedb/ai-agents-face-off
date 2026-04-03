package dev.elainedb.ytdash_android_gemini.utils

import android.content.Context
import java.io.InputStream
import java.util.Properties

object ConfigHelper {
    private const val PROPERTIES_FILE = "config.properties"
    private const val CI_PROPERTIES_FILE = "config.properties.ci"
    private const val TEMPLATE_PROPERTIES_FILE = "config.properties.template"

    fun getConfig(context: Context): Properties {
        val properties = Properties()
        
        // Try to load in fallback order
        val filesToTry = listOf(PROPERTIES_FILE, CI_PROPERTIES_FILE, TEMPLATE_PROPERTIES_FILE)
        
        for (fileName in filesToTry) {
            try {
                context.assets.open(fileName).use { inputStream: InputStream ->
                    properties.load(inputStream)
                    return properties
                }
            } catch (e: Exception) {
                // File not found or could not be read, try next
            }
        }
        
        return properties
    }

    fun getAuthorizedEmails(context: Context): List<String> {
        val config = getConfig(context)
        val emailsStr = config.getProperty("authorized_emails", "")
        return emailsStr.split(",").map { it.trim() }.filter { it.isNotEmpty() }
    }

    fun getYoutubeApiKey(context: Context): String {
        val config = getConfig(context)
        return config.getProperty("youtubeApiKey", "")
    }
}
