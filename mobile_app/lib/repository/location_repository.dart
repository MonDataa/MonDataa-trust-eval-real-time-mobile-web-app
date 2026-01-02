import 'dart:convert';
import 'package:http/http.dart' as http;

import '../models/location_model.dart';
import 'AppConfig.dart';

class LocationRepository {
  final String baseUrl = "http://${AppConfig.baseIp}:8085/api/locations";

  Future<List<LocationModel>> getZones() async {
    try {
      final response = await http.get(Uri.parse("$baseUrl/zones"));
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body) as List<dynamic>;
        List<LocationModel> locations = data
            .map((json) => LocationModel.fromJson(json as Map<String, dynamic>))
            .toList();
        return locations;
      } else {
        throw Exception("Erreur de chargement des zones");
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }
}
