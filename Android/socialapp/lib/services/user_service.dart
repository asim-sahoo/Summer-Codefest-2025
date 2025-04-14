import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import '../models/user_model.dart';
import 'auth_service.dart';

class UserService {
  final AuthService _authService = AuthService();

  // Get a user by ID
  Future<User> getUserById(String userId) async {
    final token = await _authService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userEndpoint}/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to get user: ${response.body}');
    }
  }

  // Update user profile
  Future<User> updateUser(String userId, Map<String, dynamic> userData) async {
    final token = await _authService.getToken();

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userEndpoint}/$userId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode(userData),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return User.fromJson(data);
    } else {
      throw Exception('Failed to update user: ${response.body}');
    }
  }

  // Follow a user
  Future<void> followUser(String userId) async {
    final token = await _authService.getToken();
    final currentUserId = await _authService.getUserId();

    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userEndpoint}/$userId/follow'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentUserId': currentUserId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to follow user: ${response.body}');
    }
  }

  // Unfollow a user
  Future<void> unfollowUser(String userId) async {
    final token = await _authService.getToken();
    final currentUserId = await _authService.getUserId();

    if (currentUserId == null) {
      throw Exception('User not logged in');
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userEndpoint}/$userId/unfollow'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'currentUserId': currentUserId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to unfollow user: ${response.body}');
    }
  }

  // Get user followers
  Future<List<User>> getUserFollowers(String userId) async {
    final token = await _authService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userEndpoint}/$userId/followers'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to get followers: ${response.body}');
    }
  }

  // Get user following
  Future<List<User>> getUserFollowing(String userId) async {
    final token = await _authService.getToken();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.userEndpoint}/$userId/following'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((user) => User.fromJson(user)).toList();
    } else {
      throw Exception('Failed to get following: ${response.body}');
    }
  }
}