import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_development_project/cubit/order/order_detail_state.dart';
import 'package:app_development_project/data/network/api_exception.dart';
import 'package:app_development_project/data/network/app_logger.dart';
import 'package:app_development_project/data/repository/order_repository.dart';

class OrderDetailCubit extends Cubit<OrderDetailState> {
  final OrderRepository repository;

  OrderDetailCubit(this.repository) : super(OrderDetailInitial());

  static const _tag = 'OrderDetailCubit';

  int? _orderId;
  int _requestId = 0;

  Future<void> load(int id) async {
    _orderId = id;
    final requestId = ++_requestId;
    emit(OrderDetailLoading());

    try {
      final order = await repository.fetchOrder(id);
      if (requestId != _requestId || isClosed) return;
      emit(OrderDetailLoaded(order));
    } on ApiException catch (e, st) {
      AppLogger.error('$_tag.load($id) status=${e.statusCode}', e, st);
      if (requestId != _requestId || isClosed) return;

      if (e.isUnauthorized) {
        emit(OrderDetailUnauthorized(e.message));
      } else if (e.isForbidden) {
        emit(OrderDetailForbidden(e.message));
      } else if (e.isNotFound) {
        emit(OrderDetailNotFound(e.message));
      } else {
        emit(OrderDetailError(e.message));
      }
    } catch (e, st) {
      AppLogger.error('$_tag.load($id) unexpected', e, st);
      if (requestId != _requestId || isClosed) return;
      emit(OrderDetailError('Unexpected error. Please try again.'));
    }
  }

  Future<void> retry() async {
    final id = _orderId;
    if (id != null) await load(id);
  }
}