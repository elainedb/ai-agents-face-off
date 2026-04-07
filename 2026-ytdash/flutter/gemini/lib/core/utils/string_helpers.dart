class StringHelpers {
  static bool isPalindrome(String input) {
    final clean = input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
    return clean == clean.split('').reversed.join('');
  }

  static int countWords(String input) {
    if (input.trim().isEmpty) return 0;
    return input.trim().split(RegExp(r'\s+')).length;
  }

  static String reverseWords(String input) {
    return input.split(' ').reversed.join(' ');
  }

  static String capitalizeWords(String input) {
    if (input.isEmpty) return input;
    return input.split(' ').map((word) {
      if (word.isEmpty) return word;
      return word[0].toUpperCase() + word.substring(1).toLowerCase();
    }).join(' ');
  }

  static String removeVowels(String input) {
    return input.replaceAll(RegExp(r'[aeiouAEIOU]'), '');
  }

  static bool isValidEmail(String email) {
    return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
  }
}