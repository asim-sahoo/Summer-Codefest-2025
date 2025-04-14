import 'dart:io';
import 'dart:convert';
import 'dart:math';
import 'package:http/http.dart' as http;
import 'package:http_parser/http_parser.dart';
import 'package:path/path.dart' as path;
import '../config/api_config.dart';
import '../services/auth_service.dart';

class UploadService {
  final AuthService _authService = AuthService();

  // Upload image to the server and return the filename
  Future<String> uploadImage(File imageFile) async {
    // Get token for authentication
    final token = await _authService.getToken();
    if (token == null) {
      throw Exception('Authentication required');
    }

    // Validate file type before upload
    final validExtensions = ['jpg', 'jpeg', 'png', 'gif', 'webp'];
    final fileExtension = path.extension(imageFile.path).toLowerCase();
    print('File extension: $fileExtension'); // Add this line
    if (!validExtensions.contains(fileExtension.substring(1))) {
      throw Exception('Invalid file type. Only JPG, JPEG, PNG, GIF, and WEBP images are allowed.');
    }

    try {
      // Check file size (limit to 10MB)
      final fileSize = await imageFile.length();
      if (fileSize > 10 * 1024 * 1024) {
        throw Exception('Image size exceeds 10MB limit');
      }

      // Get file extension and MIME type
      final mimeType = _getMimeType(fileExtension);

      // Generate a unique filename using timestamp and random numbers
      final timestamp = DateTime.now().millisecondsSinceEpoch;
      final random = Random().nextInt(10000);
      final fileName = '$timestamp$random$fileExtension';

      // Create multipart request
      var request = http.MultipartRequest(
        'POST',
        Uri.parse('${ApiConfig.baseUrl}${ApiConfig.uploadEndpoint}'),
      );

      // Add name field to the request fields (required by the server)
      request.fields['name'] = fileName;

      // Add authorization header
      request.headers.addAll({
        'Authorization': 'Bearer $token',
        'Accept': 'application/json',
      });

      // Add file to upload with correct content type
      request.files.add(
        http.MultipartFile(
          'file', // Changed from 'image' to 'file' to match server expectation
          imageFile.readAsBytes().asStream(),
          fileSize,
          filename: fileName,
          contentType: mimeType,
        ),
      );

      // Send the request with timeout
      var response = await request.send().timeout(
            const Duration(seconds: 30),
            onTimeout: () {
              throw Exception('Upload timed out. Please try again.');
            },
          );

      // Check if upload was successful
      if (response.statusCode == 200) {
        // Parse response
        final responseData = await response.stream.bytesToString();
        final Map<String, dynamic> data = json.decode(responseData);

        // Return the filename
        return data['imageUrl'] ?? fileName;
      } else {
        // Get response body for better error reporting
        final errorBody = await response.stream.bytesToString();
        print('Server error: $errorBody');
        throw Exception('Failed to upload image: ${response.statusCode} - $errorBody');
      }
    } catch (e) {
      print('Upload error: $e');
      if (e is Exception) {
        rethrow;
      }
      throw Exception('Failed to upload image: $e');
    }
  }

  // Helper method to determine MIME type from file extension
  MediaType _getMimeType(String extension) {
    switch (extension) {
      case '.jpg':
      case '.jpeg':
        return MediaType('image', 'jpeg');
      case '.png':
        return MediaType('image', 'png');
      case '.gif':
        return MediaType('image', 'gif');
      case '.webp':
        return MediaType('image', 'webp');
      case '.heic':
      case '.heif':
        return MediaType('image', 'heic');
      default:
        return MediaType('application', 'octet-stream');
    }
  }
}