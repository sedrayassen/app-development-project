import 'order_model.dart';

class OrdersResult {
  final List<OrderModel> orders;
  final bool hasMore;
  final int currentPage;
  final int lastPage;
  final int perPage;
  final int total;
  final String? message;

  OrdersResult({
    required this.orders,
    required this.hasMore,
    this.currentPage = 1,
    this.lastPage = 1,
    this.perPage = 10,
    this.total = 0,
    this.message,
  });
}