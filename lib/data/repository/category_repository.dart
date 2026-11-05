import 'package:app_development_project/data/models/categories_response_model.dart';
import 'package:app_development_project/data/services/category_service.dart';

class CategoryRepository {
  final CategoryService categoryService;

  CategoryRepository(this.categoryService);

  Future<CategoriesResponseModel> getCategories() async {
    return await categoryService.getCategories();
  }
}