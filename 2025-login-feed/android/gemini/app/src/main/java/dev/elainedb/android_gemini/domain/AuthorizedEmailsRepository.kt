package dev.elainedb.android_gemini.domain

interface AuthorizedEmailsRepository {
    suspend fun isEmailAuthorized(email: String): Boolean
}
