import 'package:flutter_test/flutter_test.dart';
import 'package:safeinsurance_mobile/core/utils/date_formatter.dart';

void main() {
  group('AppFormatter', () {
    group('formatDate', () {
      test('formats a valid date', () {
        final date = DateTime(2024, 3, 15);
        expect(AppFormatter.formatDate(date), 'Mar 15, 2024');
      });

      test('returns em-dash for null', () {
        expect(AppFormatter.formatDate(null), '—');
      });
    });

    group('formatCurrency', () {
      test('formats currency with default symbol', () {
        expect(AppFormatter.formatCurrency(1000.0), 'ETB 1,000.00');
        expect(AppFormatter.formatCurrency(0), 'ETB 0.00');
      });

      test('formats currency with custom symbol', () {
        expect(AppFormatter.formatCurrency(500.0, symbol: r'$'), r'$ 500.00');
      });

      test('returns zero for null', () {
        expect(AppFormatter.formatCurrency(null), 'ETB 0.00');
      });
    });

    group('parseDate', () {
      test('parses ISO date string', () {
        final date = AppFormatter.parseDate('2024-03-15');
        expect(date, isNotNull);
        expect(date!.year, 2024);
        expect(date.month, 3);
        expect(date.day, 15);
      });

      test('returns null for invalid string', () {
        expect(AppFormatter.parseDate(null), isNull);
        expect(AppFormatter.parseDate(''), isNull);
        expect(AppFormatter.parseDate('not-a-date'), isNull);
      });
    });

    group('formatFileSize', () {
      test('formats bytes', () {
        expect(AppFormatter.formatFileSize(512), '512 B');
      });

      test('formats kilobytes', () {
        expect(AppFormatter.formatFileSize(1024), '1.0 KB');
        expect(AppFormatter.formatFileSize(2048), '2.0 KB');
      });

      test('formats megabytes', () {
        expect(AppFormatter.formatFileSize(1048576), '1.0 MB');
      });
    });

    group('toApiDate', () {
      test('converts date to API format', () {
        final date = DateTime(2024, 3, 15);
        expect(AppFormatter.toApiDate(date), '2024-03-15');
      });
    });
  });
}
