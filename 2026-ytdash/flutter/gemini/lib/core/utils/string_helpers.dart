bool isPalindrome(String input) {
  final clean = input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
  if (clean.isEmpty) return true;
  for (int i = 0; i < clean.length ~/ 2; i++) {
    if (clean[i] != clean[clean.length - 1 - i]) return false;
  }
  return true;
}

int countWords(String input) {
  if (input.trim().isEmpty) return 0;
  return input.trim().split(RegExp(r'\s+')).length;
}

String reverseWords(String input) {
  if (input.trim().isEmpty) return input;
  return input.trim().split(RegExp(r'\s+')).reversed.join(' ');
}

String capitalizeWords(String input) {
  if (input.trim().isEmpty) return input;
  return input.trim().split(RegExp(r'\s+')).map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

String removeVowels(String input) {
  return input.replaceAll(RegExp(r'[aeiouAEIOU]'), '');
}

bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}
