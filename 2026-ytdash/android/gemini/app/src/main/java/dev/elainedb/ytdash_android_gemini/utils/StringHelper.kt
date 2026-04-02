package dev.elainedb.ytdash_android_gemini.utils

object StringHelper {

    fun isPalindrome(input: String): Boolean {
        val clean = input.replace(Regex("[^A-Za-z0-9]"), "").lowercase()
        return clean.isNotEmpty() && clean == clean.reversed()
    }

    fun countWords(input: String): Int {
        if (input.trim().isEmpty()) return 0
        return input.trim().split(Regex("\\s+")).size
    }

    fun reverseWords(input: String): String {
        return input.trim().split(Regex("\\s+")).reversed().joinToString(" ")
    }

    fun capitalizeWords(input: String): String {
        return input.split(" ").joinToString(" ") { word ->
            word.replaceFirstChar { if (it.isLowerCase()) it.titlecase() else it.toString() }
        }
    }

    fun removeVowels(input: String): String {
        return input.replace(Regex("[aeiouAEIOU]"), "")
    }

    fun isValidEmail(email: String): Boolean {
        val regex = Regex("^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\\.[A-Za-z]{2,6}$")
        return regex.matches(email)
    }
}