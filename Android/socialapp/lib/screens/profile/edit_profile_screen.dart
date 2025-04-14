import 'dart:io';
import 'package:flutter/material.dart';
import '../../models/user_model.dart';
import '../../services/user_service.dart';
import '../../services/upload_service.dart';
import '../../widgets/profile/profile_image_picker.dart';

class EditProfileScreen extends StatefulWidget {
  final User user;

  const EditProfileScreen({super.key, required this.user});

  @override
  _EditProfileScreenState createState() => _EditProfileScreenState();
}

class _EditProfileScreenState extends State<EditProfileScreen> {
  final _formKey = GlobalKey<FormState>();
  final UserService _userService = UserService();
  final UploadService _uploadService = UploadService();

  late TextEditingController _firstnameController;
  late TextEditingController _lastnameController;
  late TextEditingController _aboutController;
  late TextEditingController _livesInController;
  late TextEditingController _worksAtController;
  late TextEditingController _relationshipController;
  late TextEditingController _countryController;

  File? _profileImage;
  File? _coverImage;
  bool _isLoading = false;
  String _errorMessage = '';

  @override
  void initState() {
    super.initState();
    _firstnameController = TextEditingController(text: widget.user.firstname);
    _lastnameController = TextEditingController(text: widget.user.lastname);
    _aboutController = TextEditingController(text: widget.user.about);
    _livesInController = TextEditingController(text: widget.user.livesin);
    _worksAtController = TextEditingController(text: widget.user.worksAt);
    _relationshipController = TextEditingController(text: widget.user.relationship);
    _countryController = TextEditingController(text: widget.user.country);
  }

  @override
  void dispose() {
    _firstnameController.dispose();
    _lastnameController.dispose();
    _aboutController.dispose();
    _livesInController.dispose();
    _worksAtController.dispose();
    _relationshipController.dispose();
    _countryController.dispose();
    super.dispose();
  }

