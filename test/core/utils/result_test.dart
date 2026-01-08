import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/core/utils/result.dart';

void main() {
  group('ResultX Extension', () {
    test('isSuccess returns true for Right value', () {
      final result = Right<Failure, int>(42);
      expect(result.isSuccess, true);
      expect(result.isFailure, false);
    });

    test('isFailure returns true for Left value', () {
      final result = Left<Failure, int>(const ServerFailure('Error'));
      expect(result.isFailure, true);
      expect(result.isSuccess, false);
    });

    test('valueOrNull returns value for Right', () {
      final result = Right<Failure, int>(42);
      expect(result.valueOrNull, 42);
    });

    test('valueOrNull returns null for Left', () {
      final result = Left<Failure, int>(const ServerFailure('Error'));
      expect(result.valueOrNull, null);
    });

    test('failureOrNull returns failure for Left', () {
      const failure = ServerFailure('Error');
      final result = Left<Failure, int>(failure);
      expect(result.failureOrNull, failure);
    });

    test('failureOrNull returns null for Right', () {
      final result = Right<Failure, int>(42);
      expect(result.failureOrNull, null);
    });
  });

  group('ResultHelper', () {
    test('success creates Right value', () {
      final result = ResultHelper.success(42);
      expect(result.isRight(), true);
      expect(result.fold((l) => null, (r) => r), 42);
    });

    test('failure creates Left value', () {
      const failure = ServerFailure('Error');
      final result = ResultHelper.failure<int>(failure);
      expect(result.isLeft(), true);
      expect(result.fold((l) => l, (r) => null), failure);
    });

    test('success and failure work with different types', () {
      final stringResult = ResultHelper.success('Hello');
      final listResult = ResultHelper.success([1, 2, 3]);
      final failureResult = ResultHelper.failure<String>(const NetworkFailure());

      expect(stringResult.valueOrNull, 'Hello');
      expect(listResult.valueOrNull, [1, 2, 3]);
      expect(failureResult.failureOrNull, isA<NetworkFailure>());
    });
  });
}

