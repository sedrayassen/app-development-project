import 'package:app_development_project/data/models/orders_result.dart';
import 'package:app_development_project/data/services/order_service.dart';
import 'package:app_development_project/data/models/order_model.dart';
import 'package:app_development_project/data/models/create_order_request.dart';

class OrderRepository {
  final OrderService service;

  OrderRepository(this.service);

  Future<OrdersResult> fetchOrders({
    int page = 1,
    int perPage = 10,
    String? status,
  }) {
    return service.getOrders(
      page: page,
      perPage: perPage,
      status: status,
    );
  }
    Future<OrderModel> fetchOrder(int id) {
    return service.getOrder(id);
  }

    Future<OrderModel> createOrder(CreateOrderRequest request) {
    return service.createOrder(request);
  }
}