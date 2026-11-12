

import 'package:dio/dio.dart';

import 'package:app_development_project/constants/api_constants.dart';
import 'package:app_development_project/data/cache/categories_cache.dart';
import 'package:app_development_project/data/models/categories_response_model.dart';
import 'package:app_development_project/data/models/category_model.dart';
import 'package:app_development_project/data/network/api_exception.dart';
import 'package:app_development_project/data/network/app_logger.dart';


class CategoryService {
  final Dio dio;
  final CategoriesCache cache;

  CategoryService(this.dio, this.cache);

  Future<CategoriesResponseModel> getCategories() async {
    const tag = 'CategoryService.getCategories';

    try {
      final headers = <String, dynamic>{};

      if (cache.etag != null && cache.etag!.isNotEmpty) {
        headers['If-None-Match'] = cache.etag;
      }

      AppLogger.request(
        tag,
        'GET',
        ApiConstants.categories,
        query: {
          if (headers['If-None-Match'] != null)
            'If-None-Match': headers['If-None-Match'],
        },
      );

      final response = await dio.get(
        ApiConstants.categories,
        options: Options(
          headers: headers,
          validateStatus: (status) =>
              status != null && status >= 200 && status < 400,
        ),
      );

      final responseEtag = response.headers.value('etag') ??
          response.headers.value('ETag');

      if (response.statusCode == 304) {
        AppLogger.etag(
          tag,
          status: 304,
          requestIfNoneMatch: cache.etag,
          responseEtag: responseEtag ?? cache.etag,
          fromCache: true,
        );

        if (!cache.hasData) {
          throw ApiException(
            'Cached categories not available.',
            statusCode: 304,
          );
        }

        AppLogger.response(tag, 304, 'from local cache');

        return CategoriesResponseModel(
          data: List<CategoryModel>.from(cache.categories!),
          message: 'Not modified (from cache).',
          code: 304,
        );
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

        final model = CategoriesResponseModel.fromJson(
          Map<String, dynamic>.from(root),
        );

        cache.save(
          data: model.data,
          etag: responseEtag,
        );

        AppLogger.response(tag, 200, response.data);
        AppLogger.info(tag, 'Cached ${model.data.length} categories, etag=$responseEtag');

        return model;
      }

      AppLogger.response(tag, response.statusCode, response.data);

      final root = response.data;
      if (root is Map) {
        throw ApiException.fromResponse(
          response.statusCode,
          Map<String, dynamic>.from(root),
        );
      }

      throw ApiException(
        'Request failed.',
        statusCode: response.statusCode,
      );
    } on ApiException catch (e) {
      AppLogger.error(tag, e);
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