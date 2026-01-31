import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';

class ApiService {
  // Backend API URL
  static const String baseUrl =
      "https://web-production-de68aa.up.railway.app/api";
  static const String contentUrl =
      "https://web-production-de68aa.up.railway.app";

  static Future<Map<String, String>> authHeaders() => getHeaders();

  static Future<Map<String, String>> getHeaders() async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    final headers = {
      "Accept": "application/json",
      "Content-Type": "application/json",
      "X-Requested-With": "XMLHttpRequest",
    };

    if (token != null) {
      headers["Authorization"] = "Bearer $token";
    }

    return headers;
  }

  static Future<bool> isLoggedIn() async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.containsKey('token') && prefs.getString('token') != null;
  }

  static Future<Map<String, dynamic>?> fetchUserProfile() async {
    final url = Uri.parse("$baseUrl/user");
    final headers = await getHeaders();

    debugPrint("--- FETCHING PROFILE: $url");
    try {
      final response = await http
          .get(url, headers: headers)
          .timeout(const Duration(seconds: 10));

      debugPrint("--- PROFILE STATUS: ${response.statusCode}");
      debugPrint("--- PROFILE BODY: ${response.body}");

      if (response.statusCode == 200) {
        if (response.body.isEmpty) return null;

        final dynamic jsonResponse = jsonDecode(response.body);

        if (jsonResponse is Map<String, dynamic>) {
          // Check for nested user data in the response
          final dynamic data = jsonResponse['data'];
          if (data is Map<String, dynamic>) {
            return data['user'] ?? data;
          }
          return jsonResponse['user'] ?? jsonResponse;
        }
        return null;
      } else if (response.statusCode == 401) {
        // Clear token on 401
        final prefs = await SharedPreferences.getInstance();
        await prefs.remove('token');
        return null;
      }
    } catch (e) {
      debugPrint("Error fetching user profile: $e");
    }
    return null;
  }
}
