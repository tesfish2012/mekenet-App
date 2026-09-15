import 'package:flutter_test/flutter_test.dart';
import 'package:mekenetinsurance_mobile/core/error/exceptions.dart';
import 'package:mekenetinsurance_mobile/core/error/failures.dart';
import 'package:mekenetinsurance_mobile/core/utils/failure_mapper.dart';

void main() {
  group('Failure types', () {
    test('NetworkFailure has correct properties', () {
      const f = NetworkFailure();
      expect(f.message, 'No internet connection');
      expect(f.statusCode, isNull);
    });

    test('UnauthorizedFailure has status 401', () {
      const f = UnauthorizedFailure();
      expect(f.statusCode, 401);
    });

    test('ServerFailure holds message and code', () {
      const f = ServerFailure(message: 'Server error', statusCode: 500);
      expect(f.message, 'Server error');
      expect(f.statusCode, 500);
    });

    test('ValidationFailure has status 422', () {
      const f = ValidationFailure(message: 'Invalid input');
      expect(f.statusCode, 422);
    });
  });

  group('mapExceptionToFailure', () {
    test('maps NetworkException to NetworkFailure', () {
      final result = mapExceptionToFailure(
        const NetworkException(message: 'No connection'),
      );
      expect(result, isA<NetworkFailure>());
    });

    test('maps UnauthorizedException to UnauthorizedFailure', () {
      final result = mapExceptionToFailure(
        const UnauthorizedException(message: 'Unauthorized'),
      );
      expect(result, isA<UnauthorizedFailure>());
    });

    test('maps TimeoutException to TimeoutFailure', () {
      final result = mapExceptionToFailure(
        const TimeoutException(message: 'Timed out'),
      );
      expect(result, isA<TimeoutFailure>());
    });

    test('maps ServerException(401) to UnauthorizedFailure', () {
      final result = mapExceptionToFailure(
        const ServerException(message: 'Unauthorized', statusCode: 401),
      );
      expect(result, isA<UnauthorizedFailure>());
    });

    test('maps ServerException(500) to ServerFailure', () {
      final result = mapExceptionToFailure(
        const ServerException(message: 'Server error', statusCode: 500),
      );
      expect(result, isA<ServerFailure>());
    });

    test('maps unknown exception to UnknownFailure', () {
      final result = mapExceptionToFailure(Exception('Unknown'));
      expect(result, isA<UnknownFailure>());
    });
  });
}
