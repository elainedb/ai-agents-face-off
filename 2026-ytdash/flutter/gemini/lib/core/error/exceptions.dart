abstract class AppException implements Exception {
  final String message;
  const AppException(this.message);
}

class ServerException extends AppException {
  const ServerException([super.message = 'A server error occurred']);
}

class CacheException extends AppException {
  const CacheException([super.message = 'A cache error occurred']);
}

class NetworkException extends AppException {
  const NetworkException([super.message = 'A network error occurred']);
}

class AuthException extends AppException {
  const AuthException([super.message = 'An authentication error occurred']);
}
