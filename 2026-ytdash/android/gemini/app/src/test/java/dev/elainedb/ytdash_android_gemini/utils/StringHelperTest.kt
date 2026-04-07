package dev.elainedb.ytdash_android_gemini.utils

import org.junit.Assert.assertEquals
import org.junit.Assert.assertFalse
import org.junit.Assert.assertTrue
import org.junit.Test

class StringHelperTest {

    @Test
    fun testIsPalindrome() {
        assertTrue(StringHelper.isPalindrome("A man, a plan, a canal: Panama"))
        assertTrue(StringHelper.isPalindrome("racecar"))
        assertFalse(StringHelper.isPalindrome("hello"))
    }

    @Test
    fun testCountWords() {
        assertEquals(3, StringHelper.countWords("Hello world this"))
        assertEquals(0, StringHelper.countWords("  "))
    }

    @Test
    fun testReverseWords() {
        assertEquals("world Hello", StringHelper.reverseWords("Hello world"))
    }

    @Test
    fun testCapitalizeWords() {
        assertEquals("Hello World", StringHelper.capitalizeWords("hello world"))
    }

    @Test
    fun testRemoveVowels() {
        assertEquals("hll wrld", StringHelper.removeVowels("hello world"))
    }

    @Test
    fun testIsValidEmail() {
        assertTrue(StringHelper.isValidEmail("test@example.com"))
        assertFalse(StringHelper.isValidEmail("invalid-email"))
    }
}