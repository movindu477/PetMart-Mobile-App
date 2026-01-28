import 'dart:convert';
import 'package:http/http.dart' as http;

import 'api_service.dart';

class OrderService {
  static final String baseUrl = ApiService.baseUrl;

  static Future<void> placeOrder({
    required String fullName,
    required String address,
    required String phone,
    String? cityZip,
    required String paymentMethod,
    required List<Map<String, dynamic>> cartItems,
    required double totalAmount,
  }) async {
    try {
      // Prepare order items
      final orderItems = cartItems.map((item) {
        return {
          'pet_id': item['pet_id'] ?? item['id'],
          'quantity': item['quantity'] ?? 1,
          'price': item['price'] ?? 0.0,
        };
      }).toList();

      // Prepare order data
      final orderData = {
        'full_name': fullName,
        'address': address,
        'phone': phone,
        if (cityZip != null && cityZip.isNotEmpty) 'city_zip': cityZip,
        'payment_method': paymentMethod,
        'items': orderItems,
        'total_amount': totalAmount,
      };

      final response = await http
          .post(
            Uri.parse("$baseUrl/orders"),
            headers: await ApiService.authHeaders(),
            body: jsonEncode(orderData),
          )
          .timeout(
            const Duration(seconds: 15),
            onTimeout: () {
              throw Exception("Request timeout. Please check your connection.");
            },
          );

      if (response.statusCode != 200 && response.statusCode != 201) {
        String errorMessage = "Failed to place order";
        try {
          final errorBody = jsonDecode(response.body);
          errorMessage =
              errorBody['message'] ?? errorBody['error'] ?? errorMessage;
        } catch (_) {
          errorMessage = "Server error: ${response.statusCode}";
        }
        throw Exception(errorMessage);
      }
    } catch (e) {
      if (e is Exception) {
        rethrow;
      }
      throw Exception("Network error: $e");
    }
  }
}
