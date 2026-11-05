// import 'package:dio/dio.dart';

// import 'package:app_development_project/constants/api_constants.dart';
// import 'package:app_development_project/data/models/product_model.dart';
// import 'package:app_development_project/data/models/products_result.dart';
// import 'package:app_development_project/data/models/product_detail_model.dart';
// import 'package:app_development_project/data/network/api_exception.dart';

// class ProductService {
//   final Dio dio;

//   ProductService(this.dio);

//   Future<ProductsResult> getProducts({
//     int page = 1,
//     int perPage = 10,
//     String? search,
//     double? minPrice,
//     double? maxPrice,
//     String? sort,
//     String? direction,
//     bool includeInactive = false,
//     int? categoryId,
//   }) async {
//     final query = <String, dynamic>{
//       'page': page,
//       'per_page': perPage,
//       if (search != null && search.isNotEmpty) 'search': search,
//       if (minPrice != null) 'min_price': minPrice,
//       if (maxPrice != null) 'max_price': maxPrice,
//       if (sort != null && sort.isNotEmpty) 'sort': sort,
//       if (direction != null && direction.isNotEmpty) 'direction': direction,
//       if (includeInactive) 'include_inactive': true,
//       // مو موثّق بالـ Postman — إذا الباك ما فلتر حسب صنف احذف السطر
//       if (categoryId != null) 'category_id': categoryId,
//     };

//     final response = await dio.get(
//       ApiConstants.products,
//       queryParameters: query,
//     );

//     final root = response.data as Map<String, dynamic>? ?? {};
//     final data = root['data'];

//     List itemsJson = [];
//     bool hasMore = false;
//     int currentPage = page;
//     int lastPage = 1;
//     int total = 0;

//     if (data is Map) {
//       itemsJson = (data['items'] as List?) ?? [];
//       final pagination = data['pagination'] as Map<String, dynamic>?;

//       if (pagination != null) {
//         hasMore = pagination['has_more_pages'] == true;
//         currentPage =
//             (pagination['current_page'] as num?)?.toInt() ?? page;
//         lastPage = (pagination['last_page'] as num?)?.toInt() ?? 1;
//         total =
//             (pagination['total'] as num?)?.toInt() ?? itemsJson.length;
//       } else {
//         hasMore = itemsJson.length >= perPage;
//       }
//     } else if (data is List) {
//       itemsJson = data;
//       hasMore = itemsJson.length >= perPage;
//     }

//     final items = itemsJson
//         .map(
//           (e) => ProductModel.fromJson(
//             Map<String, dynamic>.from(e as Map),
//           ),
//         )
//         .toList();

//     return ProductsResult(
//       items: items,
//       hasMore: hasMore,
//       currentPage: currentPage,
//       lastPage: lastPage,
//       total: total,
//     );
//   }
//   //   Future<ProductDetailModel> getProduct(int id) async {
//   //   try {
//   //     final response = await dio.get(ApiConstants.productDetails(id));
//   //     final root = response.data;

//   //     if (root is! Map) {
//   //       throw ApiException('Unexpected response from server.');
//   //     }

//   //     final code =
//   //         (root['code'] as num?)?.toInt() ?? response.statusCode ?? 200;
//   //     final message = root['message']?.toString();
//   //     final data = root['data'];

//   //     if (code == 404 || data == null) {
//   //       throw ApiException(message ?? 'Product not found.', statusCode: 404);
//   //     }
//   //     if (code >= 400) {
//   //       throw ApiException(message ?? 'Request failed.', statusCode: code);
//   //     }
//   //     if (data is! Map) {
//   //       throw ApiException('Unexpected response from server.');
//   //     }

//   //     return ProductDetailModel.fromJson(Map<String, dynamic>.from(data));
//   //   } on DioException catch (e) {
//   //     throw ApiException.fromDio(e);
//   //   }
//   // }

//   Future<ProductsResult> getProduct({
//   int page = 1,
//   int perPage = 10,
//   String? search,
//   double? minPrice,
//   double? maxPrice,
//   String? sort,
//   String? direction,
//   bool includeInactive = false,
//   int? categoryId,
// }) async {
//   try {
//     final query = <String, dynamic>{
//       'page': page,
//       'per_page': perPage,
//       if (search != null && search.isNotEmpty) 'search': search,
//       if (minPrice != null) 'min_price': minPrice,
//       if (maxPrice != null) 'max_price': maxPrice,
//       if (sort != null && sort.isNotEmpty) 'sort': sort,
//       if (direction != null && direction.isNotEmpty) 'direction': direction,
//       if (includeInactive) 'include_inactive': true,
//       if (categoryId != null) 'category_id': categoryId,
//     };

//     final response = await dio.get(
//       ApiConstants.products,
//       queryParameters: query,
//     );

//     final root = response.data;
//     if (root is! Map) {
//       throw ApiException('Unexpected response from server.');
//     }

//     final code =
//         (root['code'] as num?)?.toInt() ?? response.statusCode ?? 200;
//     if (code >= 400) {
//       throw ApiException.fromResponse(code, root);
//     }

