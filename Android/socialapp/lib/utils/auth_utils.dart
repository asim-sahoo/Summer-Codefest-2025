// A utility class that provides easy access to authentication functions
// This is a static wrapper around AuthService for convenience
import 'package:shared_preferences/shared_preferences.dart';
import '../services/auth_service.dart';

class AuthUtils {
  static final AuthService _authService = AuthService();

  // Get the current user's token
  static Future<String?> getToken() async {
    return await _authService.getToken();
  }

  // Get the current user's ID
  static Future<String?> getUserId() async {
    return await _authService.getUserId();
  }

  // Check if user is logged in
  static Future<bool> isLoggedIn() async {
    return await _authService.isLoggedIn();
  }

  // Save a value to shared preferences
  static Future<void> saveToPrefs(String key, String value) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.setString(key, value);
  }

  // Get a value from shared preferences
  static Future<String?> getFromPrefs(String key) async {
    final prefs = await SharedPreferences.getInstance();
    return prefs.getString(key);
  }

  // Clear a value from shared preferences
  static Future<void> removeFromPrefs(String key) async {
    final prefs = await SharedPreferences.getInstance();
    await prefs.remove(key);
  }
}