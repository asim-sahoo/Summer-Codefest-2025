import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../models/post_model.dart';
import '../models/user_model.dart';
import '../config/api_config.dart';
import '../config/app_theme.dart';
import '../widgets/loading_animation.dart';
import '../utils/image_utils.dart';

class PostCard extends StatelessWidget {
  final Post post;
  final User user;
  final Function onLike;
  final Function? onDelete;

  const PostCard({
    super.key,
    required this.post,
    required this.user,
    required this.onLike,
    this.onDelete,
  });

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final isDarkMode = theme.brightness == Brightness.dark;
    final backgroundColor = isDarkMode ? AppTheme.surfaceColorDark : Colors.white;
    final textColor = isDarkMode ? AppTheme.darkTextColor : AppTheme.lightTextColor;
    final primaryColor = isDarkMode ? AppTheme.accentColor : AppTheme.primaryColor;
    final subtleColor = isDarkMode
        ? AppTheme.darkTextColor.withOpacity(0.6)
        : AppTheme.lightTextColor.withOpacity(0.6);

    return Card(
      margin: const EdgeInsets.symmetric(vertical: 10, horizontal: 16),
      elevation: 0,
      shape: RoundedRectangleBorder(
        borderRadius: BorderRadius.circular(16),
        side: BorderSide(
          color: isDarkMode
              ? Colors.grey.shade800.withOpacity(0.5)
              : Colors.grey.shade200,
          width: 1,
        ),
      ),
      color: backgroundColor,
      clipBehavior: Clip.antiAlias,
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          // Post header with user info
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 8, 8),
            child: Row(
              children: [
                // User avatar with subtle border
                Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(
                      color: primaryColor.withOpacity(0.2),
                      width: 2,
                    ),
                  ),
                  child: CircleAvatar(
                    radius: 20,
                    backgroundColor: primaryColor.withOpacity(0.1),
                    backgroundImage: user.profilePicture.isNotEmpty
                        ? CachedNetworkImageProvider(
                            '${ApiConfig.baseUrl}/images/${user.profilePicture}',
                          )
                        : null,
                    child: user.profilePicture.isEmpty
                        ? Text(
                            _getInitials(user),
                            style: TextStyle(
                              color: primaryColor,
                              fontWeight: FontWeight.bold,
                            ),
                          )
                        : null,
                  ),
                ),

                const SizedBox(width: 12),

