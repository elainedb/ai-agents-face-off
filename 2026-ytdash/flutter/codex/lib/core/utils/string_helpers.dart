bool isPalindrome(String input) {
  final normalized = input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
  return normalized == normalized.split('').reversed.join();
}

int countWords(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    return 0;
  }
  return trimmed.split(RegExp(r'\s+')).length;
}

String reverseWords(String input) {
  final trimmed = input.trim();
  if (trimmed.isEmpty) {
    return '';
  }
  return trimmed.split(RegExp(r'\s+')).reversed.join(' ');
}

String capitalizeWords(String input) {
  return input
      .trim()
      .split(RegExp(r'\s+'))
      .where((part) => part.isNotEmpty)
      .map(
        (word) => '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}',
      )
      .join(' ');
}

String removeVowels(String input) {
  return input.replaceAll(RegExp(r'[aeiou]', caseSensitive: false), '');
}

bool isValidEmail(String email) {
  return RegExp(r'^[^@\s]+@[^@\s]+\.[^@\s]+$').hasMatch(email);
}
