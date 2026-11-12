import 'package:app_development_project/data/models/category_model.dart';

class CategoriesCache {
  String? etag;
  List<CategoryModel>? categories;

  bool get hasData => categories != null && categories!.isNotEmpty;

  void save({
    required List<CategoryModel> data,
    required String? etag,
  }) {
    categories = data;
    this.etag = etag;
  }

  void clear() {
    etag = null;
    categories = null;
  }
}