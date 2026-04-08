bool isPalindrome(String input) {
  final cleanStr = input.replaceAll(RegExp(r'[^a-zA-Z0-9]'), '').toLowerCase();
  return cleanStr == cleanStr.split('').reversed.join('');
}

int countWords(String input) {
  if (input.trim().isEmpty) return 0;
  return input.trim().split(RegExp(r'\s+')).length;
}

String reverseWords(String input) {
  return input.trim().split(RegExp(r'\s+')).reversed.join(' ');
}

String capitalizeWords(String input) {
  if (input.isEmpty) return '';
  return input.split(RegExp(r'\s+')).map((word) {
    if (word.isEmpty) return '';
    return '${word[0].toUpperCase()}${word.substring(1).toLowerCase()}';
  }).join(' ');
}

String removeVowels(String input) {
  return input.replaceAll(RegExp(r'[aeiouAEIOU]'), '');
}

bool isValidEmail(String email) {
  return RegExp(r'^[\w-\.]+@([\w-]+\.)+[\w-]{2,4}$').hasMatch(email);
}
