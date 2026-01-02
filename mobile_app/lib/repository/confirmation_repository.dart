import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/confirmation_model.dart';

import 'AppConfig.dart';

class ConfirmationRepository {
  final String baseUrl = "http://${AppConfig.baseIp}:8085/api/confirmations";

  Future<ConfirmationModel> confirmEvent(int clientId, int eventId) async {
    final String url = "$baseUrl/confirm";

    try {
      print("📡 Envoi de la confirmation à l'API: $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"clientId": clientId, "eventId": eventId}),
      );

      print("🔄 Réponse de l'API: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        return ConfirmationModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            "❌ Erreur API: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Exception lors de la requête: $e");
      throw Exception("Erreur lors de la confirmation de l'événement: $e");
    }
  }

  Future<ConfirmationModel> rejectEvent(int clientId, int eventId) async {
    final String url = "$baseUrl/reject";

    try {
      print("📡 Envoi de la confirmation à l'API: $url");

      final response = await http.post(
        Uri.parse(url),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"clientId": clientId, "eventId": eventId}),
      );

      print("🔄 Réponse de l'API: ${response.statusCode} - ${response.body}");

      if (response.statusCode == 200) {
        return ConfirmationModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception(
            "❌ Erreur API: ${response.statusCode} - ${response.body}");
      }
    } catch (e) {
      print("❌ Exception lors de la requête: $e");
      throw Exception("Erreur lors de la confirmation de l'événement: $e");
    }
  }
}
