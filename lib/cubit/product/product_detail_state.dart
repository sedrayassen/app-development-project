import 'package:app_development_project/data/models/product_detail_model.dart';

abstract class ProductDetailState {}

class ProductDetailInitial extends ProductDetailState {}

class ProductDetailLoading extends ProductDetailState {}

class ProductDetailLoaded extends ProductDetailState {
  final ProductDetailModel product;
  ProductDetailLoaded(this.product);
}

class ProductDetailNotFound extends ProductDetailState {
  final String message;
  ProductDetailNotFound(this.message);
}

class ProductDetailUnauthorized extends ProductDetailState {
  final String message;
  ProductDetailUnauthorized(this.message);
}

class ProductDetailError extends ProductDetailState {
  final String message;
  ProductDetailError(this.message);
}