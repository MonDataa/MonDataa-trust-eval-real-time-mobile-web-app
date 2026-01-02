import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/StatisticsModel.dart';

import 'AppConfig.dart';

class StatisticsRepository {
  final String baseUrl = "http://${AppConfig.baseIp}:8085/api/users";

  Future<StatisticsModel> getUserStatistics(int userId) async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/$userId/statistics"));

      print("📩 Réponse API : ${response.body}");
      print("📩 Code HTTP : ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return StatisticsModel.fromJson(data);
      } else {
        throw Exception("Erreur de chargement des statistiques");
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }
}
