import 'package:app_development_project/data/models/notification_model.dart';

abstract class NotificationsState {}

class NotificationsInitial extends NotificationsState {}

class NotificationsLoading extends NotificationsState {}

class NotificationsLoadingMore extends NotificationsState {
  final List<AppNotificationModel> notifications;
  NotificationsLoadingMore(this.notifications);
}

class NotificationsLoaded extends NotificationsState {
  final List<AppNotificationModel> notifications;
  final bool hasMore;
  NotificationsLoaded(this.notifications, {this.hasMore = true});
}

class NotificationsEmpty extends NotificationsState {
  final String message;
  NotificationsEmpty([this.message = 'No notifications yet.']);
}

class NotificationsUnauthorized extends NotificationsState {
  final String message;
  NotificationsUnauthorized(this.message);
}

class NotificationsError extends NotificationsState {
  final String message;
  NotificationsError(this.message);
}