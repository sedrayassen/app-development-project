import 'package:app_development_project/data/models/products_result.dart';
import 'package:app_development_project/data/services/product_service.dart';
import 'package:app_development_project/data/models/product_detail_model.dart';

class ProductRepository {
  final ProductService service;

  ProductRepository(this.service);

  Future<ProductsResult> fetchProducts({
    int page = 1,
    int perPage = 10,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sort,
    String? direction,
    int? categoryId,
  }) {
    return service.getProducts(
      page: page,
      perPage: perPage,
      search: search,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sort: sort,
      direction: direction,
      categoryId: categoryId,
    );
  }
    Future<ProductDetailModel> fetchProduct(int id) {
    return service.getProduct(id);
  }
}