package com.example.ytdash.domain

import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class AuthTest {
    private val whitelist = listOf("user1@example.com", "user2@example.com")

    @Test
    fun authorizedEmail_isAllowed() {
        assertTrue(Auth.isAuthorized("user2@example.com", whitelist))
    }

    @Test
    fun authorizedEmail_isCaseInsensitiveAndTrimmed() {
        assertTrue(Auth.isAuthorized("  USER2@example.com ", whitelist))
    }

    @Test
    fun unauthorizedEmail_isDenied() {
        assertFalse(Auth.isAuthorized("intruder@example.com", whitelist))
    }

    @Test
    fun nullOrBlankEmail_isDenied() {
        assertFalse(Auth.isAuthorized(null, whitelist))
        assertFalse(Auth.isAuthorized("", whitelist))
        assertFalse(Auth.isAuthorized("   ", whitelist))
    }
}
