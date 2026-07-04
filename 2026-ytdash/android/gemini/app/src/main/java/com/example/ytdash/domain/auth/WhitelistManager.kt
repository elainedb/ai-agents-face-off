package com.example.ytdash.domain.auth

class WhitelistManager {
    fun isAuthorized(email: String, authorizedEmails: String?): Boolean {
        val whitelist = authorizedEmails?.split(",")?.map { it.trim() }?.filter { it.isNotEmpty() } ?: emptyList()
        return whitelist.contains(email)
    }
}
