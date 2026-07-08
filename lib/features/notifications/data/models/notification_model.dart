import 'package:freezed_annotation/freezed_annotation.dart';

part 'notification_model.freezed.dart';
part 'notification_model.g.dart';

/// Maps to the notice_boards table returned by /api/portal/notices
@freezed
class NotificationModel with _$NotificationModel {
  const factory NotificationModel({
    required int id,
    @Default('') String title,
    @Default('') String description,
    @Default(false) bool published,
    @Default(false) bool isRead,
    String? createdAt,
  }) = _NotificationModel;

  factory NotificationModel.fromJson(Map<String, dynamic> json) =>
      _$NotificationModelFromJson(json);
}
