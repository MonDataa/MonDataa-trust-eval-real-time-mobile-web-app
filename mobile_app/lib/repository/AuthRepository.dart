import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/UserModel.dart';

import 'AppConfig.dart';

class AuthRepository {
  String get baseUrl => "http://${AppConfig.baseIp}:8085/api/users";

  // Connexion de l'utilisateur (inchangée)
  Future<UserModel?> loginUser(String email, String password) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/login"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({"email": email, "password": password}),
      );
      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }

  // Inscription de l'utilisateur avec locationId
  Future<UserModel?> registerUser(
      String username,
      String email,
      String password,
      int locationId,
      double latitude,
      double longitude) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/register"),
        headers: {"Content-Type": "application/json"},
        body: jsonEncode({
          "username": username,
          "email": email,
          "password": password,
          "userType": "CLIENT",
          "locationId": locationId,
          "latitude": latitude,
          "longitude": longitude,
        }),
      );
      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return UserModel.fromJson(data);
      } else {
        return null;
      }
    } catch (e) {
      throw Exception("Erreur d'inscription : $e");
    }
  }

  Future<bool> logoutUser(int userId) async {
    try {
      final response = await http.post(
        Uri.parse("$baseUrl/logout?userId=$userId"),
      );
      if (response.statusCode == 200) {
        print("✅ Déconnexion réussie : ${response.body}");
        return true;
      } else {
        print("❌ Erreur lors de la déconnexion : ${response.reasonPhrase}");
        return false;
      }
    } catch (e) {
      print("❌ Erreur de déconnexion : $e");
      return false;
    }
  }

  Future<bool> isLoggedIn() async {
    return false;
  }
}
