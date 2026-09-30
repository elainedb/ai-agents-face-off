import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

abstract class AuthLocalDataSource {
  Future<List<String>> getAuthorizedEmails();
}

@LazySingleton(as: AuthLocalDataSource)
class AuthLocalDataSourceImpl implements AuthLocalDataSource {
  @override
  Future<List<String>> getAuthorizedEmails() async {
    String content;
    try {
      content = await rootBundle.loadString('assets/authorized_emails.local.txt');
    } catch (e) {
      content = await rootBundle.loadString('assets/authorized_emails.txt');
    }
    final emails = content.split('\n').where((line) => line.isNotEmpty).toList();
    return emails;
  }
}
