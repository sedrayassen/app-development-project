import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_development_project/cubit/order/orders_state.dart';
import 'package:app_development_project/data/models/order_model.dart';
import 'package:app_development_project/data/network/api_exception.dart';
import 'package:app_development_project/data/repository/order_repository.dart';

class OrdersCubit extends Cubit<OrdersState> {
  final OrderRepository repository;

  OrdersCubit(this.repository) : super(OrdersInitial());

  static const int _perPage = 10;

  int _page = 1;
  String? _status;
  List<OrderModel> _orders = [];
  int _total = 0;
  bool _hasMore = true;
  bool _isLoading = false;
  bool _loadMoreFailed = false;
  int _requestId = 0; 

  String? get status => _status;

  Future<void> load({String? status, bool refresh = true}) async {
    if (!refresh && (_isLoading || !_hasMore)) return;

    final requestId = ++_requestId;
    _isLoading = true;

    if (refresh) {
      _status = status;
      _page = 1;
      _orders = [];
      _total = 0;
      _hasMore = true;
      _loadMoreFailed = false;
      emit(OrdersLoading());
    } else {
      _loadMoreFailed = false;
      emit(OrdersLoadingMore(List.from(_orders)));
    }

    try {
      final result = await repository.fetchOrders(
        page: _page,
        perPage: _perPage,
        status: _status,
      );

      if (requestId != _requestId || isClosed) return;

      _orders = [..._orders, ...result.orders];
      _hasMore = result.hasMore;
      _total = result.total;
      _page++;

      if (_orders.isEmpty) {
        emit(OrdersEmpty(
          result.message ?? 'No orders found.',
          status: _status,
        ));
      } else {
        emit(OrdersLoaded(
          List.from(_orders),
          hasMore: _hasMore,
          total: _total,
        ));
      }
    } on ApiException catch (e) {
      if (requestId != _requestId || isClosed) return;
      _handleError(e.message, e.isUnauthorized, refresh);
    } catch (_) {
      if (requestId != _requestId || isClosed) return;
      _handleError('Unexpected error. Please try again.', false, refresh);
    } finally {
      if (requestId == _requestId) _isLoading = false;
    }
  }

  void _handleError(String message, bool unauthorized, bool wasRefresh) {
    if (unauthorized) {
      emit(OrdersUnauthorized(message));
      return;
    }
    if (wasRefresh || _orders.isEmpty) {
      emit(OrdersError(message));
      return;
    }
    _loadMoreFailed = true;
    emit(OrdersLoaded(
      List.from(_orders),
      hasMore: _hasMore,
      total: _total,
      loadMoreError: message,
    ));
  }

  Future<void> reload() => load(status: _status);

  Future<void> loadMore() async {
    if (_loadMoreFailed) return; 
    await load(refresh: false);
  }

  Future<void> retryLoadMore() async {
    _loadMoreFailed = false;
    await load(refresh: false);
  }
}