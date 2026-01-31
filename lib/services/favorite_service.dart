import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class FavoriteService {
  static final String _baseUrl = ApiService.baseUrl;

  static Future<Set<int>> fetchFavorites() async {
    try {
      final response = await http.get(
        Uri.parse("$_baseUrl/favorites"),
        headers: await ApiService.getHeaders(),
      );

      if (response.statusCode == 200) {
        debugPrint("FETCH FAVORITES SUCCESS: ${response.body}");
        if (response.body.isEmpty) return {};

        final dynamic body = jsonDecode(response.body);
        List list = [];

        if (body is List) {
          list = body;
        } else if (body is Map) {
          if (body['data'] is List) {
            list = body['data'];
          } else if (body['favorites'] is List) {
            list = body['favorites'];
          } else if (body['items'] is List) {
            list = body['items'];
          } else if (body['data'] is Map) {
            final data = body['data'];
            if (data['favorites'] is List)
              list = data['favorites'];
            else if (data['items'] is List)
              list = data['items'];
          }
        }

        return list.map<int>((e) {
          if (e is int) return e;
          if (e is String) return int.tryParse(e) ?? 0;
          if (e is Map) {
            final petId = e['pet_id'] ?? e['id'];
            if (petId is int) return petId;
            return int.tryParse(petId.toString()) ?? 0;
          }
          return 0;
        }).toSet();
      } else {
        debugPrint(
          "FETCH FAVORITES FAILED: ${response.statusCode} - ${response.body}",
        );
      }
      return {};
    } catch (e) {
      debugPrint("FETCH FAVORITES ERROR: $e");
      return {};
    }
  }

  static Future<bool> toggleFavorite(int petId) async {
    try {
      debugPrint("--- FAVORITE SERVICE: Toggling $petId");
      final response = await http.post(
        Uri.parse("$_baseUrl/favorites/toggle"),
        headers: await ApiService.getHeaders(),
        body: jsonEncode({"pet_id": petId}),
      );

      debugPrint(
        "--- FAVORITE SERVICE: Status: ${response.statusCode}, Body: ${response.body}",
      );

      if (response.statusCode == 200 || response.statusCode == 201) {
        final jsonResponse = jsonDecode(response.body);
        final dynamic data = jsonResponse['data'] ?? jsonResponse;

        if (data is Map) {
          // Robust parsing of favorited state
          final attached = data['attached'];
          if (attached is List) return attached.isNotEmpty;
          if (attached is bool) return attached;

          final status = data['status']?.toString().toLowerCase();
          if (status == 'added' || status == 'attached' || status == 'success')
            return true;
          if (status == 'removed' || status == 'detached') return false;

          final message = data['message']?.toString().toLowerCase() ?? '';
          if (message.contains('added') ||
              message.contains('successful') ||
              message.contains('attached'))
            return true;
          if (message.contains('removed') || message.contains('detached'))
            return false;
        }

        // If we got success but can't find 'attached' key, it might just be the new state
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("TOGGLE FAVORITE ERROR: $e");
      return false;
    }
  }
}
