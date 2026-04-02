package dev.elainedb.ytdash_android_gemini

import android.content.Context
import android.util.Log
import java.io.InputStream
import java.util.Properties

object ConfigHelper {
    private const val TAG = "ConfigHelper"

    fun getAuthorizedEmails(context: Context): List<String> {
        val properties = loadProperties(context)
        val emailsStr = properties.getProperty("authorized_emails", "")
        return emailsStr.split(",").map { it.trim() }.filter { it.isNotEmpty() }
    }

    fun getYoutubeApiKey(context: Context): String {
        val properties = loadProperties(context)
        return properties.getProperty("youtubeApiKey", "")
    }

    private fun loadProperties(context: Context): Properties {
        val properties = Properties()
        val filesToTry = listOf("config.properties", "config.properties.ci", "config.properties.template")

        for (fileName in filesToTry) {
            try {
                val inputStream: InputStream = context.assets.open(fileName)
                properties.load(inputStream)
                Log.d(TAG, "Loaded config from $fileName")
                return properties
            } catch (e: Exception) {
                Log.d(TAG, "Could not load $fileName, trying next...")
            }
        }
        Log.w(TAG, "No config file found. Using defaults.")
        return properties
    }
}