import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/exceptions.dart';

void main() {
  group('Exception Classes', () {
    test('AppException creates instance with message', () {
      final exception = AppException('Test error');
      expect(exception.message, 'Test error');
      expect(exception.statusCode, null);
    });

    test('AppException creates instance with message and status code', () {
      final exception = AppException('Test error', 500);
      expect(exception.message, 'Test error');
      expect(exception.statusCode, 500);
    });

    test('AppException toString includes message', () {
      final exception = AppException('Test error');
      expect(exception.toString(), contains('Test error'));
    });

    test('AppException toString includes status code when provided', () {
      final exception = AppException('Test error', 404);
      expect(exception.toString(), contains('404'));
    });

    test('NetworkException creates instance', () {
      final exception = NetworkException();
      expect(exception.message, 'No internet connection');
      expect(exception, isA<AppException>());
    });

    test('NetworkException with custom message', () {
      final exception = NetworkException('Connection timeout');
      expect(exception.message, 'Connection timeout');
    });

    test('ServerException creates instance', () {
      final exception = ServerException('Server error');
      expect(exception.message, 'Server error');
      expect(exception, isA<AppException>());
    });

    test('ServerException with status code', () {
      final exception = ServerException('Internal error', 500);
      expect(exception.message, 'Internal error');
      expect(exception.statusCode, 500);
    });

    test('ValidationException creates instance', () {
      final exception = ValidationException('Invalid data');
      expect(exception.message, 'Invalid data');
      expect(exception, isA<AppException>());
    });

    test('AuthException creates instance', () {
      final exception = AuthException('Auth failed');
      expect(exception.message, 'Auth failed');
      expect(exception, isA<AppException>());
    });

    test('NotFoundException creates instance with 404 status', () {
      final exception = NotFoundException('Not found');
      expect(exception.message, 'Not found');
      expect(exception.statusCode, 404);
      expect(exception, isA<AppException>());
    });

    test('UnauthorizedException creates instance with default message', () {
      final exception = UnauthorizedException();
      expect(exception.message, 'Unauthorized access');
      expect(exception.statusCode, 401);
    });

    test('UnauthorizedException with custom message', () {
      final exception = UnauthorizedException('Token invalid');
      expect(exception.message, 'Token invalid');
      expect(exception.statusCode, 401);
    });

    test('FirestoreException creates instance', () {
      final exception = FirestoreException('Firestore error');
      expect(exception.message, 'Firestore error');
      expect(exception, isA<AppException>());
    });

    test('CacheException creates instance', () {
      final exception = CacheException('Cache miss');
      expect(exception.message, 'Cache miss');
      expect(exception, isA<AppException>());
    });
  });
}

