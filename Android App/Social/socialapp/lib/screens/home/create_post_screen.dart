import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import '../../services/post_service.dart';
import '../../services/activity_service.dart';
import '../../config/app_theme.dart';
import '../../widgets/loading_animation.dart';
import '../../models/post_model.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  _CreatePostScreenState createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _descriptionController = TextEditingController();
  final PostService _postService = PostService();
  final ActivityService _activityService = ActivityService();
  final FocusNode _focusNode = FocusNode();
  File? _image;
  bool _isUploading = false;
  String _errorMessage = '';
  bool _hasContent = false;
  ContentType _selectedContentType = ContentType.neutral; // Default to neutral

  @override
  void initState() {
    super.initState();
    _descriptionController.addListener(_checkContent);

    // Auto focus on the text field when screen loads
    WidgetsBinding.instance.addPostFrameCallback((_) {
      _focusNode.requestFocus();
    });
  }

  @override
  void dispose() {
    _descriptionController.removeListener(_checkContent);
    _descriptionController.dispose();
    _focusNode.dispose();
    super.dispose();
  }

  void _checkContent() {
    final hasText = _descriptionController.text.trim().isNotEmpty;
    if (hasText != _hasContent) {
      setState(() {
        _hasContent = hasText;
      });
    }
  }

  Future<void> _pickImage() async {
    final ImagePicker picker = ImagePicker();

    // Show a bottom sheet with camera and gallery options
    showModalBottomSheet(
      context: context,
      backgroundColor: Theme.of(context).brightness == Brightness.dark
          ? AppTheme.surfaceColorDark
          : Colors.white,
      shape: const RoundedRectangleBorder(
        borderRadius: BorderRadius.vertical(top: Radius.circular(20)),
      ),
      builder: (context) => SafeArea(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              margin: const EdgeInsets.symmetric(vertical: 8),
              height: 4,
              width: 40,
              decoration: BoxDecoration(
                color: Colors.grey.withOpacity(0.3),
                borderRadius: BorderRadius.circular(4),
              ),
            ),
            ListTile(
              leading: const Icon(Icons.camera_alt_rounded),
              title: const Text('Take a photo'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? photo = await picker.pickImage(source: ImageSource.camera);
                if (photo != null) {
                  setState(() {
                    _image = File(photo.path);
                  });
                }
              },
            ),
            ListTile(
              leading: const Icon(Icons.photo_library_rounded),
              title: const Text('Choose from gallery'),
              onTap: () async {
                Navigator.pop(context);
                final XFile? image = await picker.pickImage(source: ImageSource.gallery);
                if (image != null) {
                  setState(() {
                    _image = File(image.path);
                  });
                }
              },
            ),
            const SizedBox(height: 8),
          ],
        ),
      ),
    );
  }

  Future<void> _createPost() async {
    final description = _descriptionController.text.trim();

    if (description.isEmpty && _image == null) {
      setState(() {
        _errorMessage = 'Please add a description or an image';
      });
      return;
    }

    setState(() {
      _isUploading = true;
      _errorMessage = '';
    });

    try {
      await _postService.createPost(
        description,
        _image,
        contentType: _selectedContentType, // Pass the selected content type
      );
      _activityService.incrementInteractions();

      if (mounted) {
        // Clear form after successful post
        _descriptionController.clear();
        setState(() {
          _image = null;
          _selectedContentType = ContentType.neutral; // Reset content type
        });

        // Show success message with custom style
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(
            content: Row(
              children: [
                Icon(
                  Icons.check_circle_outline_rounded,
                  color: Colors.white,
                ),
                const SizedBox(width: 12),
                const Text(
                  'Post shared successfully!',
                  style: TextStyle(
                    fontWeight: FontWeight.w500,
                  ),
                ),
              ],
            ),
            backgroundColor: Colors.green.shade600,
            behavior: SnackBarBehavior.floating,
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
            margin: EdgeInsets.only(
              bottom: MediaQuery.of(context).size.height * 0.1,
              left: 16,
              right: 16,
            ),
            duration: const Duration(seconds: 3),
          ),
        );
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'Failed to create post: ${e.toString()}';
      });
    } finally {
      setState(() {
        _isUploading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppTheme.backgroundColorDark : AppTheme.backgroundColorLight;
    final surfaceColor = isDarkMode ? AppTheme.surfaceColorDark : Colors.white;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;
    final primaryColor = isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor;
    final hintColor = isDarkMode
        ? AppTheme.darkTextColor.withOpacity(0.6)
        : AppTheme.lightTextColor.withOpacity(0.6);

    return Scaffold(
      backgroundColor: backgroundColor,
      appBar: AppBar(
        backgroundColor: backgroundColor,
        elevation: 0,
        title: Text(
          'Create Post',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        centerTitle: true,
        actions: [
          // Post button in the app bar
          Padding(
            padding: const EdgeInsets.only(right: 8.0),
            child: _isUploading
                ? Padding(
                    padding: const EdgeInsets.all(8.0),
                    child: LoadingAnimation(
                      size: 24,
                      primaryColor: primaryColor,
                    ),
                  )
                : TextButton(
                    onPressed: (_hasContent || _image != null) && !_isUploading
                        ? _createPost
                        : null,
                    style: TextButton.styleFrom(
                      backgroundColor: (_hasContent || _image != null)
                          ? primaryColor
                          : Colors.grey.withOpacity(0.2),
                      foregroundColor: (_hasContent || _image != null)
                          ? (isDarkMode ? Colors.black : Colors.white)
                          : hintColor,
                      shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(20),
                      ),
                      padding: const EdgeInsets.symmetric(
                        horizontal: 16,
                        vertical: 8,
                      ),
                    ),
                    child: const Text(
                      'Share',
                      style: TextStyle(
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
          ),
        ],
      ),
      body: GestureDetector(
        onTap: () {
          // Dismiss keyboard when tapping outside
          FocusScope.of(context).unfocus();
        },
        child: SafeArea(
          child: SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 16.0),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                // Error message
                if (_errorMessage.isNotEmpty)
                  Container(
                    margin: const EdgeInsets.only(top: 8, bottom: 16),
                    padding: const EdgeInsets.symmetric(
                      horizontal: 16,
                      vertical: 10,
                    ),
                    decoration: BoxDecoration(
                      color: theme.colorScheme.error.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                      border: Border.all(
                        color: theme.colorScheme.error.withOpacity(0.3),
                        width: 1,
                      ),
                    ),
                    child: Row(
                      children: [
                        Icon(
                          Icons.error_outline_rounded,
                          color: theme.colorScheme.error,
                          size: 20,
                        ),
                        const SizedBox(width: 12),
                        Expanded(
                          child: Text(
                            _errorMessage,
                            style: TextStyle(
                              color: theme.colorScheme.error,
                              fontSize: 14,
                            ),
                          ),
                        ),
                      ],
                    ),
                  ),

                // Content type selector
                Card(
                  elevation: 0,
                  color: surfaceColor,
                  margin: const EdgeInsets.only(top: 8, bottom: 16),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDarkMode
                          ? Colors.grey.shade800.withOpacity(0.5)
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                          "Content Mood",
                          style: TextStyle(
                            color: textColor,
                            fontWeight: FontWeight.w600,
                            fontSize: 15,
                          ),
                        ),
                        const SizedBox(height: 8),
                        DropdownButtonFormField<ContentType>(
                          value: _selectedContentType,
                          decoration: InputDecoration(
                            filled: true,
                            fillColor: isDarkMode
                                ? Colors.grey.shade800.withOpacity(0.3)
                                : Colors.grey.shade100,
                            border: OutlineInputBorder(
                              borderRadius: BorderRadius.circular(12),
                              borderSide: BorderSide.none,
                            ),
                            contentPadding: const EdgeInsets.symmetric(
                              horizontal: 16,
                              vertical: 12,
                            ),
                          ),
                          style: TextStyle(
                            color: textColor,
                            fontSize: 15,
                          ),
                          dropdownColor: surfaceColor,
                          items: [
                            DropdownMenuItem(
                              value: ContentType.uplifting,
                              child: Row(
                                children: [
                                  Icon(Icons.sentiment_very_satisfied,
                                    color: Colors.green,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text('Uplifting'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: ContentType.neutral,
                              child: Row(
                                children: [
                                  Icon(Icons.sentiment_neutral,
                                    color: Colors.blue,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text('Neutral'),
                                ],
                              ),
                            ),
                            DropdownMenuItem(
                              value: ContentType.sensitive,
                              child: Row(
                                children: [
                                  Icon(Icons.sentiment_dissatisfied,
                                    color: Colors.orange,
                                    size: 20,
                                  ),
                                  const SizedBox(width: 10),
                                  Text('Sensitive'),
                                ],
                              ),
                            ),
                          ],
                          onChanged: (value) {
                            if (value != null) {
                              setState(() {
                                _selectedContentType = value;
                              });
                            }
                          },
                        ),
                        const SizedBox(height: 8),
                        Text(
                          "Tag your post to help users filter their feed",
                          style: TextStyle(
                            color: textColor.withOpacity(0.6),
                            fontSize: 12,
                            fontStyle: FontStyle.italic,
                          ),
                        ),
                      ],
                    ),
                  ),
                ),

                // Post input card
                Card(
                  elevation: 0,
                  color: surfaceColor,
                  margin: const EdgeInsets.only(top: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(16),
                    side: BorderSide(
                      color: isDarkMode
                          ? Colors.grey.shade800.withOpacity(0.5)
                          : Colors.grey.shade200,
                      width: 1,
                    ),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.all(16.0),
                    child: ConstrainedBox(
                      constraints: BoxConstraints(
                        minHeight: 100,
                        maxHeight: 300,
                      ),
                        child: SingleChildScrollView(
                        child: TextField(
                          controller: _descriptionController,
                          // focusNode: _focusNode,
                          decoration: InputDecoration(
                          hintText: "What's on your mind?",
                          border: InputBorder.none,
                          hintStyle: TextStyle(
                            color: hintColor,
                            fontSize: 16,
                          ),
                          contentPadding: const EdgeInsets.symmetric(
                            vertical: 12.0,
                            horizontal: 16.0,
                          ),
                          isCollapsed: false,
                          ),
                          maxLines: null, // Allow unlimited lines
                          minLines: 3,
                          style: TextStyle(
                          color: textColor,
                          fontSize: 16,
                          height: 1.4,
                          ),
                          textCapitalization: TextCapitalization.sentences,
                          keyboardType: TextInputType.multiline,
                          textInputAction: TextInputAction.newline,
                        ),
                        ),
                      ),
                      ),
                    ),

                    // Image preview
                    if (_image != null)
                      Container(
                    margin: const EdgeInsets.only(top: 16),
                    decoration: BoxDecoration(
                      borderRadius: BorderRadius.circular(16),
                      boxShadow: [
                        BoxShadow(
                          color: Colors.black.withOpacity(0.1),
                          blurRadius: 8,
                          offset: const Offset(0, 2),
                        ),
                      ],
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(16),
                      child: Stack(
                        alignment: Alignment.topRight,
                        children: [
                          Image.file(
                            _image!,
                            height: 300,
                            width: double.infinity,
                            fit: BoxFit.cover,
                          ),
                          Material(
                            color: Colors.transparent,
                            child: InkWell(
                              onTap: () {
                                setState(() {
                                  _image = null;
                                });
                              },
                              child: Container(
                                margin: const EdgeInsets.all(8),
                                padding: const EdgeInsets.all(4),
                                decoration: BoxDecoration(
                                  color: Colors.black.withOpacity(0.6),
                                  shape: BoxShape.circle,
                                ),
                                child: const Icon(
                                  Icons.close_rounded,
                                  color: Colors.white,
                                  size: 20,
                                ),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),

                const SizedBox(height: 16),

                // Bottom action buttons
                Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8.0),
                  child: Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _ActionButton(
                        icon: Icons.photo_rounded,
                        label: 'Photo',
                        onTap: _pickImage,
                        color: Colors.green,
                      ),
                      _ActionButton(
                        icon: Icons.location_on_rounded,
                        label: 'Location',
                        onTap: () {
                          // To be implemented
                        },
                        color: Colors.red,
                      ),
                      _ActionButton(
                        icon: Icons.tag_rounded,
                        label: 'Tag',
                        onTap: () {
                          // To be implemented
                        },
                        color: Colors.blue,
                      ),
                      _ActionButton(
                        icon: Icons.emoji_emotions_rounded,
                        label: 'Feeling',
                        onTap: () {
                          // To be implemented
                        },
                        color: Colors.orange,
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}

class _ActionButton extends StatelessWidget {
  final IconData icon;
  final String label;
  final VoidCallback onTap;
  final Color color;

  const _ActionButton({
    required this.icon,
    required this.label,
    required this.onTap,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    final isDarkMode = Theme.of(context).brightness == Brightness.dark;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;

    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(12),
      child: Padding(
        padding: const EdgeInsets.symmetric(horizontal: 12.0, vertical: 8.0),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              padding: const EdgeInsets.all(8),
              decoration: BoxDecoration(
                color: color.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: Icon(
                icon,
                color: color,
                size: 20,
              ),
            ),
            const SizedBox(height: 4),
            Text(
              label,
              style: TextStyle(
                fontSize: 12,
                color: textColor.withOpacity(0.8),
                fontWeight: FontWeight.w500,
              ),
            ),
          ],
        ),
      ),
    );
  }
}