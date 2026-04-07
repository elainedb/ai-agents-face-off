package dev.elainedb.ytdash_android_gemini.utils

object StringHelper {
    fun isPalindrome(input: String): Boolean {
        val cleanInput = input.replace(Regex("[^A-Za-z0-9]"), "").lowercase()
        return cleanInput == cleanInput.reversed()
    }

    fun countWords(input: String): Int {
        if (input.trim().isEmpty()) return 0
        return input.trim().split(Regex("\\s+")).size
    }

    fun reverseWords(input: String): String {
        return input.split(Regex("\\s+")).reversed().joinToString(" ")
    }

    fun capitalizeWords(input: String): String {
        return input.split(Regex("\\s+")).joinToString(" ") { word ->
            word.replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
        }
    }

    fun removeVowels(input: String): String {
        return input.replace(Regex("[aeiouAEIOU]"), "")
    }

    fun isValidEmail(email: String): Boolean {
        return email.matches(Regex("^[A-Za-z0-9+_.-]+@[A-Za-z0-9.-]+$"))
    }
}