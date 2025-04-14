import 'package:flutter/material.dart';
import '../config/api_config.dart';

class ImageUtils {
  /// Formats an image URL correctly for network usage
  ///
  /// Handles different image formats including:
  /// - Regular filenames
  /// - Base64 encoded images
  /// - Filenames with spaces or special characters
  static String getImageUrl(String? imagePath) {
    if (imagePath == null || imagePath.isEmpty) {
      return '${ApiConfig.baseUrl}/images/defaultProfile.png';
    }

    // Check if this is a base64 image
    if (imagePath.startsWith('data:image')) {
      return imagePath; // Return base64 data as is
    }

    // Handle URL encoding for special characters
    String encodedPath = Uri.encodeComponent(imagePath);

    return '${ApiConfig.baseUrl}/images/$encodedPath';
  }

  /// Gets a profile picture URL, with a default fallback
  static String getProfilePictureUrl(String? profilePicture) {
    return getImageUrl(profilePicture!.isEmpty ? 'defaultProfile.png' : profilePicture);
  }

  /// Gets a cover picture URL, with a default fallback
  static String getCoverPictureUrl(String? coverPicture) {
    return getImageUrl(coverPicture!.isEmpty ? 'defaultCover.jpg' : coverPicture);
  }

  /// Placeholder widget to show when an image fails to load
  static Widget buildErrorPlaceholder(BuildContext context, {double size = 48.0}) {
    return Container(
      color: Theme.of(context).colorScheme.primary.withOpacity(0.1),
      child: Center(
        child: Icon(
          Icons.image_not_supported_outlined,
          color: Theme.of(context).colorScheme.onSurface.withOpacity(0.6),
          size: size,
        ),
      ),
    );
  }
}