class AppNotificationModel {
  final int id;
  final String type;
  final String title;
  final String body;
  final Map<String, dynamic>? payload;
  final String? readAt;
  final String? createdAt;

  AppNotificationModel({
    required this.id,
    required this.type,
    required this.title,
    required this.body,
    this.payload,
    this.readAt,
    this.createdAt,
  });

  bool get isRead => readAt != null && readAt!.isNotEmpty;

  int? get orderId {
    final v = payload?['order_id'];
    if (v is int) return v;
    return int.tryParse('$v');
  }

  factory AppNotificationModel.fromJson(Map<String, dynamic> json) {
    return AppNotificationModel(
      id: json['id'] is int ? json['id'] as int : int.tryParse('${json['id']}') ?? 0,
      type: json['type']?.toString() ?? '',
      title: json['title']?.toString() ?? '',
      body: json['body']?.toString() ?? '',
      payload: json['payload'] is Map
          ? Map<String, dynamic>.from(json['payload'] as Map)
          : null,
      readAt: json['read_at']?.toString(),
      createdAt: json['created_at']?.toString(),
    );
  }
}

class NotificationsResult {
  final List<AppNotificationModel> items;
  final bool hasMore;
  final int currentPage;
  final int lastPage;
  final int total;

  NotificationsResult({
    required this.items,
    required this.hasMore,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });
}