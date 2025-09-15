import 'package:flutter/services.dart' show rootBundle;

Future<List<String>> getAuthorizedEmails() async {
  try {
    final content = await rootBundle.loadString('assets/authorized_emails.local.txt');
    return content.split('\n').where((line) => line.trim().isNotEmpty).toList();
  } catch (e) {
    final content = await rootBundle.loadString('assets/authorized_emails.txt');
    return content.split('\n').where((line) => line.trim().isNotEmpty).toList();
  }
}