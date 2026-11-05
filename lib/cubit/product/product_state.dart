import 'package:app_development_project/data/models/product_model.dart';
//part of 'products_cubit.dart';

abstract class ProductsState {}

class ProductsInitial extends ProductsState {}

class ProductsLoading extends ProductsState {}

class ProductsLoadingMore extends ProductsState {
  final List<ProductModel> products;

  ProductsLoadingMore(this.products);
}

class ProductsLoaded extends ProductsState {
  final List<ProductModel> products;
  final bool hasMore;

  ProductsLoaded(this.products, {this.hasMore = true});
}

class ProductsError extends ProductsState {
  final String message;

  ProductsError(this.message);
}