package dev.elainedb.ytdash_android_gemini

import android.content.Context
import java.io.InputStream
import java.util.Properties

object ConfigHelper {
    private const val CONFIG_FILE_LOCAL = "config.properties"
    private const val CONFIG_FILE_CI = "config.properties.ci"
    private const val CONFIG_FILE_TEMPLATE = "config.properties.template"

    private val properties = Properties()
    private var isInitialized = false

    fun init(context: Context) {
        if (isInitialized) return
        
        loadProperties(context, CONFIG_FILE_LOCAL) ||
        loadProperties(context, CONFIG_FILE_CI) ||
        loadProperties(context, CONFIG_FILE_TEMPLATE)
        
        isInitialized = true
    }

    private fun loadProperties(context: Context, fileName: String): Boolean {
        return try {
            val inputStream: InputStream = context.assets.open(fileName)
            properties.load(inputStream)
            true
        } catch (e: Exception) {
            false
        }
    }

    fun getAuthorizedEmails(): List<String> {
        val emailsString = properties.getProperty("authorized_emails")
        return if (!emailsString.isNullOrEmpty()) {
            emailsString.split(",").map { it.trim() }
        } else {
            emptyList()
        }
    }

    fun getYoutubeApiKey(): String {
        return properties.getProperty("youtubeApiKey", "")
    }
}