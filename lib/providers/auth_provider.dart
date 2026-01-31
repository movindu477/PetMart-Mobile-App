import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../services/api_service.dart';
import '../models/user.dart';

class AuthProvider with ChangeNotifier {
  bool _isLoading = false;
  String? _token;
  User? _user;

  bool get isLoading => _isLoading;
  bool get isAuthenticated => _token != null;
  String? get token => _token;
  User? get user => _user;

  Future<void> login(String email, String password) async {
    _isLoading = true;
    notifyListeners();

    try {
      final url = Uri.parse('${ApiService.baseUrl}/login');

      // Use fresh headers to avoid using an old token
      final response = await http.post(
        url,
        headers: {
          'Content-Type': 'application/json',
          'Accept': 'application/json',
        },
        body: jsonEncode({'email': email, 'password': password}),
      );

      debugPrint('Status: ${response.statusCode}');
      debugPrint('Body: ${response.body}');

      if (response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }

        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);

        // Check for the nested data field
        final Map<String, dynamic>? responseData = jsonResponse['data'];

        if (responseData == null) {
          throw Exception('Data object missing in response');
        }

        final String? token = responseData['token'];

        if (token == null || token.isEmpty) {
          throw Exception('Token missing in response');
        }

        _token = token;
        _user = responseData['user'] != null
            ? User.fromJson(responseData['user'])
            : null;

        final prefs = await SharedPreferences.getInstance();
        await prefs.setString('token', _token!);

        // Debug checks
        print('TOKEN => ${prefs.getString('token')}');
        print('LOGIN SUCCESS');

        // Store user data locally
        if (responseData['user'] != null) {
          await prefs.setString('user', jsonEncode(responseData['user']));
        }
      } else {
        if (response.body.isEmpty) {
          throw Exception('Login failed with status: ${response.statusCode}');
        }
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Login failed');
      }
    } catch (e) {
      debugPrint("LOGIN ERROR: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> logout() async {
    _isLoading = true;
    notifyListeners();

    try {
      await http.post(
        Uri.parse('${ApiService.baseUrl}/logout'),
        headers: await ApiService.getHeaders(),
      );
    } catch (e) {
      debugPrint("LOGOUT ERROR: $e");
    } finally {
      _token = null;
      _user = null;
      final prefs = await SharedPreferences.getInstance();
      await prefs.remove('token');
      await prefs.remove('user');
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> checkLoginStatus() async {
    _isLoading = true;
    notifyListeners();

    try {
      final prefs = await SharedPreferences.getInstance();
      _token = prefs.getString('token');
      final cachedUser = prefs.getString('user');

      if (cachedUser != null) {
        try {
          _user = User.fromJson(jsonDecode(cachedUser));
          debugPrint("--- AUTH: Loaded CACHED user: ${_user?.name}");
        } catch (e) {
          debugPrint("--- AUTH: Failed to parse cached user: $e");
        }
      }

      debugPrint(
        "--- AUTH: Checking status. Stored Token: ${_token != null ? 'EXISTS' : 'NULL'}",
      );

      if (_token != null) {
        // Refresh profile in background so we have the latest data
        ApiService.fetchUserProfile().then((userData) async {
          if (userData != null) {
            _user = User.fromJson(userData);
            await prefs.setString('user', jsonEncode(userData));
            notifyListeners();
            debugPrint("--- AUTH: Profile refreshed from server and cached.");
          } else {
            // Check if token was wiped (e.g. 401)
            final currentToken = prefs.getString('token');
            if (currentToken == null) {
              _token = null;
              _user = null;
            }
            notifyListeners();
          }
        });
      }
    } catch (e) {
      debugPrint("--- AUTH: CHECK LOGIN STATUS ERROR: $e");
    } finally {
      _isLoading = false;
      notifyListeners();
    }
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
      final url = Uri.parse('${ApiService.baseUrl}/register');
      final response = await http.post(
        url,
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
      );

      debugPrint('Register Status: ${response.statusCode}');
      debugPrint('Register Body: ${response.body}');

      if (response.statusCode == 201 || response.statusCode == 200) {
        if (response.body.isEmpty) {
          throw Exception('Empty response from server');
        }

        final Map<String, dynamic> jsonResponse = jsonDecode(response.body);
        final Map<String, dynamic>? responseData = jsonResponse['data'];

        if (responseData == null) {
          throw Exception('Data object missing in registration response');
        }

        _token = responseData['token'];
        _user = responseData['user'] != null
            ? User.fromJson(responseData['user'])
            : null;

        final prefs = await SharedPreferences.getInstance();
        if (_token != null) {
          await prefs.setString('token', _token!);
          print('REGISTER SUCCESS. TOKEN => ${prefs.getString('token')}');
        }

        if (responseData['user'] != null) {
          await prefs.setString('user', jsonEncode(responseData['user']));
        }
      } else {
        if (response.body.isEmpty) {
          throw Exception(
            'Registration failed with status: ${response.statusCode}',
          );
        }
        final Map<String, dynamic> error = jsonDecode(response.body);
        throw Exception(error['message'] ?? 'Registration failed');
      }
    } catch (e) {
      debugPrint("REGISTER ERROR: $e");
      rethrow;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }
}
