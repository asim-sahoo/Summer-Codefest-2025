// filepath: d:\Files\Code\flutter_projects\Social\socialapp\lib\services\feedback_digest_service.dart
import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import '../models/feedback_digest_model.dart';
import '../utils/api_constants.dart';
import '../utils/auth_utils.dart';

class FeedbackDigestService {
  final String baseUrl = ApiConstants.baseUrl;

  // Cache mechanism for quicker updates
  FeedbackDigestModel? _cachedDigest;
  final Map<String, int> _pendingReactions = {
    'like': 0,
    'heart': 0,
    'smile': 0,
    'fire': 0,
  };
  int _pendingComments = 0;

  // For setting up notification at the end of day
  DateTime? _lastEndOfDayNotification;

  // Fetch the daily digest from the server
  Future<FeedbackDigestModel> getDailyDigest() async {
    try {
      // Get user credentials using AuthUtils
      String? token = await AuthUtils.getToken();
      String? userId = await AuthUtils.getUserId();

      // For testing, if there's no user ID, use a hardcoded test ID
      userId = userId ?? 'test-user-id';

      // Headers with optional authentication
      Map<String, String> headers = {
        'Content-Type': 'application/json',
      };

      // Add token if available
      if (token != null) {
        headers['Authorization'] = 'Bearer $token';
      }

      print("Attempting to get digest for userId: $userId");

      final response = await http.get(
        Uri.parse('$baseUrl/engagement/digest/$userId'),
        headers: headers,
      );

      if (response.statusCode == 200) {
        print("Successfully received digest data");
        Map<String, dynamic> responseData = json.decode(response.body);
        Map<String, dynamic> engagementData = responseData['engagementData'];

        // Add today's date to the data
        engagementData['date'] = DateTime.now().toIso8601String();

        // Create and cache the digest
        final digest = FeedbackDigestModel.fromJson(engagementData);
        _cachedDigest = digest;

        // Reset pending counts after successful refresh
        _resetPendingCounts();

        return digest;
      } else {
        print("Failed to load digest: ${response.statusCode}");
        print("Response body: ${response.body}");
        throw Exception('Failed to load digest: ${response.statusCode}');
      }
    } catch (e) {
      print('Error fetching daily digest: $e');

      // If we have a cached version, return that with pending updates
      if (_cachedDigest != null) {
        return _getUpdatedDigestWithPending();
      }

      return FeedbackDigestModel.empty();
    }
  }

