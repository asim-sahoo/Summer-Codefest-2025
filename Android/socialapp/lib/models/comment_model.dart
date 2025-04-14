class Comment {
  final String userId;
  final String text;
  final String? userName;
  final String? userProfilePicture;

  Comment({
    required this.userId,
    required this.text,
    this.userName,
    this.userProfilePicture,
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    return Comment(
      userId: json['userId'] ?? '',
      text: json['text'] ?? '',
      userName: json['userName'],
      userProfilePicture: json['userProfilePicture'],
    );
  }

  Map<String, dynamic> toJson() {
    return {
      'userId': userId,
      'text': text,
      'userName': userName,
      'userProfilePicture': userProfilePicture,
    };
  }
}