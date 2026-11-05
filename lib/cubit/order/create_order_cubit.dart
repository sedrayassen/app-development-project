import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_development_project/cubit/order/create_order_state.dart';
import 'package:app_development_project/data/models/create_order_request.dart';
import 'package:app_development_project/data/network/api_exception.dart';
import 'package:app_development_project/data/network/app_logger.dart';
import 'package:app_development_project/data/repository/order_repository.dart';

class CreateOrderCubit extends Cubit<CreateOrderState> {
  final OrderRepository repository;

  CreateOrderCubit(this.repository) : super(CreateOrderInitial());

  static const _tag = 'CreateOrderCubit';

  bool _submitting = false;

  Future<void> submit(List<CreateOrderItem> items) async {
    if (_submitting) return;

    if (items.isEmpty) {
      emit(CreateOrderValidationError('Please select at least one product.'));
      return;
    }
    if (items.any((i) => i.quantity < 1)) {
      emit(CreateOrderValidationError('Quantity must be at least 1.'));
      return;
    }

    _submitting = true;
    emit(CreateOrderSubmitting());

    try {
      final order = await repository.createOrder(CreateOrderRequest(items));
      if (isClosed) return;
      emit(CreateOrderSuccess(order));
    } on ApiException catch (e, st) {
      AppLogger.error('$_tag.submit status=${e.statusCode}', e, st);
      if (isClosed) return;
      emit(_mapError(e));
    } catch (e, st) {
      AppLogger.error('$_tag.submit unexpected', e, st);
      if (isClosed) return;
      emit(CreateOrderError('Unexpected error. Please try again.'));
    } finally {
      _submitting = false;
    }
  }

  CreateOrderState _mapError(ApiException e) {
    if (e.isUnauthorized) return CreateOrderUnauthorized(e.message);
    if (e.isForbidden) return CreateOrderForbidden(e.message);
    if (e.isConflict) return CreateOrderConflict(e.message);
    if (e.isValidation) {
      return CreateOrderValidationError(
        e.message,
        fieldErrors: e.fieldErrors,
      );
    }
    if (e.isNetwork || e.isServiceUnavailable) {
      return CreateOrderUnavailable(e.message);
    }
    if (e.isServerError) return CreateOrderServerError(e.message);
    return CreateOrderError(e.message);
  }
}