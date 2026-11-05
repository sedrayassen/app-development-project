import 'package:app_development_project/data/models/order_model.dart';

abstract class OrdersState {}

class OrdersInitial extends OrdersState {}

class OrdersLoading extends OrdersState {}

class OrdersLoadingMore extends OrdersState {
  final List<OrderModel> orders;
  OrdersLoadingMore(this.orders);
}

class OrdersLoaded extends OrdersState {
  final List<OrderModel> orders;
  final bool hasMore;
  final int total;

  final String? loadMoreError;

  OrdersLoaded(
    this.orders, {
    this.hasMore = false,
    this.total = 0,
    this.loadMoreError,
  });
}

class OrdersEmpty extends OrdersState {
  final String message;
  final String? status;
  OrdersEmpty(this.message, {this.status});
}

class OrdersUnauthorized extends OrdersState {
  final String message;
  OrdersUnauthorized(this.message);
}

class OrdersError extends OrdersState {
  final String message;
  OrdersError(this.message);
}