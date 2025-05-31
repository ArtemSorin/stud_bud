class User {
  final int id;
  final String username;
  final String firstName;
  final String lastName;
  final String email;
  final String bio;
  final String? profilePictureUrl;
  final List<Post> posts;

  User({
    required this.id,
    required this.username,
    required this.firstName,
    required this.lastName,
    required this.email,
    required this.bio,
    this.profilePictureUrl,
    required this.posts,
  });

  factory User.fromJson(Map<String, dynamic> json) {
    return User(
      id: json['user_id'],
      username: json['username'],
      firstName: json['first_name'] ?? '',
      lastName: json['last_name'] ?? '',
      email: json['email'],
      bio: json['bio'] ?? '',
      profilePictureUrl: json['profile_picture_url'],
      posts: (json['posts'] as List).map((p) => Post.fromJson(p)).toList(),
    );
  }
}

class Post {
  final int id;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;

  Post({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.createdAt,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['post_id'],
      content: json['content'],
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(json['created_at']),
    );
  }
}
