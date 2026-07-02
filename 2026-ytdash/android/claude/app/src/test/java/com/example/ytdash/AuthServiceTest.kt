package com.example.ytdash

import com.example.ytdash.domain.AuthService
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class AuthServiceTest {

    private val auth = AuthService("user1@example.com, user2@example.com")

    @Test
    fun authorizedEmailIsAllowed() {
        assertTrue(auth.isAuthorized("user2@example.com"))
        assertTrue(auth.isAuthorized("user1@example.com"))
    }

    @Test
    fun authorizationIsCaseInsensitiveAndTrimmed() {
        assertTrue(auth.isAuthorized("  USER2@example.com "))
    }

    @Test
    fun unauthorizedEmailIsDenied() {
        assertFalse(auth.isAuthorized("intruder@example.com"))
        assertFalse(auth.isAuthorized(null))
        assertFalse(auth.isAuthorized(""))
    }

    @Test
    fun emptyWhitelistDeniesEveryone() {
        val empty = AuthService(null)
        assertFalse(empty.isAuthorized("user2@example.com"))
    }
}
