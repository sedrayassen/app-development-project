// import 'package:flutter_bloc/flutter_bloc.dart';

// import 'package:app_development_project/data/models/product_model.dart';
// import 'package:app_development_project/data/repository/product_repository.dart';
// import 'package:app_development_project/cubit/product/product_state.dart';


// //part 'products_state.dart';

// class ProductsCubit extends Cubit<ProductsState> {
//   final ProductRepository repository;

//   ProductsCubit(this.repository) : super(ProductsInitial());

//   int _page = 1;
//   final int _perPage = 10;

//   String? _search;
//   double? _minPrice;
//   double? _maxPrice;
//   String? _sort;
//   String? _direction;
//   int? _categoryId;

//   List<ProductModel> _items = [];
//   bool _hasMore = true;
//   bool _isLoading = false;

//   Future<void> load({
//     String? search,
//     double? minPrice,
//     double? maxPrice,
//     String? sort,
//     String? direction,
//     int? categoryId,
//     bool refresh = true,
//   }) async {
//     if (_isLoading) return;
//     _isLoading = true;

//     if (refresh) {
//       _page = 1;
//       _items = [];
//       _hasMore = true;

//       _search = search;
//       _minPrice = minPrice;
//       _maxPrice = maxPrice;
//       _sort = sort;
//       _direction = direction;
//       _categoryId = categoryId;

//       emit(ProductsLoading());
//     } else {
//       if (!_hasMore) {
//         _isLoading = false;
//         return;
//       }
//       emit(ProductsLoadingMore(List.from(_items)));
//     }

//     try {
//       final result = await repository.fetchProducts(
//         page: _page,
//         perPage: _perPage,
//         search: _search,
//         minPrice: _minPrice,
//         maxPrice: _maxPrice,
//         sort: _sort,
//         direction: _direction,
//         categoryId: _categoryId,
//       );

//       _items = [..._items, ...result.items];
//       _hasMore = result.hasMore;
//       _page++;

//       emit(ProductsLoaded(List.from(_items), hasMore: _hasMore));
//     } catch (e) {
//       emit(ProductsError(e.toString()));
//     } finally {
//       _isLoading = false;
//     }
//   }

//   Future<void> loadMore() async {
//     if (!_hasMore || _isLoading) return;
//     await load(refresh: false);
//   }

//   void clearFilters() {
//     _search = null;
//     _minPrice = null;
//     _maxPrice = null;
//     _sort = null;
//     _direction = null;
//     _categoryId = null;
//     load(refresh: true);
//   }
// }

import 'package:flutter_bloc/flutter_bloc.dart';

import 'package:app_development_project/cubit/product/product_state.dart';
import 'package:app_development_project/data/models/product_model.dart';
import 'package:app_development_project/data/network/api_exception.dart';
import 'package:app_development_project/data/repository/product_repository.dart';

class ProductsCubit extends Cubit<ProductsState> {
  final ProductRepository repository;

  ProductsCubit(this.repository) : super(ProductsInitial());

  int _page = 1;
  final int _perPage = 10;

  String? _search;
  double? _minPrice;
  double? _maxPrice;
  String? _sort;
  String? _direction;
  int? _categoryId;

  List<ProductModel> _items = [];
  bool _hasMore = true;
  bool _isLoading = false;

  Future<void> load({
    String? search,
    double? minPrice,
    double? maxPrice,
    String? sort,
    String? direction,
    int? categoryId,
    bool refresh = true,
  }) async {
    if (_isLoading) return;
    _isLoading = true;

    if (refresh) {
      _page = 1;
      _items = [];
      _hasMore = true;

      _search = search;
      _minPrice = minPrice;
      _maxPrice = maxPrice;
      _sort = sort;
      _direction = direction;
      _categoryId = categoryId;

      emit(ProductsLoading());
    } else {
      if (!_hasMore) {
        _isLoading = false;
        return;
      }
      emit(ProductsLoadingMore(List.from(_items)));
    }

    try {
      final result = await repository.fetchProducts(
        page: _page,
        perPage: _perPage,
        search: _search,
        minPrice: _minPrice,
        maxPrice: _maxPrice,
        sort: _sort,
        direction: _direction,
        categoryId: _categoryId,
      );

      _items = [..._items, ...result.items];
      _hasMore = result.hasMore;
      _page++;

      emit(ProductsLoaded(List.from(_items), hasMore: _hasMore));
    } on ApiException catch (e) {
      if (refresh || _items.isEmpty) {
        emit(ProductsError(e.message));
      } else {
        // فشل تحميل صفحة إضافية: خلّي القائمة ووقف الـ loading more
        emit(ProductsLoaded(List.from(_items), hasMore: _hasMore));
        // اختياري: تقدري تضيفين state فيها loadMoreError
      }
    } catch (_) {
      if (refresh || _items.isEmpty) {
        emit(ProductsError('Something went wrong. Please try again.'));
      } else {
        emit(ProductsLoaded(List.from(_items), hasMore: _hasMore));
      }
    } finally {
      _isLoading = false;
    }
  }

  Future<void> loadMore() async {
    if (!_hasMore || _isLoading) return;
    await load(refresh: false);
  }

  void clearFilters() {
    _search = null;
    _minPrice = null;
    _maxPrice = null;
    _sort = null;
    _direction = null;
    _categoryId = null;
    load(refresh: true);
  }
}