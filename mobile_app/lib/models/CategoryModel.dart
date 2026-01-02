class CategoryModel {
  final int id;
  final String name;
  final String description;
  final String categoryType; // Par exemple, "PRECONFIGURED" ou "CUSTOM"
  final String? customLabel; // Optionnel pour les catégories personnalisées
  final String? imageName; // Optionnel pour les catégories personnalisées

  CategoryModel({
    required this.id,
    required this.name,
    required this.description,
    required this.categoryType,
    this.customLabel,
    this.imageName,
  });

  factory CategoryModel.fromJson(Map<String, dynamic> json) {
    return CategoryModel(
      id: json['id'] ?? 0,
      name: json['name'] ?? '',
      description: json['description'] ?? '',
      categoryType: json['categoryType'] ?? 'PRECONFIGURED',
      customLabel: json['customLabel'],
      imageName: json['imageName'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      "name": name,
      "description": description,
      "customLabel": customLabel,
    };
  }
}
