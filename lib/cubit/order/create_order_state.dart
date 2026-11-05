import 'package:app_development_project/data/models/order_model.dart';

abstract class CreateOrderState {}

class CreateOrderInitial extends CreateOrderState {}

class CreateOrderSubmitting extends CreateOrderState {}

class CreateOrderSuccess extends CreateOrderState {
  final OrderModel order;
  CreateOrderSuccess(this.order);
}

abstract class CreateOrderFailure extends CreateOrderState {
  final String message;
  CreateOrderFailure(this.message);
}

class CreateOrderValidationError extends CreateOrderFailure {
  final Map<String, List<String>> fieldErrors;
  CreateOrderValidationError(super.message, {this.fieldErrors = const {}});
}

/// 403
class CreateOrderForbidden extends CreateOrderFailure {
  CreateOrderForbidden(super.message);
}

/// 409
class CreateOrderConflict extends CreateOrderFailure {
  CreateOrderConflict(super.message);
}

/// 401
class CreateOrderUnauthorized extends CreateOrderFailure {
  CreateOrderUnauthorized(super.message);
}

/// 503 
class CreateOrderUnavailable extends CreateOrderFailure {
  CreateOrderUnavailable(super.message);
}

/// 500 
class CreateOrderServerError extends CreateOrderFailure {
  CreateOrderServerError(super.message);
}

class CreateOrderError extends CreateOrderFailure {
  CreateOrderError(super.message);
}