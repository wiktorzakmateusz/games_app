import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';

void main() {
  group('Failure Classes', () {
    test('NetworkFailure creates instance with default message', () {
      const failure = NetworkFailure();
      expect(failure.message, 'No internet connection');
      expect(failure.props, ['No internet connection']);
    });

    test('NetworkFailure creates instance with custom message', () {
      const failure = NetworkFailure('Custom network error');
      expect(failure.message, 'Custom network error');
    });

    test('ServerFailure creates instance with message', () {
      const failure = ServerFailure('Server error');
      expect(failure.message, 'Server error');
      expect(failure.statusCode, null);
    });

    test('ServerFailure creates instance with message and status code', () {
      const failure = ServerFailure('Not found', 404);
      expect(failure.message, 'Not found');
      expect(failure.statusCode, 404);
      expect(failure.props, ['Not found', 404]);
    });

    test('ValidationFailure creates instance', () {
      const failure = ValidationFailure('Invalid input');
      expect(failure.message, 'Invalid input');
      expect(failure.props, ['Invalid input']);
    });

    test('AuthFailure creates instance', () {
      const failure = AuthFailure('Authentication failed');
      expect(failure.message, 'Authentication failed');
      expect(failure.props, ['Authentication failed']);
    });

    test('NotFoundFailure creates instance with 404 status', () {
      const failure = NotFoundFailure('Resource not found');
      expect(failure.message, 'Resource not found');
      expect(failure.props, ['Resource not found']);
    });

    test('UnauthorizedFailure creates instance with default message', () {
      const failure = UnauthorizedFailure();
      expect(failure.message, 'Unauthorized access');
    });

    test('UnauthorizedFailure creates instance with custom message', () {
      const failure = UnauthorizedFailure('Token expired');
      expect(failure.message, 'Token expired');
    });

    test('UnexpectedFailure creates instance with default message', () {
      const failure = UnexpectedFailure();
      expect(failure.message, 'An unexpected error occurred');
    });

    test('UnexpectedFailure creates instance with custom message', () {
      const failure = UnexpectedFailure('Something went wrong');
      expect(failure.message, 'Something went wrong');
    });

    test('FirestoreFailure creates instance', () {
      const failure = FirestoreFailure('Firestore error');
      expect(failure.message, 'Firestore error');
      expect(failure.props, ['Firestore error']);
    });

    test('Failures with same message are equal', () {
      const failure1 = ServerFailure('Error');
      const failure2 = ServerFailure('Error');
      expect(failure1, failure2);
    });

    test('Failures with different messages are not equal', () {
      const failure1 = ServerFailure('Error 1');
      const failure2 = ServerFailure('Error 2');
      expect(failure1, isNot(failure2));
    });

    test('Different failure types with same message are not equal', () {
      const networkFailure = NetworkFailure('Error');
      const serverFailure = ServerFailure('Error');
      expect(networkFailure, isNot(serverFailure));
    });
  });
}

