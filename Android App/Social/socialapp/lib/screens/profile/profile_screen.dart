import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import '../../models/user_model.dart';
import '../../models/post_model.dart';
import '../../services/auth_service.dart';
import '../../services/user_service.dart';
import '../../services/post_service.dart';
import '../../config/api_config.dart';
import '../../widgets/post_card.dart';
import 'edit_profile_screen.dart';
import '../../services/activity_service.dart';
import '../../config/app_theme.dart'; // Import AppTheme
import '../../widgets/loading_animation.dart'; // Import LoadingAnimation

class ProfileScreen extends StatefulWidget {
  final String? userId;

  const ProfileScreen({super.key, this.userId});

  @override
  _ProfileScreenState createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  final AuthService _authService = AuthService();
  final UserService _userService = UserService();
  final PostService _postService = PostService();
  final ActivityService _activityService = ActivityService();

  // Initialize with a dummy Future that completes immediately to avoid late initialization error
  Future<User> _userFuture = Future.value(User(
    id: '',
    firstname: '',
    lastname: '',
    email: '',
    followers: [],
    following: [],
    profilePicture: '',
    coverPicture: '',
    about: '',
    livesin: '',
    worksAt: '',
    relationship: '',
  ));

  Future<List<Post>> _postsFuture = Future.value([]);
  String _currentUserId = '';
  bool _isCurrentUser = false;
  bool _isFollowing = false;
  bool _isLoading = true;

  @override
  void initState() {
    super.initState();
    _loadUserData();
  }

  Future<void> _loadUserData() async {
    try {
      final currentUserId = await _authService.getUserId();
      if (currentUserId == null) {
        throw Exception('User not logged in');
      }

      _currentUserId = currentUserId;
      _isCurrentUser = widget.userId == null || widget.userId == currentUserId;

      // Initialize futures outside setState to ensure they're set before build runs
      final userFuture = widget.userId != null
          ? _userService.getUserById(widget.userId!)
          : _userService.getUserById(currentUserId);

      final postsFuture = widget.userId != null
          ? _postService.getUserPosts(widget.userId!)
          : _postService.getUserPosts(currentUserId);

      // Only use setState to update the UI once the futures are created
      if (mounted) {
        setState(() {
          _userFuture = userFuture;
          _postsFuture = postsFuture;
          _isLoading = false;
        });
      }
    } catch (e) {
      print('Error loading user data: $e');
      if (mounted) {
        setState(() {
          _isLoading = false;
        });
      }
    }
  }

  Future<void> _refreshProfile() async {
    setState(() {
      _loadUserData();
    });
  }

  Future<void> _toggleFollow(User user) async {
    try {
      if (_isFollowing) {
        await _userService.unfollowUser(user.id);
      } else {
        await _userService.followUser(user.id);
      }
      _activityService.incrementInteractions();

      setState(() {
        _isFollowing = !_isFollowing;
      });

      _refreshProfile();
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Failed to ${_isFollowing ? 'unfollow' : 'follow'} user')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return RefreshIndicator(
      backgroundColor: AppTheme.surfaceColorLight,
      color: AppTheme.primaryColor,
      onRefresh: _refreshProfile,
      child: FutureBuilder<User>(
        future: _userFuture,
        builder: (context, userSnapshot) {
          if (userSnapshot.connectionState == ConnectionState.waiting) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundColorLight,
              body: const Center(
                child: LoadingAnimation(),
              ),
            );
          }

          if (userSnapshot.hasError) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundColorLight,
              body: Center(
                child: Text('Error loading profile: ${userSnapshot.error}'),
              ),
            );
          }

          if (!userSnapshot.hasData) {
            return Scaffold(
              backgroundColor: AppTheme.backgroundColorLight,
              body: const Center(child: Text('User not found')),
            );
          }

          final user = userSnapshot.data!;
          _isFollowing = user.followers.contains(_currentUserId);