                // User name and post time
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        user.fullName,
                        style: TextStyle(
                          fontWeight: FontWeight.w600,
                          fontSize: 15,
                          color: textColor,
                        ),
                      ),
                      const SizedBox(height: 2),
                      Text(
                        timeago.format(post.createdAt),
                        style: TextStyle(
                          color: subtleColor,
                          fontSize: 13,
                        ),
                      ),
                    ],
                  ),
                ),

                // Menu for post options
                if (onDelete != null)
                  IconButton(
                    icon: Icon(
                      Icons.more_horiz,
                      color: subtleColor,
                      size: 20,
                    ),
                    onPressed: () {
                      showModalBottomSheet(
                        context: context,
                        backgroundColor: backgroundColor,
                        shape: const RoundedRectangleBorder(
                          borderRadius: BorderRadius.vertical(
                            top: Radius.circular(20),
                          ),
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
                                  color: subtleColor.withOpacity(0.3),
                                  borderRadius: BorderRadius.circular(4),
                                ),
                              ),
                              ListTile(
                                leading: Icon(Icons.delete_outline, color: theme.colorScheme.error),
                                title: Text(
                                  'Delete Post',
                                  style: TextStyle(
                                    fontWeight: FontWeight.w500,
                                    color: theme.colorScheme.error,
                                  ),
                                ),
                                onTap: () {
                                  Navigator.pop(context);
                                  _showDeleteConfirmation(context, backgroundColor, textColor);
                                },
                              ),
                              const SizedBox(height: 8),
                            ],
                          ),
                        ),
                      );
                    },
                  ),
              ],
            ),
          ),

          // Post description with proper padding
          if (post.desc.isNotEmpty)
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
              child: Text(
                post.desc,
                style: TextStyle(
                  fontSize: 15,
                  color: textColor,
                  height: 1.3,
                ),
              ),
            ),

          // Post image with improved loading state
          if (post.image.isNotEmpty)
            Container(
              margin: const EdgeInsets.only(top: 8),
              constraints: const BoxConstraints(
                minHeight: 200,
                maxHeight: 400,
              ),
              width: double.infinity,
              child: CachedNetworkImage(
                imageUrl: ImageUtils.getImageUrl(post.image),
                imageBuilder: (context, imageProvider) => Container(
                  decoration: BoxDecoration(
                    image: DecorationImage(
                      image: imageProvider,
                      fit: BoxFit.cover,
                    ),
                  ),
                ),
                placeholder: (context, url) => Center(
                  child: LoadingAnimation(
                    size: 36,
                    primaryColor: primaryColor,
                  ),
                ),
                errorWidget: (context, url, error) => Container(
                  color: primaryColor.withOpacity(0.1),
                  child: Center(
                    child: Icon(
                      Icons.image_not_supported_outlined,
                      color: subtleColor,
                      size: 48,
                    ),
                  ),
                ),
                fit: BoxFit.cover,
              ),
            ),

          // Post actions with subtle divider
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 4),
            child: Row(
              children: [
                // Like button with animation
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () => onLike(),
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                            post.likes.contains(user.id)
                                ? Icons.favorite_rounded
                                : Icons.favorite_border_rounded,
                            color: post.likes.contains(user.id)
                                ? Colors.red
                                : subtleColor,
                            size: 22,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            '${post.likes.length}',
                            style: TextStyle(
                              color: post.likes.contains(user.id)
                                  ? Colors.red
                                  : subtleColor,
                              fontWeight: FontWeight.w500,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                // Comment button for future implementation
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      // To be implemented
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Row(
                        children: [
                          Icon(
                            Icons.chat_bubble_outline_rounded,
                            color: subtleColor,
                            size: 20,
                          ),
                          const SizedBox(width: 4),
                          Text(
                            'Comment',
                            style: TextStyle(
                              color: subtleColor,
                              fontWeight: FontWeight.w500,
                              fontSize: 13,
                            ),
                          ),
                        ],
                      ),
                    ),
                  ),
                ),

                const Spacer(),

                // Share button
                Material(
                  color: Colors.transparent,
                  child: InkWell(
                    borderRadius: BorderRadius.circular(20),
                    onTap: () {
                      // To be implemented
                    },
                    child: Padding(
                      padding: const EdgeInsets.all(8.0),
                      child: Icon(
                        Icons.share_outlined,
                        color: subtleColor,
                        size: 20,
                      ),
                    ),
                  ),
                ),
              ],
            ),
          ),

          // Add some bottom padding
          const SizedBox(height: 8),
        ],
      ),
    );
  }

  void _showDeleteConfirmation(BuildContext context, Color backgroundColor, Color textColor) {
    final theme = Theme.of(context);

    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: backgroundColor,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        title: Text(
          'Delete Post',
          style: TextStyle(
            color: textColor,
            fontWeight: FontWeight.w600,
          ),
        ),
        content: Text(
          'Are you sure you want to delete this post? This action cannot be undone.',
          style: TextStyle(
            color: textColor.withOpacity(0.8),
          ),
        ),
        actions: [
          TextButton(
            style: TextButton.styleFrom(
              foregroundColor: textColor.withOpacity(0.8),
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Cancel'),
            onPressed: () => Navigator.pop(context),
          ),
          ElevatedButton(
            style: ElevatedButton.styleFrom(
              backgroundColor: theme.colorScheme.error,
              foregroundColor: Colors.white,
              elevation: 0,
              shape: RoundedRectangleBorder(
                borderRadius: BorderRadius.circular(8),
              ),
            ),
            child: const Text('Delete'),
            onPressed: () {
              Navigator.pop(context);
              onDelete!();
            },
          ),
        ],
      ),
    );
  }

  String _getInitials(User user) {
    String initials = '';
    if (user.firstname.isNotEmpty) {
      initials += user.firstname[0];
    }
    if (user.lastname.isNotEmpty) {
      initials += user.lastname[0];
    }
    return initials.isEmpty ? '?' : initials;
  }
}