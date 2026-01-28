import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:url_launcher/url_launcher.dart';
import 'api_service.dart';

class PaymentService {
  static final String baseUrl = ApiService.baseUrl;

  static Future<void> startPayment() async {
    final headers = await ApiService.authHeaders();

    final uri = Uri.parse('$baseUrl/payment/checkout');

    final response = await http.post(uri, headers: headers);

    if (response.statusCode == 200) {
      final data = jsonDecode(response.body);
      final checkoutUrl = data['checkout_url'];

      if (checkoutUrl != null) {
        final urlUri = Uri.parse(checkoutUrl);
        if (!await launchUrl(urlUri, mode: LaunchMode.externalApplication)) {
          throw Exception("Could not launch payment URL");
        }
      } else {
        throw Exception("No checkout URL returned from server");
      }
    } else {
      String msg = "Payment initialization failed (${response.statusCode})";
      try {
        final body = jsonDecode(response.body);
        msg = body['message'] ?? body['error'] ?? msg;
      } catch (_) {}
      throw Exception(msg);
    }
  }
}
