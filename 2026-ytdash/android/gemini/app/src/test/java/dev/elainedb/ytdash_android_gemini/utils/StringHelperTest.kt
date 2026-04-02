package dev.elainedb.ytdash_android_gemini.utils

import org.junit.Assert.*
import org.junit.Test

class StringHelperTest {

    @Test
    fun isPalindrome_returnsTrueForPalindrome() {
        assertTrue(StringHelper.isPalindrome("A man, a plan, a canal: Panama"))
        assertTrue(StringHelper.isPalindrome("racecar"))
    }

    @Test
    fun isPalindrome_returnsFalseForNonPalindrome() {
        assertFalse(StringHelper.isPalindrome("hello"))
    }

    @Test
    fun countWords_returnsCorrectCount() {
        assertEquals(3, StringHelper.countWords("Hello   world  again"))
        assertEquals(0, StringHelper.countWords("   "))
    }

    @Test
    fun reverseWords_returnsReversedWords() {
        assertEquals("again world Hello", StringHelper.reverseWords("Hello world again"))
    }

    @Test
    fun capitalizeWords_capitalizesEachWord() {
        assertEquals("Hello World", StringHelper.capitalizeWords("hello world"))
    }

    @Test
    fun removeVowels_removesAllVowels() {
        assertEquals("hll wrld", StringHelper.removeVowels("hello world"))
        assertEquals("Hll", StringHelper.removeVowels("Hello"))
    }

    @Test
    fun isValidEmail_validatesCorrectly() {
        assertTrue(StringHelper.isValidEmail("test@example.com"))
        assertFalse(StringHelper.isValidEmail("invalid-email"))
        assertFalse(StringHelper.isValidEmail("test@example"))
    }
}