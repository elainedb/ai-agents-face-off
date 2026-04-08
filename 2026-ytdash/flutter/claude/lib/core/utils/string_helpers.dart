bool isPalindrome(String input) {
  final cleaned = input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
  return cleaned == cleaned.split('').reversed.join('');
}

int countWords(String input) {
  if (input.trim().isEmpty) return 0;
  return input.trim().split(RegExp(r'\s+')).length;
}

String reverseWords(String input) {
  return input.split(' ').reversed.join(' ');
}

String capitalizeWords(String input) {
  return input.split(' ').map((word) {
    if (word.isEmpty) return word;
    return word[0].toUpperCase() + word.substring(1).toLowerCase();
  }).join(' ');
}

String removeVowels(String input) {
  return input.replaceAll(RegExp(r'[aeiouAEIOU]'), '');
}

bool isValidEmail(String email) {
  return RegExp(r'^[a-zA-Z0-9._%+-]+@[a-zA-Z0-9.-]+\.[a-zA-Z]{2,}$')
      .hasMatch(email);
}
