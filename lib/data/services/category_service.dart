import 'package:dio/dio.dart';

import 'package:app_development_project/constants/api_constants.dart';
import 'package:app_development_project/data/models/categories_response_model.dart';

class CategoryService {
  final Dio dio;

  CategoryService(this.dio);

  Future<CategoriesResponseModel> getCategories() async {
    final response = await dio.get(
      ApiConstants.categories,
    );

    return CategoriesResponseModel.fromJson(
      response.data as Map<String, dynamic>,
    );
  }
}