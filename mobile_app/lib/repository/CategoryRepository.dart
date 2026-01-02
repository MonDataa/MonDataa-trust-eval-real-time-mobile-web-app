import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/CategoryModel.dart';
import 'AppConfig.dart';

class CategoryRepository {
  final String baseUrl = "http://${AppConfig.baseIp}:8085/api/categories";

  /// ✅ Récupération de toutes les catégories
  Future<List<CategoryModel>> getCategories() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List result = jsonDecode(response.body);
        return result.map((e) => CategoryModel.fromJson(e)).toList();
      } else {
        throw Exception("Erreur lors du chargement des catégories");
      }
    } catch (e) {
      throw Exception("Erreur réseau : $e");
    }
  }

  /// ✅ Création d'une catégorie personnalisée
  Future<CategoryModel?> createCustomCategory(String name, String description,
      String customLabel, String imageName) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/custom"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "name": name,
          "description": description,
          "customLabel": customLabel,
          "imageName": imageName,
        }),
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        return CategoryModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("Erreur lors de la création de la catégorie");
      }
    } catch (e) {
      throw Exception("Erreur réseau : $e");
    }
  }
}
