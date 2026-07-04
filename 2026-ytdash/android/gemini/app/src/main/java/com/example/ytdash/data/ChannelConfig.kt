package com.example.ytdash.data

import android.content.Context
import kotlinx.serialization.Serializable
import kotlinx.serialization.json.Json

@Serializable
data class ChannelConfig(
    val id: String,
    val label: String
)

object ConfigLoader {
    fun loadChannels(context: Context): List<ChannelConfig> {
        val jsonString = context.assets.open("channels.json").bufferedReader().use { it.readText() }
        val format = Json { ignoreUnknownKeys = true }
        return format.decodeFromString(jsonString)
    }
}
