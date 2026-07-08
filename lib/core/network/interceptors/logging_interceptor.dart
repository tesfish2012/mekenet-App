import 'dart:developer' as developer;

import 'package:dio/dio.dart';

/// Always-on HTTP logger — prints full request/response detail to the
/// Flutter/Dart developer console (visible in VS Code / Android Studio).
///
/// Uses dart:developer log() so output is structured and filterable.
class LoggingInterceptor extends Interceptor {
  static const String _tag = 'SafeInsurance.HTTP';

  // ── Request ───────────────────────────────────────────────

  @override
  void onRequest(RequestOptions options, RequestInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('┌─────────────────────────────────────────────────')
      ..writeln('│ 🌐 REQUEST')
      ..writeln('│ ${options.method.padRight(6)} ${options.uri}')
      ..writeln('│ Content-Type : ${options.contentType}')
      ..writeln('│ Headers      : ${_formatHeaders(options.headers)}');

    if (options.data != null) {
      buffer.writeln('│ Body         : ${_formatBody(options.data)}');
    }
    if (options.queryParameters.isNotEmpty) {
      buffer.writeln('│ Query        : ${options.queryParameters}');
    }
    buffer.writeln('└─────────────────────────────────────────────────');

    developer.log(buffer.toString(), name: _tag, level: 500);
    handler.next(options);
  }

  // ── Response ──────────────────────────────────────────────

  @override
  void onResponse(Response response, ResponseInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('┌─────────────────────────────────────────────────')
      ..writeln('│ ✅ RESPONSE')
      ..writeln('│ ${response.statusCode} ${response.statusMessage}')
      ..writeln('│ URL     : ${response.requestOptions.uri}')
      ..writeln('│ Headers : ${_formatHeaders(response.headers.map)}')
      ..writeln('│ Body    : ${_formatBody(response.data)}')
      ..writeln('└─────────────────────────────────────────────────');

    developer.log(buffer.toString(), name: _tag, level: 800);
    handler.next(response);
  }

  // ── Error ─────────────────────────────────────────────────

  @override
  void onError(DioException err, ErrorInterceptorHandler handler) {
    final buffer = StringBuffer()
      ..writeln('┌─────────────────────────────────────────────────')
      ..writeln('│ ❌ ERROR')
      ..writeln('│ Type    : ${err.type.name}')
      ..writeln('│ URL     : ${err.requestOptions.uri}')
      ..writeln('│ Message : ${err.message}');

    if (err.response != null) {
      buffer
        ..writeln('│ Status  : ${err.response!.statusCode} ${err.response!.statusMessage}')
        ..writeln('│ Body    : ${_formatBody(err.response!.data)}');
    }

    // Show the wrapped app exception if present
    if (err.error != null) {
      buffer.writeln('│ AppException : ${err.error.runtimeType} — ${err.error}');
    }

    buffer.writeln('└─────────────────────────────────────────────────');

    developer.log(buffer.toString(), name: _tag, level: 1000, error: err.error);
    handler.next(err);
  }

  // ── Helpers ───────────────────────────────────────────────

  String _formatHeaders(Map<String, dynamic> headers) {
    final filtered = Map<String, dynamic>.from(headers)
      ..remove('Authorization'); // never log tokens
    return filtered.isEmpty ? '{}' : filtered.toString();
  }

  String _formatBody(dynamic data) {
    if (data == null) return 'null';
    final str = data.toString();
    // Truncate very large bodies to avoid flooding the console
    return str.length > 2000 ? '${str.substring(0, 2000)}…[truncated]' : str;
  }
}
