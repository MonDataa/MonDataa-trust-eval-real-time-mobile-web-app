import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/ProfileModel.dart';

import 'AppConfig.dart';

class ProfileRepository {
  final String baseUrl = "http://${AppConfig.baseIp}:8085/api/users";

  Future<ProfileModel> getUserStatistics(int userId) async {
    try {
      // Appel pour récupérer l'historique de participation
      final participationResponse = await http.get(
        Uri.parse("$baseUrl/$userId/participation-history"),
      );
      // Appel pour récupérer le trust score
      final trustScoreResponse = await http.get(
        Uri.parse("$baseUrl/$userId/trust-score"),
      );

      print("📩 Réponse participation-history : ${participationResponse.body}");
      print(
          "📩 Code HTTP participation-history : ${participationResponse.statusCode}");
      print("📩 Réponse trust-score : ${trustScoreResponse.body}");
      print("📩 Code HTTP trust-score : ${trustScoreResponse.statusCode}");

      if (participationResponse.statusCode == 200 &&
          trustScoreResponse.statusCode == 200) {
        final participationData =
            jsonDecode(participationResponse.body) as List<dynamic>;
        final trustScoreData = jsonDecode(trustScoreResponse.body);

        // Combinaison des deux réponses dans une seule Map
        final combinedData = {
          'participationHistory': participationData,
          'trustScore': trustScoreData,
        };

        return ProfileModel.fromJson(combinedData);
      } else {
        throw Exception("Erreur de chargement des statistiques");
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }
}
