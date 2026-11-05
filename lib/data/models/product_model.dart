class ProductModel {
  final int id;
  final String name;
  final String? slug;
  final String? description;
  final double price;
  final bool isActive;
  final int? categoryId;
  final String? categoryName;

  ProductModel({
    required this.id,
    required this.name,
    this.slug,
    this.description,
    required this.price,
    this.isActive = true,
    this.categoryId,
    this.categoryName,
  });

  factory ProductModel.fromJson(Map<String, dynamic> json) {
    final category = json['category'];

    return ProductModel(
      id: json['id'] is int
          ? json['id'] as int
          : int.tryParse('${json['id']}') ?? 0,
      name: json['name']?.toString() ?? '',
      slug: json['slug']?.toString(),
      description: json['description']?.toString(),
      price: double.tryParse('${json['price']}') ?? 0,
      isActive: json['is_active'] == 1 || json['is_active'] == true,
      categoryId: category is Map
          ? (category['id'] is int
              ? category['id'] as int
              : int.tryParse('${category['id']}'))
          : null,
      categoryName:
          category is Map ? category['name']?.toString() : null,
    );
  }
}