  // Record a reaction to a post with local caching for immediate feedback
  Future<bool> recordReaction(String postUserId, String reactionType, String postId) async {
    try {
      // Increment local pending count for immediate feedback
      _incrementPendingReaction(reactionType);

      String? token = await AuthUtils.getToken();
      String? userId = await AuthUtils.getUserId();

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/engagement/reaction'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userId': postUserId,
          'reactedByUserId': userId,
          'reactionType': reactionType,
          'postId': postId
        }),
      );

      // If server request failed, decrement the pending count
      if (response.statusCode != 200) {
        _decrementPendingReaction(reactionType);
      }

      return response.statusCode == 200;
    } catch (e) {
      print('Error recording reaction: $e');
      // Revert the pending increment on error
      _decrementPendingReaction(reactionType);
      return false;
    }
  }

  // Record a comment with local caching
  Future<bool> recordComment(String postUserId, String commentText, String postId) async {
    try {
      // Increment local pending count
      _pendingComments++;

      String? token = await AuthUtils.getToken();
      String? userId = await AuthUtils.getUserId();

      if (token == null || userId == null) {
        throw Exception('User not authenticated');
      }

      final response = await http.post(
        Uri.parse('$baseUrl/engagement/comment'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
        body: json.encode({
          'userId': postUserId,
          'commentedByUserId': userId,
          'commentText': commentText,
          'postId': postId
        }),
      );

      // If server request failed, decrement the pending count
      if (response.statusCode != 200) {
        _pendingComments--;
      }

      return response.statusCode == 200;
    } catch (e) {
      print('Error recording comment: $e');
      // Revert the pending increment on error
      _pendingComments--;
      return false;
    }
  }

  // Save digest locally for offline access
  Future<void> saveDigestLocally(FeedbackDigestModel digest) async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();

      // Convert digest to JSON string
      Map<String, dynamic> digestMap = {
        'likesReceived': digest.likesReceived,
        'commentsReceived': digest.commentsReceived,
        'reactionsReceived': digest.reactionsReceived,
        'uniqueEngagers': digest.uniqueEngagers,
        'messages': digest.messages,
        'date': digest.date.toIso8601String(),
      };

      String digestJson = json.encode(digestMap);
      await prefs.setString('latest_digest', digestJson);

      // Save the timestamp of when we last fetched the digest
      await prefs.setInt('last_digest_fetch', DateTime.now().millisecondsSinceEpoch);

      // Cache the digest
      _cachedDigest = digest;
    } catch (e) {
      print('Error saving digest locally: $e');
    }
  }

  // Get the latest digest from local storage
  Future<FeedbackDigestModel?> getLocalDigest() async {
    try {
      // If we have a cached digest with pending updates, return that first
      if (_cachedDigest != null) {
        return _getUpdatedDigestWithPending();
      }

      SharedPreferences prefs = await SharedPreferences.getInstance();
      String? digestJson = prefs.getString('latest_digest');

      if (digestJson != null) {
        Map<String, dynamic> digestMap = json.decode(digestJson);
        final digest = FeedbackDigestModel.fromJson(digestMap);
        _cachedDigest = digest;
        return _getUpdatedDigestWithPending();
      }

      return null;
    } catch (e) {
      print('Error getting local digest: $e');
      return null;
    }
  }

  // Check if we should fetch a new digest
  Future<bool> shouldFetchNewDigest() async {
    try {
      SharedPreferences prefs = await SharedPreferences.getInstance();
      int? lastFetch = prefs.getInt('last_digest_fetch');

      if (lastFetch == null) {
        return true;
      }

      DateTime lastFetchDate = DateTime.fromMillisecondsSinceEpoch(lastFetch);
      DateTime now = DateTime.now();

      // Fetch new data if it's been more than 15 minutes since the last fetch
      if (now.difference(lastFetchDate).inMinutes > 15) {
        return true;
      }

      // Also fetch new data if the day has changed
      DateTime lastFetchDay = DateTime(lastFetchDate.year, lastFetchDate.month, lastFetchDate.day);
      DateTime today = DateTime(now.year, now.month, now.day);
      return lastFetchDay.isBefore(today);
    } catch (e) {
      print('Error checking if should fetch new digest: $e');
      return true;
    }
  }

  // Check if it's time to show end of day summary
  Future<bool> shouldShowEndOfDaySummary() async {
    final now = DateTime.now();

    // Only show end of day summary once per day and after 8 PM
    if (_lastEndOfDayNotification != null) {
      final lastDate = DateTime(_lastEndOfDayNotification!.year,
                              _lastEndOfDayNotification!.month,
                              _lastEndOfDayNotification!.day);
      final today = DateTime(now.year, now.month, now.day);

      if (lastDate.isAtSameMomentAs(today)) {
        return false; // Already shown today
      }
    }

    // Check if it's after 8 PM
    if (now.hour >= 20) {
      _lastEndOfDayNotification = now;
      return true;
    }

    return false;
  }

  // Test function to generate sample feedback data (for debugging)
  Future<bool> generateTestEngagement() async {
    try {
      String? userId = await AuthUtils.getUserId();

      // For testing, if there's no user ID in preferences, use a hardcoded test ID
      userId = userId ?? 'test-user-id';

      print("Attempting test with userId: $userId");

      // Call the test endpoint without authentication for simplicity
      final response = await http.get(
        Uri.parse('$baseUrl/engagement/test-engagement/$userId'),
      );

      if (response.statusCode == 200) {
        print("Test engagement generated successfully");
        print("Response body: ${response.body}");
        return true;
      } else {
        print("Error generating test engagement: ${response.statusCode}");
        print("Response body: ${response.body}");
        return false;
      }
    } catch (e) {
      print('Error generating test engagement: $e');
      return false;
    }
  }

  // Reset pending reaction and comment counts
  void _resetPendingCounts() {
    _pendingReactions['like'] = 0;
    _pendingReactions['heart'] = 0;
    _pendingReactions['smile'] = 0;
    _pendingReactions['fire'] = 0;
    _pendingComments = 0;
  }

  // Increment pending reaction count
  void _incrementPendingReaction(String reactionType) {
    if (_pendingReactions.containsKey(reactionType)) {
      _pendingReactions[reactionType] = (_pendingReactions[reactionType] ?? 0) + 1;
    }
  }

  // Decrement pending reaction count
  void _decrementPendingReaction(String reactionType) {
    if (_pendingReactions.containsKey(reactionType) &&
        (_pendingReactions[reactionType] ?? 0) > 0) {
      _pendingReactions[reactionType] = (_pendingReactions[reactionType] ?? 0) - 1;
    }
  }

  // Get updated digest with pending reactions and comments
  FeedbackDigestModel _getUpdatedDigestWithPending() {
    if (_cachedDigest == null) {
      return FeedbackDigestModel.empty();
    }

    // Create new reaction counts map with pending updates
    Map<String, int> updatedReactions = Map.from(_cachedDigest!.reactionsReceived);
    _pendingReactions.forEach((key, pendingCount) {
      updatedReactions[key] = (updatedReactions[key] ?? 0) + pendingCount;
    });

    // Calculate total likes (for backward compatibility)
    final totalLikes = _cachedDigest!.likesReceived + (_pendingReactions['like'] ?? 0);

    // Create an updated digest with pending changes
    return FeedbackDigestModel(
      likesReceived: totalLikes,
      commentsReceived: _cachedDigest!.commentsReceived + _pendingComments,
      reactionsReceived: updatedReactions,
      uniqueEngagers: _cachedDigest!.uniqueEngagers,
      messages: _cachedDigest!.messages,
      date: DateTime.now(),
    );
  }
}