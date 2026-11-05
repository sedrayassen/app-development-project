import 'package:dio/dio.dart';

import 'package:app_development_project/constants/api_constants.dart';
import 'package:app_development_project/data/models/notification_model.dart';
import 'package:app_development_project/data/network/api_exception.dart';

class NotificationService {
  final Dio dio;

  NotificationService(this.dio);

  Future<NotificationsResult> getNotifications({
    int page = 1,
    int perPage = 20,
  }) async {
    try {
      final response = await dio.get(
        ApiConstants.notifications,
        queryParameters: {
          'page': page,
          'per_page': perPage,
        },
      );

      final root = response.data;
      if (root is! Map) {
        throw ApiException('Unexpected response from server.');
      }

      final code =
          (root['code'] as num?)?.toInt() ?? response.statusCode ?? 200;
      if (code >= 400) {
        throw ApiException.fromResponse(code, Map<String, dynamic>.from(root));
      }

      final data = root['data'];
      List listJson = [];
      bool hasMore = false;
      int currentPage = page;
      int lastPage = 1;
      int total = 0;

      if (data is Map) {
        listJson = (data['notifications'] as List?) ?? [];
        final pagination = data['pagination'] as Map<String, dynamic>?;
        if (pagination != null) {
          currentPage = (pagination['current_page'] as num?)?.toInt() ?? page;
          lastPage = (pagination['last_page'] as num?)?.toInt() ?? 1;
          total = (pagination['total'] as num?)?.toInt() ?? listJson.length;
          hasMore = currentPage < lastPage || pagination['next_page_url'] != null;
        } else {
          hasMore = listJson.length >= perPage;
        }
      }

      final items = listJson
          .map((e) => AppNotificationModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ))
          .toList();

      return NotificationsResult(
        items: items,
        hasMore: hasMore,
        currentPage: currentPage,
        lastPage: lastPage,
        total: total,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (_) {
      throw ApiException('Unexpected response format.');
    }
  }
}