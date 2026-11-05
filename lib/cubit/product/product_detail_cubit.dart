import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_development_project/cubit/product/product_detail_state.dart';
import 'package:app_development_project/data/network/api_exception.dart';
import 'package:app_development_project/data/repository/product_repository.dart';

class ProductDetailCubit extends Cubit<ProductDetailState> {
  final ProductRepository repository;

  ProductDetailCubit(this.repository) : super(ProductDetailInitial());

  int? _productId;
  int _requestId = 0;

  Future<void> load(int id) async {
    _productId = id;
    final requestId = ++_requestId;
    emit(ProductDetailLoading());

    try {
      final product = await repository.fetchProduct(id);
      if (requestId != _requestId || isClosed) return;
      emit(ProductDetailLoaded(product));
    } on ApiException catch (e) {
      if (requestId != _requestId || isClosed) return;
      if (e.isNotFound) {
        emit(ProductDetailNotFound(e.message));
      } else if (e.isUnauthorized) {
        emit(ProductDetailUnauthorized(e.message));
      } else {
        emit(ProductDetailError(e.message));
      }
    } catch (_) {
      if (requestId != _requestId || isClosed) return;
      emit(ProductDetailError('Unexpected error. Please try again.'));
    }
  }

  Future<void> retry() async {
    final id = _productId;
    if (id != null) await load(id);
  }
}