          return FutureBuilder<List<Post>>(
            future: _postsFuture,
            builder: (context, postsSnapshot) {
              final posts = postsSnapshot.data ?? [];

              return CustomScrollView(
                slivers: [
                  // Profile header
                  SliverToBoxAdapter(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        // Cover photo
                        Stack(
                          clipBehavior: Clip.none,
                          alignment: Alignment.bottomLeft,
                          children: [
                            // Cover image
                            Container(
                              height: 150,
                              width: double.infinity,
                              decoration: BoxDecoration(
                                color: Colors.grey[300],
                                image: user.coverPicture.isNotEmpty
                                    ? DecorationImage(
                                        image: CachedNetworkImageProvider(
                                          '${ApiConfig.baseUrl}/images/${user.coverPicture}',
                                        ),
                                        fit: BoxFit.cover,
                                      )
                                    : null,
                              ),
                            ),

                            // Profile picture
                            Positioned(
                              bottom: -50,
                              left: 20,
                              child: CircleAvatar(
                                radius: 50,
                                backgroundColor: Colors.white,
                                child: CircleAvatar(
                                  radius: 47,
                                  backgroundImage: user.profilePicture.isNotEmpty
                                      ? CachedNetworkImageProvider(
                                          '${ApiConfig.baseUrl}/images/${user.profilePicture}',
                                        )
                                      : null,
                                  child: user.profilePicture.isEmpty
                                      ? Text(
                                          user.firstname[0] + user.lastname[0],
                                          style: const TextStyle(fontSize: 30),
                                        )
                                      : null,
                                ),
                              ),
                            ),

                            // Edit profile or Follow button
                            Positioned(
                              bottom: 10,
                              right: 20,
                              child: _isCurrentUser
                              ? Container(
                                decoration: BoxDecoration(
                                color: Theme.of(context).primaryColor,
                                shape: BoxShape.circle,
                                ),
                                child: IconButton(
                                icon: const Icon(Icons.edit),
                                onPressed: () {
                                  Navigator.push(
                                  context,
                                  MaterialPageRoute(
                                    builder: (context) => EditProfileScreen(user: user),
                                  ),
                                  ).then((_) => _refreshProfile());
                                },
                                color: Colors.white,
                                ),
                              ): ElevatedButton.icon(
                                      icon: Icon(_isFollowing ? Icons.person_remove : Icons.person_add),
                                      label: Text(_isFollowing ? 'Unfollow' : 'Follow'),
                                      onPressed: () => _toggleFollow(user),
                                      style: ElevatedButton.styleFrom(
                                        backgroundColor: _isFollowing
                                            ? Colors.grey[300]
                                            : Theme.of(context).primaryColor,
                                        foregroundColor: _isFollowing
                                            ? Colors.black
                                            : Colors.white,
                                      ),
                                    ),
                            ),
                          ],
                        ),

                        // User info
                        Padding(
                          padding: const EdgeInsets.fromLTRB(20, 60, 20, 20),
                          child: Column(
                            crossAxisAlignment: CrossAxisAlignment.start,
                            children: [
                              Text(
                                user.fullName,
                                style: const TextStyle(
                                  fontSize: 24,
                                  fontWeight: FontWeight.bold,
                                ),
                              ),
                              const SizedBox(height: 5),
                              Text(
                                '@${user.email.split('@')[0]}',
                                style: TextStyle(
                                  fontSize: 16,
                                  color: Colors.grey[600],
                                ),
                              ),

                              if (user.about.isNotEmpty) ...[
                                const SizedBox(height: 15),
                                Text(user.about),
                              ],

                              const SizedBox(height: 15),

                              // Location, work, relationship info
                              if (user.livesin.isNotEmpty)
                                _buildInfoRow(Icons.location_on, user.livesin),
                              if (user.worksAt.isNotEmpty)
                                _buildInfoRow(Icons.work, user.worksAt),
                              if (user.relationship.isNotEmpty)
                                _buildInfoRow(Icons.favorite, user.relationship),

                              const SizedBox(height: 20),

                              // Followers & Following counts
                              Row(
                                children: [
                                  _buildCountColumn('Posts', posts.length),
                                  const SizedBox(width: 30),
                                  _buildCountColumn('Followers', user.followers.length),
                                  const SizedBox(width: 30),
                                  _buildCountColumn('Following', user.following.length),
                                ],
                              ),

                              const SizedBox(height: 20),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),

                  // User posts
                  if (postsSnapshot.connectionState == ConnectionState.waiting)
                    const SliverFillRemaining(
                      child: Center(child: CircularProgressIndicator()),
                    )
                  else if (postsSnapshot.hasError)
                    SliverFillRemaining(
                      child: Center(
                        child: Text('Error loading posts: ${postsSnapshot.error}'),
                      ),
                    )
                  else if (posts.isEmpty)
                    const SliverFillRemaining(
                      child: Center(
                        child: Text('No posts yet'),
                      ),
                    )
                  else
                    SliverList(
                      delegate: SliverChildBuilderDelegate(
                        (context, index) {
                          final post = posts[index];
                          return PostCard(
                            post: post,
                            user: user,
                            onLike: () async {
                              await _postService.likePost(post.id);
                              _refreshProfile();
                            },
                            onDelete: _isCurrentUser
                                ? () async {
                                    await _postService.deletePost(post.id);
                                    _refreshProfile();
                                  }
                                : null,
                          );
                        },
                        childCount: posts.length,
                      ),
                    ),
                ],
              );
            },
          );
        },
      ),
    );
  }

  Widget _buildInfoRow(IconData icon, String text) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 8.0),
      child: Row(
        children: [
          Icon(icon, size: 18, color: Colors.grey[600]),
          const SizedBox(width: 5),
          Text(
            text,
            style: TextStyle(color: Colors.grey[600]),
          ),
        ],
      ),
    );
  }

  Widget _buildCountColumn(String label, int count) {
    return Column(
      children: [
        Text(
          count.toString(),
          style: const TextStyle(
            fontSize: 18,
            fontWeight: FontWeight.bold,
          ),
        ),
        Text(
          label,
          style: TextStyle(color: Colors.grey[600]),
        ),
      ],
    );
  }
}