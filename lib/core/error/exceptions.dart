class AppException implements Exception {
  final String message;
  final int? statusCode;

  AppException(this.message, [this.statusCode]);

  @override
  String toString() => 'AppException: $message${statusCode != null ? ' (Status: $statusCode)' : ''}';
}

class NetworkException extends AppException {
  NetworkException([super.message = 'No internet connection']);
}

class ServerException extends AppException {
  ServerException(super.message, [super.statusCode]);
}

class ValidationException extends AppException {
  ValidationException(super.message);
}

class AuthException extends AppException {
  AuthException(super.message);
}

class NotFoundException extends AppException {
  NotFoundException(String message) : super(message, 404);
}

class UnauthorizedException extends AppException {
  UnauthorizedException([String message = 'Unauthorized access']) : super(message, 401);
}

class FirestoreException extends AppException {
  FirestoreException(super.message);
}

class CacheException extends AppException {
  CacheException(super.message);
}

