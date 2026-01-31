import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:flutter_stripe/flutter_stripe.dart';
import 'api_service.dart';

class StripeService {
  static final String _baseUrl = ApiService.baseUrl;

  static Future<String?> createPaymentIntent(double amount) async {
    try {
      final headers = await ApiService.getHeaders();
      // Need to convert to cents for stripe
      final int amountInCents = (amount * 100).toInt();

      debugPrint(
        "--- STRIPE SERVICE: Creating PaymentIntent for $amountInCents cents",
      );

      final response = await http.post(
        Uri.parse("$_baseUrl/create-payment-intent"),
        headers: headers,
        body: jsonEncode({"amount": amountInCents}),
      );

      debugPrint("--- STRIPE SERVICE: Response Status: ${response.statusCode}");
      debugPrint("--- STRIPE SERVICE: Response Body: ${response.body}");

      if (response.statusCode == 200 || response.statusCode == 201) {
        final data = jsonDecode(response.body);
        return data["client_secret"];
      }
      return null;
    } catch (e) {
      debugPrint("--- STRIPE SERVICE ERROR (createPaymentIntent): $e");
      return null;
    }
  }

  static Future<String?> confirmPaymentWithCardField(double amount) async {
    try {
      // First get the intent from our server
      final clientSecret = await createPaymentIntent(amount);
      if (clientSecret == null) {
        throw Exception("Failed to get client secret from server");
      }

      // Now confirm the actual payment
      // Card details come automatically from the CardField widget
      final PaymentIntent paymentIntent = await Stripe.instance.confirmPayment(
        paymentIntentClientSecret: clientSecret,
        data: const PaymentMethodParams.card(
          paymentMethodData: PaymentMethodData(),
        ),
      );

      debugPrint(
        "--- STRIPE SERVICE: CardField Payment successful! ID: ${paymentIntent.id}",
      );
      return paymentIntent.id;
    } catch (e) {
      if (e is StripeException) {
        debugPrint("--- STRIPE ERROR: ${e.error.localizedMessage}");
      } else {
        debugPrint("--- STRIPE SERVICE ERROR: $e");
      }
      return null;
    }
  }

  // No longer used - we moved to the inline UI
  static Future<bool> makePayment(BuildContext context, double amount) async {
    // ... preserved for compatibility or fallback if needed ...
    return false;
  }
}
