import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/event_position_model.dart';

import 'AppConfig.dart';

class EventPositionsRepository {
  final String baseUrl = "http:/${AppConfig.baseIp}:8085/api/events";

  Future<List<EventPosition>> getEventPositions() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/positions"));
      print("📩 Réponse API : ${response.body}");
      print("📩 Code HTTP : ${response.statusCode}");

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        List<EventPosition> positions = data
            .map((json) => EventPosition.fromJson(json as Map<String, dynamic>))
            .toList();
        return positions;
      } else {
        throw Exception("Erreur de chargement des positions");
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }
}