  Future<void> _updateProfile() async {
    if (_formKey.currentState!.validate()) {
      setState(() {
        _isLoading = true;
        _errorMessage = '';
      });

      try {
        // Prepare user data to update
        Map<String, dynamic> userData = {
          'firstname': _firstnameController.text.trim(),
          'lastname': _lastnameController.text.trim(),
          'about': _aboutController.text.trim(),
          'livesin': _livesInController.text.trim(),
          'worksAt': _worksAtController.text.trim(),
          'relationship': _relationshipController.text.trim(),
          'country': _countryController.text.trim(),
        };

        // Handle image uploads
        if (_profileImage != null) {
          try {
            final profileImageUrl = await _uploadService.uploadImage(_profileImage!);
            userData['profilePicture'] = profileImageUrl;
          } catch (e) {
            print('Failed to upload profile image: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to upload profile image: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }

        if (_coverImage != null) {
          try {
            final coverImageUrl = await _uploadService.uploadImage(_coverImage!);
            userData['coverPicture'] = coverImageUrl;
          } catch (e) {
            print('Failed to upload cover image: $e');
            if (mounted) {
              ScaffoldMessenger.of(context).showSnackBar(
                SnackBar(
                  content: Text('Failed to upload cover image: ${e.toString()}'),
                  backgroundColor: Colors.red,
                ),
              );
            }
          }
        }

        // Update user
        await _userService.updateUser(widget.user.id, userData);

        if (mounted) {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Profile updated successfully!'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.pop(context);
        }
      } catch (e) {
        setState(() {
          _errorMessage = 'Failed to update profile: ${e.toString()}';
        });
      } finally {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Profile'),
        actions: [
          Padding(
            padding: const EdgeInsets.symmetric(vertical: 8.0, horizontal: 16.0),
            child: ElevatedButton(
              onPressed: _isLoading ? null : _updateProfile,
              style: ElevatedButton.styleFrom(
                backgroundColor: Theme.of(context).primaryColor,
                foregroundColor: Colors.white,
                shape: RoundedRectangleBorder(
                  borderRadius: BorderRadius.circular(20),
                ),
                elevation: 2,
                padding: const EdgeInsets.symmetric(horizontal: 16.0),
              ),
              child: _isLoading
                  ? const SizedBox(
                      width: 20,
                      height: 20,
                      child: CircularProgressIndicator(
                        strokeWidth: 2,
                        color: Colors.white,
                      ),
                    )
                  : const Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        Icon(Icons.check, size: 18),
                        SizedBox(width: 4),
                        Text(
                          'Save',
                          style: TextStyle(
                            fontWeight: FontWeight.bold,
                            fontSize: 14,
                          ),
                        ),
                      ],
                    ),
            ),
          ),
        ],
      ),
      body: SingleChildScrollView(
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Cover photo with edit button
              Stack(
                clipBehavior: Clip.none,
                alignment: Alignment.bottomLeft,
                children: [
                  // Cover Image
                  ProfileImagePicker(
                    networkImagePath: widget.user.coverPicture,
                    imageFile: _coverImage,
                    onImagePicked: (file) {
                      setState(() {
                        _coverImage = file;
                      });
                    },
                    radius: 50,
                    initials: '',
                    isCircular: false,
                    isCoverImage: true,
                  ),

                  // Profile Image
                  Positioned(
                    bottom: -50,
                    left: 20,
                    child: ProfileImagePicker(
                      networkImagePath: widget.user.profilePicture,
                      imageFile: _profileImage,
                      onImagePicked: (file) {
                        setState(() {
                          _profileImage = file;
                        });
                      },
                      radius: 50,
                      initials: widget.user.firstname.isNotEmpty && widget.user.lastname.isNotEmpty
                          ? widget.user.firstname[0] + widget.user.lastname[0]
                          : 'U',
                    ),
                  ),
                ],
              ),

              const SizedBox(height: 60),

              // Error message
              if (_errorMessage.isNotEmpty)
                Padding(
                  padding: const EdgeInsets.all(16.0),
                  child: Container(
                    padding: const EdgeInsets.all(8.0),
                    color: Colors.red.withOpacity(0.1),
                    child: Text(
                      _errorMessage,
                      style: const TextStyle(color: Colors.red),
                    ),
                  ),
                ),

              // Form fields
              Padding(
                padding: const EdgeInsets.all(16.0),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    const Text(
                      'Basic Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // First Name
                    TextFormField(
                      controller: _firstnameController,
                      decoration: const InputDecoration(
                        labelText: 'First Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your first name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // Last Name
                    TextFormField(
                      controller: _lastnameController,
                      decoration: const InputDecoration(
                        labelText: 'Last Name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (value) {
                        if (value == null || value.isEmpty) {
                          return 'Please enter your last name';
                        }
                        return null;
                      },
                    ),
                    const SizedBox(height: 16),

                    // About
                    TextFormField(
                      controller: _aboutController,
                      decoration: const InputDecoration(
                        labelText: 'About',
                        border: OutlineInputBorder(),
                      ),
                      maxLines: 3,
                    ),

                    const SizedBox(height: 24),
                    const Text(
                      'Personal Information',
                      style: TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.bold,
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Lives in
                    TextFormField(
                      controller: _livesInController,
                      decoration: const InputDecoration(
                        labelText: 'Lives in',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.location_on),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Works At
                    TextFormField(
                      controller: _worksAtController,
                      decoration: const InputDecoration(
                        labelText: 'Works at',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.work),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Relationship
                    TextFormField(
                      controller: _relationshipController,
                      decoration: const InputDecoration(
                        labelText: 'Relationship Status',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.favorite),
                      ),
                    ),
                    const SizedBox(height: 16),

                    // Country
                    TextFormField(
                      controller: _countryController,
                      decoration: const InputDecoration(
                        labelText: 'Country',
                        border: OutlineInputBorder(),
                        prefixIcon: Icon(Icons.flag),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}