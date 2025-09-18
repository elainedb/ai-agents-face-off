package dev.elainedb.android_gemini.domain

interface GoogleAuthRepository {
    suspend fun signOut()
}
