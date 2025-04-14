import 'dart:convert';
import 'package:http/http.dart' as http;
import '../config/api_config.dart';
import 'auth_service.dart';

class EngagementService {
  final AuthService _authService = AuthService();

  // Fetch the daily digest for a user
  Future<Map<String, dynamic>> getDailyDigest(String userId) async {
    final token = await _authService.getToken();

    // Trim and encode the userId to avoid issues with spaces
    final encodedUserId = Uri.encodeComponent(userId.trim());

    // Use the engagementEndpoint from ApiConfig which includes the /api prefix
    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.engagementEndpoint}/digest/$encodedUserId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to get daily digest: ${response.body}');
    }
  }

  // Generate test engagement data
  Future<Map<String, dynamic>> generateTestEngagement(String userId) async {
    final token = await _authService.getToken();
    final timestamp = DateTime.now().toIso8601String();

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.engagementEndpoint}/test-engagement'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'timestamp': timestamp,
      }),
    );

    if (response.statusCode == 200) {
      print('Test engagement generated successfully');
      print('Response body: ${response.body}');
      return jsonDecode(response.body);
    } else {
      throw Exception('Failed to generate test engagement: ${response.body}');
    }
  }
}