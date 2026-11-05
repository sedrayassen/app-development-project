class CategoryModel {
  final int id;
  final String name;
  final String slug;
  final String description;

  CategoryModel({
    required this.id,
    required this.name,
    required this.slug,
    required this.description,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: (json['id'] as num).toInt(),
      name: json['name'] as String? ?? '',
      slug: json['slug'] as String? ?? '',
      description: json['description'] as String? ?? '',
    );
  }
}