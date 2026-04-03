abstract class AppException implements Exception {
  final String message;
  AppException(this.message);
}

class ServerException extends AppException {
  ServerException([super.message = 'A server error occurred.']);
}

class CacheException extends AppException {
  CacheException([super.message = 'A cache error occurred.']);
}

class NetworkException extends AppException {
  NetworkException([super.message = 'A network error occurred.']);
}

class AuthException extends AppException {
  AuthException([super.message = 'An authentication error occurred.']);
}