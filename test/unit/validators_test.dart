import 'package:flutter_test/flutter_test.dart';
import 'package:safeinsurance_mobile/core/utils/validators.dart';

void main() {
  group('Validators', () {
    group('email', () {
      test('returns null for valid email', () {
        expect(Validators.email('user@example.com'), isNull);
        expect(Validators.email('test.name+tag@domain.co'), isNull);
      });

      test('returns error for empty email', () {
        expect(Validators.email(''), isNotNull);
        expect(Validators.email(null), isNotNull);
      });

      test('returns error for invalid email', () {
        expect(Validators.email('notanemail'), isNotNull);
        expect(Validators.email('@missing.com'), isNotNull);
        expect(Validators.email('missing@'), isNotNull);
      });
    });

    group('password', () {
      test('returns null for valid password', () {
        expect(Validators.password('SecurePass123'), isNull);
        expect(Validators.password('12345678'), isNull);
      });

      test('returns error for short password', () {
        expect(Validators.password('1234567'), isNotNull);
        expect(Validators.password(''), isNotNull);
      });
    });

    group('confirmPassword', () {
      test('returns null when passwords match', () {
        expect(Validators.confirmPassword('password123', 'password123'), isNull);
      });

      test('returns error when passwords do not match', () {
        expect(Validators.confirmPassword('password123', 'different'), isNotNull);
      });
    });

    group('pin', () {
      test('returns null for valid 4-digit PIN', () {
        expect(Validators.pin('1234'), isNull);
        expect(Validators.pin('0000'), isNull);
      });

      test('returns error for invalid PIN', () {
        expect(Validators.pin('123'), isNotNull);
        expect(Validators.pin('12345'), isNotNull);
        expect(Validators.pin('abcd'), isNotNull);
        expect(Validators.pin(''), isNotNull);
      });
    });

    group('amount', () {
      test('returns null for valid amount', () {
        expect(Validators.amount('100'), isNull);
        expect(Validators.amount('9999.99'), isNull);
      });

      test('returns error for invalid amount', () {
        expect(Validators.amount('0'), isNotNull);
        expect(Validators.amount('-100'), isNotNull);
        expect(Validators.amount('abc'), isNotNull);
        expect(Validators.amount(''), isNotNull);
      });
    });
  });
}
