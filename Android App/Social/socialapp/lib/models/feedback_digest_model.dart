// filepath: d:\Files\Code\flutter_projects\Social\socialapp\lib\models\feedback_digest_model.dart
class FeedbackDigestModel {
  final int likesReceived;
  final int commentsReceived;
  final Map<String, int> reactionsReceived;
  final int uniqueEngagers;
  final List<String> messages;
  final DateTime date;

  FeedbackDigestModel({
    required this.likesReceived,
    required this.commentsReceived,
    required this.reactionsReceived,
    required this.uniqueEngagers,
    required this.messages,
    required this.date,
  });

  factory FeedbackDigestModel.fromJson(Map<String, dynamic> json) {
    Map<String, int> reactions = {};

    if (json['reactionsReceived'] != null) {
      Map<String, dynamic> reactionsData = json['reactionsReceived'];
      reactionsData.forEach((key, value) {
        reactions[key] = value;
      });
    } else {
      reactions = {
        'like': json['likesReceived'] ?? 0,
        'heart': 0,
        'smile': 0,
        'fire': 0,
      };
    }

    List<String> messagesList = [];
    if (json['messages'] != null) {
      messagesList = List<String>.from(json['messages']);
    } else {
      messagesList = ['No new activity today.'];
    }

    return FeedbackDigestModel(
      likesReceived: json['likesReceived'] ?? 0,
      commentsReceived: json['commentsReceived'] ?? 0,
      reactionsReceived: reactions,
      uniqueEngagers: json['uniqueEngagers'] ?? 0,
      messages: messagesList,
      date: json['date'] != null
        ? DateTime.parse(json['date'])
        : DateTime.now(),
    );
  }

  factory FeedbackDigestModel.empty() {
    return FeedbackDigestModel(
      likesReceived: 0,
      commentsReceived: 0,
      reactionsReceived: {
        'like': 0,
        'heart': 0,
        'smile': 0,
        'fire': 0,
      },
      uniqueEngagers: 0,
      messages: ['No activity recorded yet.'],
      date: DateTime.now(),
    );
  }

  int get totalReactions =>
    reactionsReceived.values.fold(0, (sum, item) => sum + item);

  bool get hasActivity =>
    likesReceived > 0 || commentsReceived > 0 || totalReactions > 0;
}