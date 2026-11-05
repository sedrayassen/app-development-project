import 'package:app_development_project/data/models/notification_model.dart';
import 'package:app_development_project/data/services/notification_service.dart';

class NotificationRepository {
  final NotificationService service;

  NotificationRepository(this.service);

  Future<NotificationsResult> fetchNotifications({
    int page = 1,
    int perPage = 20,
  }) {
    return service.getNotifications(page: page, perPage: perPage);
  }
}