import 'package:freezed_annotation/freezed_annotation.dart';

part 'api_response.freezed.dart';
part 'api_response.g.dart';

/// Standard API envelope: { success, message, data }
@freezed
class ApiResponse<T> with _$ApiResponse<T> {
  const factory ApiResponse({
    @Default(true) bool success,
    @Default('') String message,
    T? data,
  }) = _ApiResponse<T>;

  factory ApiResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$ApiResponseFromJson(json, fromJsonT);
}

/// Paginated list envelope
@freezed
class PagedResponse<T> with _$PagedResponse<T> {
  const factory PagedResponse({
    @Default([]) List<T> content,
    @Default(0) int page,
    @Default(20) int size,
    @Default(0) int totalElements,
    @Default(0) int totalPages,
  }) = _PagedResponse<T>;

  factory PagedResponse.fromJson(
    Map<String, dynamic> json,
    T Function(Object? json) fromJsonT,
  ) =>
      _$PagedResponseFromJson(json, fromJsonT);
}
