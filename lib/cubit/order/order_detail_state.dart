import 'package:app_development_project/data/models/order_model.dart';

abstract class OrderDetailState {}

class OrderDetailInitial extends OrderDetailState {}

class OrderDetailLoading extends OrderDetailState {}

class OrderDetailLoaded extends OrderDetailState {
  final OrderModel order;
  OrderDetailLoaded(this.order);
}

class OrderDetailNotFound extends OrderDetailState {
  final String message;
  OrderDetailNotFound(this.message);
}

class OrderDetailForbidden extends OrderDetailState {
  final String message;
  OrderDetailForbidden(this.message);
}

class OrderDetailUnauthorized extends OrderDetailState {
  final String message;
  OrderDetailUnauthorized(this.message);
}

class OrderDetailError extends OrderDetailState {
  final String message;
  OrderDetailError(this.message);
}