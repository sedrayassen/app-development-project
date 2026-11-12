// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:app_development_project/cubit/category/category_state.dart';
// import 'package:app_development_project/data/repository/category_repository.dart';

// class CategoryCubit extends Cubit<CategoryState> {
//   final CategoryRepository categoryRepository;

//   CategoryCubit(this.categoryRepository) : super(CategoryInitial());

//   Future<void> getCategories() async {
//     emit(CategoryLoading());

//     try {
//       final result = await categoryRepository.getCategories();

//       emit(CategorySuccess(result.data));
//     } catch (e) {
//       emit(
//         CategoryFailure(
//           e.toString().replaceFirst('Exception: ', ''),
//         ),
//       );
//     }
//   }
// }
import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_development_project/cubit/category/category_state.dart';
import 'package:app_development_project/data/network/api_exception.dart';
import 'package:app_development_project/data/repository/category_repository.dart';

class CategoryCubit extends Cubit<CategoryState> {
  final CategoryRepository categoryRepository;

  CategoryCubit(this.categoryRepository) : super(CategoryInitial());

  Future<void> getCategories() async {
    emit(CategoryLoading());

    try {
      final result = await categoryRepository.getCategories();
      emit(CategorySuccess(result.data));
    } on ApiException catch (e) {
      emit(CategoryFailure(e.message));
    } catch (e) {
      emit(CategoryFailure('Something went wrong. Please try again.'));
    }
  }
}