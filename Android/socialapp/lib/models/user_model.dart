class User {
  final String id;
  final String email;
  final String password;
  final String firstname;
  final String lastname;
  final bool isAdmin;
  final String profilePicture;
  final String coverPicture;
  final String about;
  final String livesin;
  final String worksAt;
  final String relationship;
  final String country;
  final List<String> followers;
  final List<String> following;

  User({
    required this.id,
    required this.email,
    this.password = '',
    required this.firstname,
    required this.lastname,
    this.isAdmin = false,
    this.profilePicture = '',
    this.coverPicture = '',
    this.about = '',
    this.livesin = '',
    this.worksAt = '',
    this.relationship = '',
    this.country = '',
    this.followers = const [],
    this.following = const [],
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['_id'] ?? '',
      email: json['email'] ?? '',
      password: json['password'] ?? '',
      firstname: json['firstname'] ?? '',
      lastname: json['lastname'] ?? '',
      isAdmin: json['isAdmin'] ?? false,
      profilePicture: json['profilePicture'] ?? '',
      coverPicture: json['coverPicture'] ?? '',
      about: json['about'] ?? '',
      livesin: json['livesin'] ?? '',
      worksAt: json['worksAt'] ?? '',
      relationship: json['relationship'] ?? '',
      country: json['country'] ?? '',
      followers: List<String>.from(json['followers'] ?? []),
      following: List<String>.from(json['following'] ?? []),
    );
  }

  Map<String, dynamic> toJson() {
    return {
      '_id': id,
      'email': email,
      'password': password,
      'firstname': firstname,
      'lastname': lastname,
      'isAdmin': isAdmin,
      'profilePicture': profilePicture,
      'coverPicture': coverPicture,
      'about': about,
      'livesin': livesin,
      'worksAt': worksAt,
      'relationship': relationship,
      'country': country,
      'followers': followers,
      'following': following,
    };
  }

  String get fullName {
    if (firstname.isEmpty && lastname.isEmpty) {
      return "Unknown User";
    } else if (firstname.isEmpty) {
      return lastname;
    } else if (lastname.isEmpty) {
      return firstname;
    }
    return '$firstname $lastname';
  }
}