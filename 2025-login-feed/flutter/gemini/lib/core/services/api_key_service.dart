import 'package:flutter/services.dart';
import 'package:injectable/injectable.dart';

@lazySingleton
class ApiKeyService {
  Future<String> getApiKey() async {
    try {
      return await rootBundle.loadString('assets/api_key_local.txt');
    } catch (e) {
      return await rootBundle.loadString('assets/api_key.txt');
    }
  }
}
