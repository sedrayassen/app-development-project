import 'package:dio/dio.dart';

import 'package:app_development_project/constants/api_constants.dart';
import 'package:app_development_project/data/models/order_model.dart';
import 'package:app_development_project/data/models/orders_result.dart';
import 'package:app_development_project/data/network/api_exception.dart';
import 'package:app_development_project/data/network/app_logger.dart';
import 'package:app_development_project/data/models/create_order_request.dart';

class OrderService {
  final Dio dio;

  OrderService(this.dio);


  Future<OrdersResult> getOrders({
    int page = 1,
    int perPage = 10,
    String? status,
  }) async {
    const tag = 'OrderService.getOrders';

    final query = <String, dynamic>{
      'page': page,
      'per_page': perPage,
      if (status != null && status.isNotEmpty) 'status': status,
    };

    try {
      AppLogger.request(tag, 'GET', ApiConstants.orders, query: query);

      final response = await dio.get(
        ApiConstants.orders,
        queryParameters: query,
      );

      AppLogger.response(tag, response.statusCode, response.data);

      final root = response.data;
      if (root is! Map) {
        throw ApiException('Unexpected response from server.');
      }

      final code =
          (root['code'] as num?)?.toInt() ?? response.statusCode ?? 200;
      final message = root['message']?.toString();
      final data = root['data'];

      if (code == 401) {
        throw ApiException(message ?? 'Unauthenticated.', statusCode: 401);
      }
      if (code >= 400) {
        throw ApiException(message ?? 'Request failed.', statusCode: code);
      }

      List ordersJson = [];
      bool hasMore = false;
      int currentPage = page;
      int lastPage = 1;
      int perPageRes = perPage;
      int total = 0;

      if (data is List) {
        ordersJson = data;
        total = data.length;
      } else if (data is Map) {
        ordersJson = (data['orders'] as List?) ?? [];

        final pagination = data['pagination'];
        if (pagination is Map) {
          currentPage = (pagination['current_page'] as num?)?.toInt() ?? page;
          lastPage = (pagination['last_page'] as num?)?.toInt() ?? 1;
          perPageRes = (pagination['per_page'] as num?)?.toInt() ?? perPage;
          total = (pagination['total'] as num?)?.toInt() ?? ordersJson.length;
          hasMore = pagination['has_more'] == true ||
              (pagination['has_more'] == null && currentPage < lastPage);
        } else {
          hasMore = ordersJson.length >= perPage;
        }
      }

      final orders = ordersJson
          .whereType<Map>()
          .map((e) => OrderModel.fromJson(Map<String, dynamic>.from(e)))
          .toList();

      return OrdersResult(
        orders: orders,
        hasMore: hasMore,
        currentPage: currentPage,
        lastPage: lastPage,
        perPage: perPageRes,
        total: total,
        message: message,
      );
    } on ApiException catch (e) {
      AppLogger.error(tag, e);
      rethrow;
    } on DioException catch (e) {
      AppLogger.dio(tag, e);
      throw ApiException.fromDio(e);
    } catch (e, st) {
      AppLogger.error(tag, e, st);
      throw ApiException('Unexpected response format.');
    }
  }


  Future<OrderModel> getOrder(int id) async {
    const tag = 'OrderService.getOrder';
    final path = ApiConstants.orderDetails(id);

    try {
      AppLogger.request(tag, 'GET', path);

      final response = await dio.get(path);

      AppLogger.response(tag, response.statusCode, response.data);

      final root = response.data;
      if (root is! Map) {
        throw ApiException('Unexpected response from server.');
      }

      final code =
          (root['code'] as num?)?.toInt() ?? response.statusCode ?? 200;
      final message = root['message']?.toString();
      final data = root['data'];

      if (code == 401) {
        throw ApiException(message ?? 'Unauthenticated.', statusCode: 401);
      }
      if (code == 403) {
        throw ApiException(
          message ?? 'You are not authorized to perform this action.',
          statusCode: 403,
        );
      }
      if (code == 404 || data == null) {
        throw ApiException(message ?? 'Order not found.', statusCode: 404);
      }
      if (code >= 400) {
        throw ApiException(message ?? 'Request failed.', statusCode: code);
      }
      if (data is! Map) {
        throw ApiException('Unexpected response from server.');
      }

      final orderJson = data['order'] is Map ? data['order'] as Map : data;

      return OrderModel.fromJson(Map<String, dynamic>.from(orderJson));
    } on ApiException catch (e) {
      AppLogger.error(tag, e);
      rethrow;
    } on DioException catch (e) {
      AppLogger.dio(tag, e);
      throw ApiException.fromDio(e);
    } catch (e, st) {
      AppLogger.error(tag, e, st);
      throw ApiException('Unexpected response format.');
    }
  }

    // ───────────── create order ─────────────

  Future<OrderModel> createOrder(CreateOrderRequest request) async {
    const tag = 'OrderService.createOrder';
    final body = request.toJson();

    try {
      AppLogger.request(tag, 'POST', ApiConstants.createOrder, body: body);

      final response = await dio.post(ApiConstants.createOrder, data: body);

      AppLogger.response(tag, response.statusCode, response.data);

      final root = response.data;
      if (root is! Map) {
        throw ApiException('Unexpected response from server.');
      }

      final code =
          (root['code'] as num?)?.toInt() ?? response.statusCode ?? 201;

      // الباك ممكن يرجّع الكود بالـ body حتى لو الـ HTTP status 200
      if (code >= 400) {
        throw ApiException.fromResponse(code, root);
      }

      final data = root['data'];
      if (data is! Map) {
        throw ApiException(
          'Unexpected response format. Please check your orders list.',
          statusCode: code,
        );
      }

      final orderJson = data['order'] is Map ? data['order'] as Map : data;
      return OrderModel.fromJson(Map<String, dynamic>.from(orderJson));
    } on ApiException catch (e) {
      AppLogger.error(tag, e);
      rethrow;
    } on DioException catch (e) {
      AppLogger.dio(tag, e);
      throw ApiException.fromDio(e);
    } catch (e, st) {
      AppLogger.error(tag, e, st);
      throw ApiException(
        'Unexpected response format. Please check your orders list.',
      );
    }
  }
}