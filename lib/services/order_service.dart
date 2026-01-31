import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'api_service.dart';

class OrderService {
  static final String _baseUrl = ApiService.baseUrl;

  static Future<bool> checkout({
    required String fullName,
    required String address,
    required String city,
    required String phone,
    required String paymentMethod,
    String? paymentIntentId,
  }) async {
    try {
      final response = await http
          .post(
            Uri.parse("$_baseUrl/checkout"),
            headers: await ApiService.getHeaders(),
            body: jsonEncode({
              "full_name": fullName,
              "shipping_address": address,
              "shipping_city": city,
              "shipping_phone": phone,
              "payment_method": paymentMethod,
              if (paymentIntentId != null) "payment_intent_id": paymentIntentId,
            }),
          )
          .timeout(const Duration(seconds: 15));

      debugPrint("--- CHECKOUT STATUS: ${response.statusCode}");
      debugPrint("--- CHECKOUT RESPONSE: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        return true;
      }
      return false;
    } catch (e) {
      debugPrint("CHECKOUT ERROR: $e");
      return false;
    }
  }
}
