class Post {
  final int id;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final String author;
  final String? authorPicture;
  int likesCount;
  bool likedByCurrentUser;
  int commentsCount;

  Post({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.author,
    this.authorPicture,
    required this.likesCount,
    required this.likedByCurrentUser,
    required this.commentsCount,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    const String baseUrl = 'http://localhost:5000';

    return Post(
      id: json['post_id'] ?? 0,
      content: json['content'] ?? '',
      imageUrl:
          json['image_url'] != null ? '$baseUrl${json['image_url']}' : null,
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      author: json['author'] ?? 'Неизвестный',
      authorPicture:
          json['author_picture_url'] != null
              ? '$baseUrl${json['author_picture_url']}'
              : null,
      likesCount: json['likes_count'] ?? 0,
      likedByCurrentUser: json['liked_by_current_user'] ?? false,
      commentsCount: json['commentsCount'] ?? 0,
    );
  }
}
