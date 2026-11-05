import 'category_model.dart';

class CategoriesResponseModel {
  final List<CategoryModel> data;
  final String message;
  final int code;

  CategoriesResponseModel({
    required this.data,
    required this.message,
    required this.code,
  });

  factory CategoriesResponseModel.fromJson(
    Map<String, dynamic> json,
  ) {
    return CategoriesResponseModel(
      data: (json['data'] as List<dynamic>)
          .map(
            (item) => CategoryModel.fromJson(
              item as Map<String, dynamic>,
            ),
          )
          .toList(),
      message: json['message'] as String? ?? '',
      code: (json['code'] as num?)?.toInt() ?? 0,
    );
  }
}