import 'comment_model.dart';

// Define the ContentType enum for post mood categorization
enum ContentType {
  uplifting,
  neutral,
  sensitive
}

// Helper to convert string to ContentType enum
ContentType contentTypeFromString(String? value) {
  if (value == 'uplifting') return ContentType.uplifting;
  if (value == 'sensitive') return ContentType.sensitive;
  return ContentType.neutral;
}

// Helper to convert ContentType enum to string
String contentTypeToString(ContentType type) {
  switch (type) {
    case ContentType.uplifting:
      return 'uplifting';
    case ContentType.sensitive:
      return 'sensitive';
    case ContentType.neutral:
    default:
      return 'neutral';
  }
}

class Post {
  final String id;
  final String userId;
  final String desc;
  final List<String> likes;
  final String image;
  final DateTime createdAt;
  final DateTime updatedAt;
  final List<Comment> comments;
  final ContentType contentType; // New field to categorize content

  Post({
    required this.id,
    required this.userId,
    required this.desc,
    this.likes = const [],
    this.image = '',
    required this.createdAt,
    required this.updatedAt,
    this.comments = const [],
    this.contentType = ContentType.neutral, // Default to neutral
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['_id'] ?? '',
      userId: json['userId'] ?? '',
      desc: json['desc'] ?? '',
      likes: List<String>.from(json['likes'] ?? []),
      image: json['image'] ?? '',
      createdAt: json['createdAt'] != null
          ? DateTime.parse(json['createdAt'])
          : DateTime.now(),
      updatedAt: json['updatedAt'] != null
          ? DateTime.parse(json['updatedAt'])
          : DateTime.now(),
      comments: (json['comments'] as List? ?? []).map((commentJson) => Comment.fromJson(commentJson)).toList(),
      contentType: contentTypeFromString(json['contentType']),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'userId': userId,
      'desc': desc,
      'likes': likes,
      'image': image,
      'createdAt': createdAt.toIso8601String(),
      'updatedAt': updatedAt.toIso8601String(),
      'comments': comments.map((comment) => comment.toJson()).toList(),
      'contentType': contentTypeToString(contentType),
    };
  }
}