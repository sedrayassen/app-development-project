import 'package:app_development_project/constants/api_constants.dart';

class ProductImageModel {
  final int id;
  final String url;
  final int sortOrder;

  ProductImageModel({
    required this.id,
    required this.url,
    this.sortOrder = 0,
  });

  factory ProductImageModel.fromJson(Map<String, dynamic> json) {
    return ProductImageModel(
      id: int.tryParse('${json['id']}') ?? 0,
      url: ApiConstants.fixImageUrl(json['url']?.toString() ?? ''),
      sortOrder: int.tryParse('${json['sort_order']}') ?? 0,
    );
  }
}

class ProductDetailModel {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final double price;
  final bool isActive;
  final int? categoryId;
  final String? categoryName;
  final List<ProductImageModel> images;
  final String? createdAt;
  final String? updatedAt;

  /// null = الباك ما رجّعها بهالـ response
  final int? availableQuantity;

  ProductDetailModel({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    required this.price,
    this.isActive = true,
    this.categoryId,
    this.categoryName,
    this.images = const [],
    this.createdAt,
    this.updatedAt,
    this.availableQuantity,
  });

  /// بيدعم شكلين للـ data:
  /// 1) المنتج مباشرة
  /// 2) { product: {...}, available_quantity: 5 }
  factory ProductDetailModel.fromJson(Map<String, dynamic> json) {
    final wrapped = json['product'] is Map;
    final p = wrapped
        ? Map<String, dynamic>.from(json['product'] as Map)
        : json;

    final category = p['category'];
    final imagesJson = p['images'];

    final images = <ProductImageModel>[
      if (imagesJson is List)
        for (final i in imagesJson)
          if (i is Map) ProductImageModel.fromJson(Map<String, dynamic>.from(i)),
    ]..sort((a, b) => a.sortOrder.compareTo(b.sortOrder));

    final qtyRaw = json['available_quantity'] ?? p['available_quantity'];

    return ProductDetailModel(
      id: int.tryParse('${p['id']}') ?? 0,
      name: p['name']?.toString() ?? '',
      slug: p['slug']?.toString(),
      description: p['description']?.toString(),
      price: double.tryParse('${p['price']}') ?? 0,
      isActive: p['is_active'] == 1 || p['is_active'] == true,
      categoryId: category is Map ? int.tryParse('${category['id']}') : null,
      categoryName: category is Map ? category['name']?.toString() : null,
      images: images,
      createdAt: p['created_at']?.toString(),
      updatedAt: p['updated_at']?.toString(),
      availableQuantity: qtyRaw == null ? null : int.tryParse('$qtyRaw'),
    );
  }
}