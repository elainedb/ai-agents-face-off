export class AppException extends Error {
  constructor(message: string) {
    super(message);
    this.name = 'AppException';
  }
}

export class ServerException extends AppException {
  constructor(message: string) {
    super(message);
    this.name = 'ServerException';
  }
}

export class CacheException extends AppException {
  constructor(message: string) {
    super(message);
    this.name = 'CacheException';
  }
}

export class NetworkException extends AppException {
  constructor(message: string) {
    super(message);
    this.name = 'NetworkException';
  }
}

export class AuthException extends AppException {
  constructor(message: string) {
    super(message);
    this.name = 'AuthException';
  }
}
