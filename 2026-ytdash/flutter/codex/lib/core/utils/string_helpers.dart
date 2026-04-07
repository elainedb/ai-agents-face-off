bool isPalindrome(String input) {
  final String normalized = input
      .replaceAll(RegExp(r'[^a-zA-Z0-9]'), '')
      .toLowerCase();
  return normalized == normalized.split('').reversed.join();
}

int countWords(String input) {
  final String trimmed = input.trim();
  if (trimmed.isEmpty) {
    return 0;
  }

  return trimmed.split(RegExp(r'\s+')).length;
}

String reverseWords(String input) {
  final String trimmed = input.trim();
  if (trimmed.isEmpty) {
    return '';
  }

  return trimmed.split(RegExp(r'\s+')).reversed.join(' ');
}

String capitalizeWords(String input) {
  return input
      .split(RegExp(r'\s+'))
      .where((String word) => word.isNotEmpty)
      .map(
        (String word) =>
            '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String removeVowels(String input) {
  return input.replaceAll(RegExp(r'[aeiou]', caseSensitive: false), '');
}

bool isValidEmail(String email) {
  return RegExp(
    r'^[A-Za-z0-9._%+-]+@[A-Za-z0-9.-]+\.[A-Za-z]{2,}$',
  ).hasMatch(email);
}
