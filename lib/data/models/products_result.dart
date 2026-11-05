import 'product_model.dart';

class ProductsResult {
  final List<ProductModel> items;
  final bool hasMore;
  final int currentPage;
  final int lastPage;
  final int total;

  ProductsResult({
    required this.items,
    required this.hasMore,
    this.currentPage = 1,
    this.lastPage = 1,
    this.total = 0,
  });
}