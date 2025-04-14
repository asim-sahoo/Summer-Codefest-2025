import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../config/api_config.dart';

class ProfileImagePicker extends StatelessWidget {
  final File? imageFile;
  final String? networkImagePath;
  final Function(File) onImagePicked;
  final double radius;
  final String initials;
  final bool isCircular;
  final bool isCoverImage;

  const ProfileImagePicker({
    super.key,
    this.imageFile,
    this.networkImagePath,
    required this.onImagePicked,
    this.radius = 50,
    required this.initials,
    this.isCircular = true,
    this.isCoverImage = false,
  });

  Future<void> _pickImage(BuildContext context) async {
    final ImagePicker picker = ImagePicker();

    try {
      // Show image source options
      await showModalBottomSheet(
        context: context,
        builder: (BuildContext context) {
          return SafeArea(
            child: Column(
              mainAxisSize: MainAxisSize.min,
              children: <Widget>[
                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 16.0),
                  child: Text(
                    'Select Image Source',
                    style: TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
                ListTile(
                  leading: const Icon(Icons.photo_library, size: 28),
                  title: const Text('Photo Library'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  onTap: () async {
                    Navigator.of(context).pop();
                    _getImageFromSource(context, ImageSource.gallery);
                  },
                ),
                ListTile(
                  leading: const Icon(Icons.photo_camera, size: 28),
                  title: const Text('Camera'),
                  contentPadding: const EdgeInsets.symmetric(horizontal: 24.0, vertical: 8.0),
                  onTap: () async {
                    Navigator.of(context).pop();
                    _getImageFromSource(context, ImageSource.camera);
                  },
                ),
                const SizedBox(height: 16),
              ],
            ),
          );
        },
      );
    } catch (e) {
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to show image picker: $e')),
        );
      }
    }
  }

  Future<void> _getImageFromSource(BuildContext context, ImageSource source) async {
    try {
      final XFile? pickedImage = await ImagePicker().pickImage(
        source: source,
        imageQuality: 80,
        maxWidth: 1200,
      );

      if (pickedImage != null) {
        final imageFile = File(pickedImage.path);
        print('Image picked successfully: ${imageFile.path}');
        onImagePicked(imageFile);
      } else {
        print('No image selected');
      }
    } catch (e) {
      print('Error picking image: $e');
      if (context.mounted) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Failed to pick image: $e')),
        );
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    Widget imageWidget;

    if (isCoverImage) {
      if (imageFile != null) {
        imageWidget = Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            image: DecorationImage(
              image: FileImage(imageFile!),
              fit: BoxFit.cover,
            ),
          ),
        );
      } else if (networkImagePath != null && networkImagePath!.isNotEmpty) {
        final imageUrl = '${ApiConfig.baseUrl}/images/$networkImagePath';
        imageWidget = Container(
          height: 150,
          width: double.infinity,
          decoration: BoxDecoration(
            color: Colors.grey[300],
            image: DecorationImage(
              image: CachedNetworkImageProvider(imageUrl),
              fit: BoxFit.cover,
            ),
          ),
        );
      } else {
        imageWidget = Container(
          height: 150,
          width: double.infinity,
          color: Colors.grey[300],
          child: Center(
            child: Icon(
              Icons.image,
              size: 50,
              color: Colors.grey[600],
            ),
          ),
        );
      }

      return Stack(
        children: [
          imageWidget,
          Positioned.fill(
            child: Material(
              color: Colors.transparent,
              child: InkWell(
                onTap: () => _pickImage(context),
                child: Container(
                  alignment: Alignment.center,
                  child: Icon(
                    Icons.camera_alt,
                    color: Colors.white,
                    size: 30,
                    shadows: [
                      Shadow(
                        blurRadius: 10.0,
                        color: Colors.black.withOpacity(0.5),
                        offset: const Offset(0, 0),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        ],
      );
    }

    // Regular profile image logic (not cover)
    if (imageFile != null) {
      // Show picked image
      imageWidget = isCircular
        ? CircleAvatar(
            radius: radius,
            backgroundImage: FileImage(imageFile!),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              imageFile!,
              fit: BoxFit.cover,
              width: radius * 2,
              height: radius * 2,
            ),
          );
    } else if (networkImagePath != null && networkImagePath!.isNotEmpty) {
      // Show network image
      final imageUrl = '${ApiConfig.baseUrl}/images/$networkImagePath';
      imageWidget = isCircular
        ? CircleAvatar(
            radius: radius,
            backgroundImage: CachedNetworkImageProvider(imageUrl),
          )
        : ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: CachedNetworkImage(
              imageUrl: imageUrl,
              fit: BoxFit.cover,
              width: radius * 2,
              height: radius * 2,
              placeholder: (context, url) => Container(
                color: Colors.grey[300],
                child: const Center(child: CircularProgressIndicator()),
              ),
              errorWidget: (context, url, error) => Container(
                color: Colors.grey[300],
                child: const Center(child: Icon(Icons.error)),
              ),
            ),
          );
    } else {
      // Show placeholder with initials
      imageWidget = isCircular
        ? CircleAvatar(
            radius: radius,
            backgroundColor: Theme.of(context).primaryColor,
            child: Text(
              initials,
              style: TextStyle(
                color: Colors.white,
                fontSize: radius * 0.6,
                fontWeight: FontWeight.bold,
              ),
            ),
          )
        : Container(
            width: radius * 2,
            height: radius * 2,
            decoration: BoxDecoration(
              color: Theme.of(context).primaryColor,
              borderRadius: BorderRadius.circular(8),
            ),
            child: Center(
              child: Text(
                initials,
                style: TextStyle(
                  color: Colors.white,
                  fontSize: radius * 0.6,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ),
          );
    }

    return Stack(
      children: [
        GestureDetector(
          onTap: () => _pickImage(context),
          child: imageWidget,
        ),
        Positioned(
          bottom: 0,
          right: 0,
          child: GestureDetector(
            onTap: () => _pickImage(context),
            child: Container(
              width: radius * 0.8,
              height: radius * 0.8,
              decoration: BoxDecoration(
                color: Theme.of(context).primaryColor,
                shape: BoxShape.circle,
                border: Border.all(color: Colors.white, width: 2),
                boxShadow: [
                  BoxShadow(
                    color: Colors.black.withOpacity(0.2),
                    spreadRadius: 1,
                    blurRadius: 3,
                    offset: const Offset(0, 1),
                  ),
                ],
              ),
              child: Icon(
                Icons.camera_alt,
                size: radius * 0.4,
                color: Colors.white,
              ),
            ),
          ),
        ),
      ],
    );
  }
}