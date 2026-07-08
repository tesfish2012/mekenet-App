class NotificationModel {
  final int id;
  final String title;
  final String description;
  final bool published;
  final bool isRead;
  final String? createdAt;

  const NotificationModel({
    required this.id,
    this.title = '',
    this.description = '',
    this.published = false,
    this.isRead = false,
    this.createdAt,
  });

  factory NotificationModel.fromJson(Map<String, dynamic> json) {
    return NotificationModel(
      id: json['id'] as int? ?? 0,
      title: json['title'] as String? ?? '',
      description: json['description'] as String? ?? '',
      published: json['published'] as bool? ?? false,
      isRead: json['isRead'] as bool? ?? false,
      createdAt: json['createdAt'] as String?,
    );
  }
}
