import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/EventModel.dart';
import '../models/event_detail_model.dart';
import 'AppConfig.dart';

class EventsRepository {
  final String baseUrl = "http://${AppConfig.baseIp}:8085/api/events";

  /// Récupère la liste des événements (pour la HomePage)f
  Future<List<EventModel>> getEvents() async {
    try {
      final response = await http.get(Uri.parse(baseUrl));
      if (response.statusCode == 200) {
        final List result = jsonDecode(response.body);
        return result.map((e) => EventModel.fromJson(e)).toList();
      } else {
        throw Exception('Failed to load events: ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception('Error fetching events: $e');
    }
  }

  Future<Map<String, dynamic>> getEventsL({int page = 0, int size = 8}) async {
    try {
      final response =
          await http.get(Uri.parse('$baseUrl/pages?page=$page&size=$size'));
      print("📥 API Response: ${response.body}"); // 🔍 Debug the API response
      if (response.statusCode == 200) {
        final decodedData = jsonDecode(response.body);

        if (decodedData is List) {
          // ✅ Si l'API retourne une LISTE, on la traite correctement
          List<EventModel> events =
              decodedData.map((json) => EventModel.fromJson(json)).toList();
          return {
            "events": events,
            "totalPages": 1, // 🔹 Pas de pagination si c'est une liste simple
            "currentPage": 0
          };
        } else if (decodedData is Map<String, dynamic>) {
          // ✅ Si l'API retourne un OBJET (cas normal de pagination)
          List<EventModel> events = (decodedData['content'] as List)
              .map((json) => EventModel.fromJson(json))
              .toList();

          return {
            "events": events,
            "totalPages": decodedData['totalPages'],
            "currentPage": page
          };
        } else {
          throw Exception("Format de réponse inattendu");
        }
      } else {
        throw Exception("Erreur de chargement des événements");
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }

  /// Récupère les détails d'un événement donné
  Future<EventDetail> getEventDetails(int eventId) async {
    try {
      final response = await http.get(Uri.parse('$baseUrl/$eventId/details'));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return EventDetail.fromJson(data);
      } else {
        throw Exception(
            'Échec du chargement des détails de l\'événement : ${response.reasonPhrase}');
      }
    } catch (e) {
      throw Exception(
          'Erreur lors de la récupération des détails de l\'événement : $e');
    }
  }

  /// 🔹 Création d'un événement
  Future<EventModel> createEvent(
    String title,
    String description,
    int creatorId,
    int locationId,
    int categoryId,
    double latitude,
    double longitude,
    DateTime expirationTime,
    String imageName,
  ) async {
    // 🔥 Vérifier que creatorId n'est pas null avant d'envoyer la requête
    if (creatorId == null) {
      throw Exception("❌ L'ID du créateur est null !");
    }

    final Map<String, dynamic> body = {
      "title": title,
      "description": description,
      "eventTime": DateTime.now().toIso8601String(),
      "expirationTime":
          DateTime.now().add(const Duration(days: 2)).toIso8601String(),
      "creatorId": creatorId,
      "categoryId": categoryId,
      "locationId": locationId,
      "latitude": latitude,
      "longitude": longitude,
      "expirationTime": expirationTime.toIso8601String(),
      "imageName": imageName,
    };

    print("🔹 POST $baseUrl");
    print("🔹 Données envoyées : $body");

    try {
      final response = await http.post(
        Uri.parse(baseUrl),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode(body),
      );

      print("🔹 Réponse Status Code : ${response.statusCode}");
      print("🔹 Réponse Body : ${response.body}");

      if (response.statusCode == 201 || response.statusCode == 200) {
        return EventModel.fromJson(jsonDecode(response.body));
      } else {
        throw Exception("❌ Erreur création événement : ${response.body}");
      }
    } catch (e) {
      throw Exception(
          "❌ Erreur réseau lors de la création de l'événement : $e");
    }
  }
}
