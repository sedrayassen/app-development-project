import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_development_project/cubit/notification/notification_state.dart';
import 'package:app_development_project/data/models/notification_model.dart';
import 'package:app_development_project/data/network/api_exception.dart';
import 'package:app_development_project/data/repository/notification_repository.dart';

class NotificationsCubit extends Cubit<NotificationsState> {
  final NotificationRepository repository;

  NotificationsCubit(this.repository) : super(NotificationsInitial());

  int _page = 1;
  final int _perPage = 20;
  List<AppNotificationModel> _items = [];
  bool _hasMore = true;
  bool _isLoading = false;

  Future<void> load({bool refresh = true}) async {
    if (_isLoading) return;
    _isLoading = true;

    if (refresh) {
      _page = 1;
      _items = [];
      _hasMore = true;
      emit(NotificationsLoading());
    } else {
      if (!_hasMore) {
        _isLoading = false;
        return;
      }
      emit(NotificationsLoadingMore(List.from(_items)));
    }

    try {
      final result = await repository.fetchNotifications(
        page: _page,
        perPage: _perPage,
      );

      _items = [..._items, ...result.items];
      _hasMore = result.hasMore;
      _page++;

      if (_items.isEmpty) {
        emit(NotificationsEmpty());
      } else {
        emit(NotificationsLoaded(List.from(_items), hasMore: _hasMore));
      }
    } on ApiException catch (e) {
      if (e.isUnauthorized) {
        emit(NotificationsUnauthorized(e.message));
      } else if (refresh || _items.isEmpty) {
        emit(NotificationsError(e.message));
      } else {
        emit(NotificationsLoaded(List.from(_items), hasMore: _hasMore));
      }
    } catch (_) {
      if (refresh || _items.isEmpty) {
        emit(NotificationsError('Something went wrong. Please try again.'));
      } else {
        emit(NotificationsLoaded(List.from(_items), hasMore: _hasMore));
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    await load(refresh: false);
  }

  Future<void> reload() => load(refresh: true);
}