import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Type alias for Result type using dartz Either
/// Left = Failure, Right = Success
typedef Result<T> = Either<Failure, T>;

/// Extension methods for Result type to make it easier to use
extension ResultX<T> on Result<T> {
  bool get isSuccess => isRight();
  bool get isFailure => isLeft();
  T? get valueOrNull => fold((_) => null, (value) => value);
  Failure? get failureOrNull => fold((failure) => failure, (_) => null);
}

class ResultHelper {
  static Result<T> success<T>(T value) => Right(value);
  static Result<T> failure<T>(Failure failure) => Left(failure);
}

