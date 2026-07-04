package com.example.ytdash.data.repository

import android.content.Context
import com.example.ytdash.TestConfig
import com.example.ytdash.domain.auth.WhitelistManager

class AuthRepository(
    private val context: Context,
    private val whitelistManager: WhitelistManager
) {
    private var signedInEmail: String? = null

    // For UI Test Mode
    fun signInMock(testConfig: TestConfig): Result<String> {
        val email = testConfig.mockAuthEmail ?: return Result.failure(Exception("No mock email provided"))
        val isAuth = whitelistManager.isAuthorized(email, testConfig.authorizedEmails)
        return if (isAuth) {
            signedInEmail = email
            Result.success(email)
        } else {
            Result.failure(Exception("Unauthorized email"))
        }
    }

    // Real implementation would use Google Sign-In. 
    // Since UI test mode provides `mockAuthEmail`, we use that for tests.
    // For simplicity here, we allow mocking directly or just passing an email.
    fun signInReal(email: String, testConfig: TestConfig): Result<String> {
        val isAuth = whitelistManager.isAuthorized(email, testConfig.authorizedEmails)
        return if (isAuth) {
            signedInEmail = email
            Result.success(email)
        } else {
            Result.failure(Exception("Unauthorized email"))
        }
    }

    fun getSignedInEmail(): String? = signedInEmail

    fun signOut() {
        signedInEmail = null
    }
}
