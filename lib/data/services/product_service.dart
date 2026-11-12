

import 'package:dio/dio.dart';

import 'package:app_development_project/constants/api_constants.dart';
import 'package:app_development_project/data/cache/products_cache.dart';
import 'package:app_development_project/data/models/product_detail_model.dart';
import 'package:app_development_project/data/models/product_model.dart';
import 'package:app_development_project/data/models/products_result.dart';
import 'package:app_development_project/data/network/api_exception.dart';
import 'package:app_development_project/data/network/app_logger.dart';

class ProductService {
  final Dio dio;
  final ProductsCache cache;

  ProductService(this.dio, this.cache);

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
    const tag = 'ProductService.getProducts';

    final key = cache.listKey(
      page: page,
      perPage: perPage,
      search: search,
      minPrice: minPrice,
      maxPrice: maxPrice,
      sort: sort,
      direction: direction,
      includeInactive: includeInactive,
      categoryId: categoryId,
    );

    final cached = cache.getList(key);

    try {
      final headers = <String, dynamic>{};
      if (cached?.etag != null && cached!.etag!.isNotEmpty) {
        headers['If-None-Match'] = cached.etag;
      }

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

      AppLogger.request(tag, 'GET', ApiConstants.products, query: {
        ...query,
        if (headers['If-None-Match'] != null)
          'If-None-Match': headers['If-None-Match'],
      });

      final response = await dio.get(
        ApiConstants.products,
        queryParameters: query,
        options: Options(
          headers: headers,
          validateStatus: (s) => s != null && s >= 200 && s < 400,
        ),
      );

      final responseEtag =
          response.headers.value('etag') ?? response.headers.value('ETag');

      if (response.statusCode == 304) {
        AppLogger.etag(
          tag,
          status: 304,
          requestIfNoneMatch: cached?.etag,
          responseEtag: responseEtag ?? cached?.etag,
          fromCache: true,
        );

        if (cached == null) {
          throw ApiException(
            'Cached products not available.',
            statusCode: 304,
          );
        }

        AppLogger.response(tag, 304, 'from local cache');
        return cached.result;
      }

      if (response.statusCode == 200) {
        AppLogger.etag(
          tag,
          status: 200,
          requestIfNoneMatch: headers['If-None-Match']?.toString(),
          responseEtag: responseEtag,
          fromCache: false,
        );

        final root = response.data;
        if (root is! Map) {
          throw ApiException('Unexpected response from server.');
        }

        final code =
            (root['code'] as num?)?.toInt() ?? response.statusCode ?? 200;
        if (code >= 400) {
          throw ApiException.fromResponse(
            code,
            Map<String, dynamic>.from(root),
          );
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
            currentPage =
                (pagination['current_page'] as num?)?.toInt() ?? page;
            lastPage = (pagination['last_page'] as num?)?.toInt() ?? 1;
            total =
                (pagination['total'] as num?)?.toInt() ?? itemsJson.length;
          } else {
            hasMore = itemsJson.length >= perPage;
          }
        } else if (data is List) {
          itemsJson = data;
          hasMore = itemsJson.length >= perPage;
        }

        final items = itemsJson
            .map(
              (e) => ProductModel.fromJson(
                Map<String, dynamic>.from(e as Map),
              ),
            )
            .toList();

        final result = ProductsResult(
          items: items,
          hasMore: hasMore,
          currentPage: currentPage,
          lastPage: lastPage,
          total: total,
        );

        cache.saveList(key, result: result, etag: responseEtag);

        AppLogger.response(tag, 200, response.data);
        AppLogger.info(
          tag,
          'Cached page=$page items=${items.length} etag=$responseEtag',
        );

        return result;
      }

      final root = response.data;
      if (root is Map) {
        throw ApiException.fromResponse(
          response.statusCode,
          Map<String, dynamic>.from(root),
        );
      }
      throw ApiException('Request failed.', statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      AppLogger.dio(tag, e);
      throw ApiException.fromDio(e);
    } catch (e, st) {
      AppLogger.error(tag, e, st);
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected response format.');
    }
  }

  Future<ProductDetailModel> getProduct(int id) async {
    const tag = 'ProductService.getProduct';
    final cached = cache.getDetail(id);

    try {
      final headers = <String, dynamic>{};
      if (cached?.etag != null && cached!.etag!.isNotEmpty) {
        headers['If-None-Match'] = cached.etag;
      }

      AppLogger.request(
        tag,
        'GET',
        ApiConstants.productDetails(id),
        query: {
          if (headers['If-None-Match'] != null)
            'If-None-Match': headers['If-None-Match'],
        },
      );

      final response = await dio.get(
        ApiConstants.productDetails(id),
        options: Options(
          headers: headers,
          validateStatus: (s) => s != null && s >= 200 && s < 400,
        ),
      );

      final responseEtag =
          response.headers.value('etag') ?? response.headers.value('ETag');

      if (response.statusCode == 304) {
        AppLogger.etag(
          tag,
          status: 304,
          requestIfNoneMatch: cached?.etag,
          responseEtag: responseEtag ?? cached?.etag,
          fromCache: true,
        );

        if (cached == null) {
          throw ApiException(
            'Cached product not available.',
            statusCode: 304,
          );
        }

        AppLogger.response(tag, 304, 'from local cache');
        return cached.product;
      }

      if (response.statusCode == 200) {
        AppLogger.etag(
          tag,
          status: 200,
          requestIfNoneMatch: headers['If-None-Match']?.toString(),
          responseEtag: responseEtag,
          fromCache: false,
        );

        final root = response.data;
        if (root is! Map) {
          throw ApiException('Unexpected response from server.');
        }

        final code =
            (root['code'] as num?)?.toInt() ?? response.statusCode ?? 200;
        final message = root['message']?.toString();
        final data = root['data'];

        if (code == 404 || data == null) {
          throw ApiException(
            message ?? 'Product not found.',
            statusCode: 404,
          );
        }
        if (code >= 400) {
          throw ApiException.fromResponse(
            code,
            Map<String, dynamic>.from(root),
          );
        }
        if (data is! Map) {
          throw ApiException('Unexpected response from server.');
        }

        final product = ProductDetailModel.fromJson(
          Map<String, dynamic>.from(data),
        );

        cache.saveDetail(id, product: product, etag: responseEtag);

        AppLogger.response(tag, 200, response.data);
        AppLogger.info(tag, 'Cached product id=$id etag=$responseEtag');

        return product;
      }

      final root = response.data;
      if (root is Map) {
        throw ApiException.fromResponse(
          response.statusCode,
          Map<String, dynamic>.from(root),
        );
      }
      throw ApiException('Request failed.', statusCode: response.statusCode);
    } on ApiException {
      rethrow;
    } on DioException catch (e) {
      AppLogger.dio(tag, e);
      throw ApiException.fromDio(e);
    } catch (e, st) {
      AppLogger.error(tag, e, st);
      if (e is ApiException) rethrow;
      throw ApiException('Unexpected response format.');
    }
  }
}