//     final data = root['data'];
//     List itemsJson = [];
//     bool hasMore = false;
//     int currentPage = page;
//     int lastPage = 1;
//     int total = 0;

//     if (data is Map) {
//       itemsJson = (data['items'] as List?) ?? [];
//       final pagination = data['pagination'] as Map<String, dynamic>?;
//       if (pagination != null) {
//         hasMore = pagination['has_more_pages'] == true;
//         currentPage = (pagination['current_page'] as num?)?.toInt() ?? page;
//         lastPage = (pagination['last_page'] as num?)?.toInt() ?? 1;
//         total = (pagination['total'] as num?)?.toInt() ?? itemsJson.length;
//       } else {
//         hasMore = itemsJson.length >= perPage;
//       }
//     } else if (data is List) {
//       itemsJson = data;
//       hasMore = itemsJson.length >= perPage;
//     }

//     final items = itemsJson
//         .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
//         .toList();

//     return ProductsResult(
//       items: items,
//       hasMore: hasMore,
//       currentPage: currentPage,
//       lastPage: lastPage,
//       total: total,
//     );
//   } on ApiException {
//     rethrow;
//   } on DioException catch (e) {
//     throw ApiException.fromDio(e);
//   } catch (_) {
//     throw ApiException('Unexpected response format.');
//   }
// }
// }
import 'package:dio/dio.dart';

import 'package:app_development_project/constants/api_constants.dart';
import 'package:app_development_project/data/models/product_model.dart';
import 'package:app_development_project/data/models/products_result.dart';
import 'package:app_development_project/data/models/product_detail_model.dart';
import 'package:app_development_project/data/network/api_exception.dart';

class ProductService {
  final Dio dio;

  ProductService(this.dio);

  /// قائمة المنتجات (index)
  Future<ProductsResult> getProducts({
    int page = 1,
    int perPage = 10,
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sort,
    String? direction,
    bool includeInactive = false,
    int? categoryId,
  }) async {
    try {
      final query = <String, dynamic>{
        'page': page,
        'per_page': perPage,
        if (search != null && search.isNotEmpty) 'search': search,
        if (minPrice != null) 'min_price': minPrice,
        if (maxPrice != null) 'max_price': maxPrice,
        if (sort != null && sort.isNotEmpty) 'sort': sort,
        if (direction != null && direction.isNotEmpty) 'direction': direction,
        if (includeInactive) 'include_inactive': true,
        if (categoryId != null) 'category_id': categoryId,
      };

      final response = await dio.get(
        ApiConstants.products,
        queryParameters: query,
      );

      final root = response.data;
      if (root is! Map) {
        throw ApiException('Unexpected response from server.');
      }

      final code =
          (root['code'] as num?)?.toInt() ?? response.statusCode ?? 200;
      if (code >= 400) {
        throw ApiException.fromResponse(code, Map<String, dynamic>.from(root));
      }

      final data = root['data'];
      List itemsJson = [];
      bool hasMore = false;
      int currentPage = page;
      int lastPage = 1;
      int total = 0;

      if (data is Map) {
        itemsJson = (data['items'] as List?) ?? [];
        final pagination = data['pagination'] as Map<String, dynamic>?;
        if (pagination != null) {
          hasMore = pagination['has_more_pages'] == true;
          currentPage = (pagination['current_page'] as num?)?.toInt() ?? page;
          lastPage = (pagination['last_page'] as num?)?.toInt() ?? 1;
          total = (pagination['total'] as num?)?.toInt() ?? itemsJson.length;
        } else {
          hasMore = itemsJson.length >= perPage;
        }
      } else if (data is List) {
        itemsJson = data;
        hasMore = itemsJson.length >= perPage;
      }

      final items = itemsJson
          .map((e) => ProductModel.fromJson(Map<String, dynamic>.from(e as Map)))
          .toList();

      return ProductsResult(
        items: items,
        hasMore: hasMore,
        currentPage: currentPage,
        lastPage: lastPage,
        total: total,
      );
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (_) {
      throw ApiException('Unexpected response format.');
    }
  }

  /// تفاصيل منتج واحد (show)
  Future<ProductDetailModel> getProduct(int id) async {
    try {
      final response = await dio.get(ApiConstants.productDetails(id));
      final root = response.data;

      if (root is! Map) {
        throw ApiException('Unexpected response from server.');
      }

      final code =
          (root['code'] as num?)?.toInt() ?? response.statusCode ?? 200;
      final message = root['message']?.toString();
      final data = root['data'];

      if (code == 404 || data == null) {
        throw ApiException(message ?? 'Product not found.', statusCode: 404);
      }
      if (code >= 400) {
        throw ApiException.fromResponse(code, Map<String, dynamic>.from(root));
      }
      if (data is! Map) {
        throw ApiException('Unexpected response from server.');
      }

      return ProductDetailModel.fromJson(Map<String, dynamic>.from(data));
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      throw ApiException.fromDio(e);
    } catch (_) {
      throw ApiException('Unexpected response format.');
    }
  }
}
