import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:flutter_secure_storage/flutter_secure_storage.dart';
import '../config/api_config.dart';
import '../models/user_model.dart';

class AuthService {
  final _storage = const FlutterSecureStorage();

  // Login with email instead of username
  Future<User> login(String email, String password) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authEndpoint}/login'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final User user = User.fromJson(data['user']);

      // Store the token
      await _storage.write(key: 'token', value: data['token']);
      await _storage.write(key: 'userId', value: user.id);

      return user;
    } else {
      throw Exception('Failed to login: ${response.body}');
    }
  }

  // Register with email
  Future<User> register(String email, String password, String firstname, String lastname) async {
    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.authEndpoint}/register'),
      headers: {'Content-Type': 'application/json'},
      body: jsonEncode({
        'email': email,
        'password': password,
        'firstname': firstname,
        'lastname': lastname,
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      final User user = User.fromJson(data['user']);

      // Store the token if provided, otherwise user will need to login
      if (data.containsKey('token')) {
        await _storage.write(key: 'token', value: data['token']);
        await _storage.write(key: 'userId', value: user.id);
      }

      return user;
    } else {
      throw Exception('Failed to register: ${response.body}');
    }
  }

  // Logout
  Future<void> logout() async {
    await _storage.delete(key: 'token');
    await _storage.delete(key: 'userId');
  }

  // Check if user is logged in
  Future<bool> isLoggedIn() async {
    final token = await _storage.read(key: 'token');
    return token != null;
  }

  // Get current user token
  Future<String?> getToken() async {
    return await _storage.read(key: 'token');
  }

  // Get current user ID
  Future<String?> getUserId() async {
    return await _storage.read(key: 'userId');
  }
}