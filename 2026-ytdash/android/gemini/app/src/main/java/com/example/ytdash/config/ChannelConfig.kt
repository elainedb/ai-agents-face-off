package com.example.ytdash.config

import kotlinx.serialization.Serializable

@Serializable
data class ChannelConfig(
    val id: String,
    val label: String
)
