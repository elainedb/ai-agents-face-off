package dev.elainedb.ytdash_android_gemini.core.error

sealed class AppException(message: String) : Exception(message)
class ServerException(message: String) : AppException(message)
class CacheException(message: String) : AppException(message)
class NetworkException(message: String) : AppException(message)
class AuthException(message: String) : AppException(message)
