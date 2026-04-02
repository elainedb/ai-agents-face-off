package dev.elainedb.ytdash_android_gemini.utils

import android.content.Context
import java.util.Properties

object ConfigHelper {
    private const val CONFIG_FILE = "config.properties"
    private const val CONFIG_FILE_CI = "config.properties.ci"
    private const val CONFIG_FILE_TEMPLATE = "config.properties.template"

    private var properties: Properties = Properties()

    fun init(context: Context) {
        val filesToTry = listOf(CONFIG_FILE, CONFIG_FILE_CI, CONFIG_FILE_TEMPLATE)
        for (fileName in filesToTry) {
            try {
                context.assets.open(fileName).use { inputStream ->
                    properties.load(inputStream)
                }
                return
            } catch (e: Exception) {
                // Try next file
            }
        }
    }

    fun getAuthorizedEmails(): List<String> {
        return properties.getProperty("authorized_emails", "")
            .split(",")
            .map { it.trim() }
            .filter { it.isNotEmpty() }
    }

    fun getYoutubeApiKey(): String {
        return properties.getProperty("youtubeApiKey", "")
    }
}
