import 'package:dartz/dartz.dart';
import '../error/failures.dart';

/// Type alias: Either<Failure, T>
/// Left = failure, Right = success
typedef Result<T> = Either<Failure, T>;

/// Convenience helpers
Result<T> success<T>(T value) => Right(value);
Result<T> failure<T>(Failure f) => Left(f);
