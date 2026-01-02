import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:mobile_app/models/UserModel.dart';

import 'AppConfig.dart';

class UsersRepository {
  final String baseUrl = "http://${AppConfig.baseIp}:8085/api/users";

  Future<Map<String, dynamic>> getClients(
      {int page = 0, int size = 10, String? username}) async {
    try {
      String url = "$baseUrl/clientspages?page=$page&size=$size";
      if (username != null && username.isNotEmpty) {
        url += "&username=$username";
      }

      final response = await http.get(Uri.parse(url));

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        List<UserModel> clients = (data['content'] as List)
            .map((json) => UserModel.fromJson(json as Map<String, dynamic>))
            .toList();

        return {
          "clients": clients,
          "totalPages": data['totalPages'],
          "currentPage": page
        };
      } else {
        throw Exception("Erreur de chargement des clients");
      }
    } catch (e) {
      throw Exception("Erreur de connexion : $e");
    }
  }
}
