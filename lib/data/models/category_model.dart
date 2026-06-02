class CategoryModel {
  const CategoryModel({
    required this.id,
    required this.title,
    required this.description,
    required this.sortOrder,
    required this.icon,
  });

  final String id;
  final Map<String, String> title;
  final Map<String, String> description;
  final int sortOrder;
  final String icon;

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] as String,
      title: Map<String, String>.from(json['title'] as Map),
      description: Map<String, String>.from(json['description'] as Map),
      sortOrder: json['sort_order'] as int,
      icon: json['icon'] as String,
    );
  }
}
