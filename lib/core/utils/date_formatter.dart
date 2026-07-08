import 'package:intl/intl.dart';

/// Date and number formatting helpers
class AppFormatter {
  AppFormatter._();

  static final _dateFormat = DateFormat('MMM d, yyyy');
  static final _shortDateFormat = DateFormat('dd/MM/yyyy');
  static final _dateTimeFormat = DateFormat('MMM d, yyyy • h:mm a');
  static final _monthYearFormat = DateFormat('MMMM yyyy');
  static final _apiDateFormat = DateFormat('yyyy-MM-dd');

  // ── Dates ─────────────────────────────────────────────────

  static String formatDate(DateTime? date) {
    if (date == null) return '—';
    return _dateFormat.format(date);
  }

  static String formatShortDate(DateTime? date) {
    if (date == null) return '—';
    return _shortDateFormat.format(date);
  }

  static String formatDateTime(DateTime? date) {
    if (date == null) return '—';
    return _dateTimeFormat.format(date);
  }

  static String formatMonthYear(DateTime? date) {
    if (date == null) return '—';
    return _monthYearFormat.format(date);
  }

  static String toApiDate(DateTime date) => _apiDateFormat.format(date);

  static DateTime? parseDate(String? value) {
    if (value == null || value.isEmpty) return null;
    try {
      return DateTime.parse(value);
    } catch (_) {
      return null;
    }
  }

  static String timeAgo(DateTime date) {
    final now = DateTime.now();
    final diff = now.difference(date);
    if (diff.inDays > 365) return '${(diff.inDays / 365).floor()}y ago';
    if (diff.inDays > 30) return '${(diff.inDays / 30).floor()}mo ago';
    if (diff.inDays > 0) return '${diff.inDays}d ago';
    if (diff.inHours > 0) return '${diff.inHours}h ago';
    if (diff.inMinutes > 0) return '${diff.inMinutes}m ago';
    return 'Just now';
  }

  // ── Currency ─────────────────────────────────────────────

  static String formatCurrency(double? amount, {String symbol = 'ETB'}) {
    if (amount == null) return '$symbol 0.00';
    final formatter = NumberFormat('#,##0.00', 'en_US');
    return '$symbol ${formatter.format(amount)}';
  }

  static String formatNumber(num? value) {
    if (value == null) return '0';
    return NumberFormat('#,##0', 'en_US').format(value);
  }

  static String formatFileSize(int bytes) {
    if (bytes < 1024) return '$bytes B';
    if (bytes < 1048576) return '${(bytes / 1024).toStringAsFixed(1)} KB';
    return '${(bytes / 1048576).toStringAsFixed(1)} MB';
  }
}
