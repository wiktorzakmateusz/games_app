import 'package:dartz/dartz.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:games_app/core/error/failures.dart';
import 'package:games_app/features/auth/domain/repositories/auth_repository.dart';
import 'package:games_app/features/auth/domain/usecases/sign_out_usecase.dart';
import 'package:mockito/annotations.dart';
import 'package:mockito/mockito.dart';

import 'sign_out_usecase_test.mocks.dart';

/// Generate mocks: flutter pub run build_runner build
@GenerateMocks([AuthRepository])
void main() {
  late SignOutUseCase usecase;
  late MockAuthRepository mockRepository;

  setUp(() {
    mockRepository = MockAuthRepository();
    usecase = SignOutUseCase(mockRepository);
  });

  group('SignOutUseCase', () {
    test('should complete successfully when sign out succeeds', () async {
      // Arrange
      when(mockRepository.signOut())
          .thenAnswer((_) async => const Right(null));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Right(null));
      verify(mockRepository.signOut()).called(1);
      verifyNoMoreInteractions(mockRepository);
    });

    test('should return ServerFailure when sign out fails', () async {
      // Arrange
      const failure = ServerFailure('Failed to sign out');
      when(mockRepository.signOut())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
      verify(mockRepository.signOut()).called(1);
    });

    test('should return AuthFailure when authentication error occurs', () async {
      // Arrange
      const failure = AuthFailure('Authentication error');
      when(mockRepository.signOut())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
    });

    test('should return NetworkFailure when there is no internet', () async {
      // Arrange
      const failure = NetworkFailure('No internet connection');
      when(mockRepository.signOut())
          .thenAnswer((_) async => const Left(failure));

      // Act
      final result = await usecase();

      // Assert
      expect(result, const Left(failure));
    });
  });
}

