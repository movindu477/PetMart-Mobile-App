import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  static const String baseUrl = "http://10.0.2.2/SSPLaravel/public/api";
  static const String contentUrl = "http://10.0.2.2/SSPLaravel/public";

  static Future<Map<String, String>> authHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    return {
      "Accept": "application/json",
      "Content-Type": "application/json",
      if (token != null) "Authorization": "Bearer $token",
    };
  }

  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    final url = Uri.parse("$baseUrl/user"); // Assuming standard endpoint
    final headers = await authHeaders();

    try {
      final response = await http.get(url, headers: headers);

      if (response.statusCode == 200) {
        return jsonDecode(response.body);
      } else {
        // Fallback: try /profile if /user fails, or just return null
        // return null;
        print("Failed to fetch user profile: ${response.statusCode}");
      }
    } catch (e) {
      print("Error fetching user profile: $e");
    }
    return null;
  }
}
