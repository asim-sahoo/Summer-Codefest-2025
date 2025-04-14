import 'dart:convert';
import 'dart:io';
import 'dart:math'; // Add this for min function
import 'package:http/http.dart' as http;
import 'package:dio/dio.dart';
import 'package:http_parser/http_parser.dart';
import '../config/api_config.dart';
import '../models/post_model.dart';
import 'auth_service.dart';

class PostService {
  final AuthService _authService = AuthService();
  final Dio _dio = Dio();

  // Get timeline posts (posts from user and followed users)
  Future<List<Post>> getTimelinePosts() async {
    final token = await _authService.getToken();
    final userId = await _authService.getUserId();

    if (userId == null) {
      throw Exception('User not logged in');
    }

    // Remove spaces from userId and ensure proper URL formatting
    final cleanUserId = userId.trim();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.postEndpoint}/timeline/$cleanUserId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((post) => Post.fromJson(post)).toList();
    } else {
      throw Exception('Failed to get timeline posts: ${response.body}');
    }
  }

  // Get user posts
  Future<List<Post>> getUserPosts(String userId) async {
    final token = await _authService.getToken();

    // Clean the userId to ensure no spaces
    final cleanUserId = userId.trim();

    // Add debug logging
    print('Fetching posts for user: $cleanUserId');
    print('Request URL: ${ApiConfig.baseUrl}${ApiConfig.postEndpoint}/user/$cleanUserId');

    try {
      final response = await http.get(
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.postEndpoint}/user/$cleanUserId'),
        headers: {
          'Content-Type': 'application/json',
          'Authorization': 'Bearer $token',
        },
      );

      print('Response status code: ${response.statusCode}');
      print('Response body: ${response.body.substring(0, min(100, response.body.length))}...'); // Print first 100 chars

      if (response.statusCode == 200) {
        final List<dynamic> data = jsonDecode(response.body);
        return data.map((post) => Post.fromJson(post)).toList();
      } else {
        throw Exception('Failed to get user posts: ${response.body}');
      }
    } catch (e) {
      print('Error fetching user posts: $e');
      throw Exception('Failed to get user posts: $e');
    }
  }

  // Get a single post by ID
  Future<Post> getPostById(String postId) async {
    final token = await _authService.getToken();

    // Clean the postId to ensure no spaces
    final cleanPostId = postId.trim();

    final response = await http.get(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.postEndpoint}/$cleanPostId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Post.fromJson(data);
    } else {
      throw Exception('Failed to get post: ${response.body}');
    }
  }

  // Create a new post
  Future<Post> createPost(String desc, File? image, {ContentType contentType = ContentType.neutral}) async {
    final token = await _authService.getToken();
    final userId = await _authService.getUserId();

    if (userId == null) {
      throw Exception('User not logged in');
    }

    // If there's an image, upload it first
    String? imageUrl;
    if (image != null) {
      imageUrl = await _uploadImage(image);
    }

    final response = await http.post(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.postEndpoint}'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
        'desc': desc,
        'image': imageUrl,
        'contentType': contentTypeToString(contentType),
      }),
    );

    if (response.statusCode == 200) {
      final Map<String, dynamic> data = jsonDecode(response.body);
      return Post.fromJson(data);
    } else {
      throw Exception('Failed to create post: ${response.body}');
    }
  }

  // Upload image
  Future<String> _uploadImage(File image) async {
    final token = await _authService.getToken();
    final fileName = image.path.split('/').last;

    // Validate file type before upload
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final extension = fileName.split('.').last.toLowerCase();
    print('File extension: $extension'); // Add this line
    if (!validExtensions.contains(extension)) {
      throw Exception('Invalid file type. Only JPG, JPEG, PNG, GIF, and WEBP images are allowed.');
    }

    try {
      FormData formData = FormData.fromMap({
        "file": await MultipartFile.fromFile(
          image.path,
          filename: fileName,
          contentType: extension == 'jpg' || extension == 'jpeg'
              ? MediaType('image', 'jpeg')
              : extension == 'png'
                  ? MediaType('image', 'png')
                  : extension == 'gif'
                      ? MediaType('image', 'gif')
                      : extension == 'webp'
                          ? MediaType('image', 'webp')
                          : null, // Let Dio handle the content type if extension is unknown
        ),
        "name": fileName,  // Adding name parameter for server compatibility
      });

      // Configure Dio with timeout and retry options
      _dio.options.connectTimeout = const Duration(seconds: 15);
      _dio.options.receiveTimeout = const Duration(seconds: 30);

      final response = await _dio.post(
        '${ApiConfig.baseUrl}${ApiConfig.uploadEndpoint}',
        data: formData,
        options: Options(
          headers: {
            'Authorization': 'Bearer $token',
            'Content-Type': 'multipart/form-data',  // Explicitly set content type
          },
        ),
      );

      if (response.statusCode == 200) {
        print('Image uploaded successfully: ${response.data}');
        return response.data['imageUrl'] ?? fileName;
      } else {
        throw Exception('Server returned status code: ${response.statusCode}');
      }
    } on DioException catch (e) {
      print('Dio upload error: ${e.message}');
      print('Dio upload error type: ${e.type}');
      if (e.response != null) {
        print('Server response: ${e.response?.data}');
      }
      throw Exception('Failed to upload image: ${e.message}');
    } catch (e) {
      print('Unexpected upload error: $e');
      throw Exception('Failed to upload image: $e');
    }
  }

  // Like/unlike a post
  Future<void> likePost(String postId) async {
    final token = await _authService.getToken();
    final userId = await _authService.getUserId();

    if (userId == null) {
      throw Exception('User not logged in');
    }

    final response = await http.put(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.postEndpoint}/$postId/like'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({
        'userId': userId,
      }),
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to like/unlike post: ${response.body}');
    }
  }

  // Delete a post
  Future<void> deletePost(String postId) async {
    final token = await _authService.getToken();

    final response = await http.delete(
      Uri.parse('${ApiConfig.baseUrl}${ApiConfig.postEndpoint}/$postId'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode != 200) {
      throw Exception('Failed to delete post: ${response.body}');
    }
  }
}