import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _token;
  Map<String, dynamic>? _user;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  String? get token => _token;
  Map<String, dynamic>? get user => _user;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http.post(
        Uri.parse('${ApiService.baseUrl}/login'),
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      if (response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _user = data['user'];

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);
        // Save user details if needed
      } else {
        throw Exception(jsonDecode(response.body)['message'] ?? 'Login failed');
      }
    } catch (e) {
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _token = null;
    _user = null;
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove('token');
    notifyListeners();
  }

  Future<void> checkLoginStatus() async {
    final prefs = await SharedPreferences.getInstance();
    _token = prefs.getString('token');

    if (_token != null) {
      // Validate token and get user data
      try {
        final userData = await ApiService.fetchUserProfile();
        if (userData != null) {
          _user = userData;
        } else {
          // Token might be invalid/expired
          _token = null;
          await prefs.remove('token');
        }
      } catch (e) {
        // Handle network error gracefully, opt to keep token or clear it depending on security requirement
        // For now, if we can't reach server, we might assume session is still valid locally or clear it
        // _token = null;
        // await prefs.remove('token');
      }
    }
    notifyListeners();
  }

  Future<void> register(
    String name,
    String email,
    String password,
    String passwordConfirmation,
  ) async {
    _isLoading = true;
    notifyListeners();

    try {
      final response = await http
          .post(
            Uri.parse('${ApiService.baseUrl}/register'),
            headers: {
              'Content-Type': 'application/json',
              'Accept': 'application/json',
            },
            body: jsonEncode({
              'name': name,
              'email': email,
              'password': password,
              'password_confirmation': passwordConfirmation,
            }),
          )
          .timeout(const Duration(seconds: 10));

      if (response.statusCode == 201 || response.statusCode == 200) {
        final data = jsonDecode(response.body);
        _token = data['token'];
        _user = data['user'];

        final prefs = await SharedPreferences.getInstance();
        if (_token != null) {
          await prefs.setString('token', _token!);
        }
      } else {
        final errorMsg =
            jsonDecode(response.body)['message'] ?? 'Registration failed';
        throw Exception(errorMsg);
      }
    } catch (e) {
      if (e.toString().contains('TimeoutException')) {
        throw Exception(
          'Connection timed out. Please check if the server is running.',
        );
      }
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
