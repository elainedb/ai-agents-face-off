package com.example.ytdash.data.repository

import android.content.Context
import com.example.ytdash.domain.models.Channel
import kotlinx.serialization.json.Json
import java.io.InputStreamReader

class ConfigRepository(private val context: Context) {
    private val json = Json { ignoreUnknownKeys = true }

    fun getChannels(): List<Channel> {
        val inputStream = context.assets.open("channels.json")
        val reader = InputStreamReader(inputStream)
        val content = reader.readText()
        reader.close()
        return try {
            json.decodeFromString<List<Channel>>(content)
        } catch (e: Exception) {
            emptyList()
        }
    }
}
