package dev.elainedb.ytdash_android_gemini.utils

import android.content.Context
import java.io.InputStream
import java.util.Properties

object ConfigHelper {
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
        
        for (fileName in filesToTry) {
            try {
                val inputStream: InputStream = context.assets.open(fileName)
                properties.load(inputStream)
                
                val emailsStr = properties.getProperty("authorized_emails")
                val keyStr = properties.getProperty("youtubeApiKey")
                
                if (!emailsStr.isNullOrBlank() && !keyStr.isNullOrBlank() && keyStr != "YOUR_YOUTUBE_API_KEY") {
                    authorizedEmails = emailsStr.split(",").map { it.trim() }
                    youtubeApiKey = keyStr
                    return
                }
            } catch (e: Exception) {
                // Ignore and try next file
            }
        }
        
        // Hardcoded fallbacks if all else fails
        authorizedEmails = listOf("aaa@gmail.com", "bbb@gmail.com", "ccc@gmail.com")
        youtubeApiKey = "abc"
    }
}
