import 'package:app_development_project/data/models/product_detail_model.dart';
import 'package:app_development_project/data/models/product_model.dart';
import 'package:app_development_project/data/models/products_result.dart';

class ProductsListCacheEntry {
  final String? etag;
  final ProductsResult result;

  ProductsListCacheEntry({required this.etag, required this.result});
}

class ProductDetailCacheEntry {
  final String? etag;
  final ProductDetailModel product;

  ProductDetailCacheEntry({required this.etag, required this.product});
}

class ProductsCache {
  final Map<String, ProductsListCacheEntry> listCache = {};

  final Map<int, ProductDetailCacheEntry> detailCache = {};

  String listKey({
    required int page,
    required int perPage,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sort,
    String? direction,
    bool includeInactive = false,
    int? categoryId,
  }) {
    return [
      'page=$page',
      'perPage=$perPage',
      'search=${search ?? ''}',
      'min=${minPrice ?? ''}',
      'max=${maxPrice ?? ''}',
      'sort=${sort ?? ''}',
      'dir=${direction ?? ''}',
      'inactive=$includeInactive',
      'cat=${categoryId ?? ''}',
    ].join('|');
  }

  ProductsListCacheEntry? getList(String key) => listCache[key];

  void saveList(String key, {required ProductsResult result, String? etag}) {
    listCache[key] = ProductsListCacheEntry(etag: etag, result: result);
  }

  ProductDetailCacheEntry? getDetail(int id) => detailCache[id];

  void saveDetail(int id, {required ProductDetailModel product, String? etag}) {
    detailCache[id] = ProductDetailCacheEntry(etag: etag, product: product);
  }

  void clear() {
    listCache.clear();
    detailCache.clear();
  }
}