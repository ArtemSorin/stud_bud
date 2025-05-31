class Post {
  final int id;
  final String content;
  final String? imageUrl;
  final DateTime createdAt;
  final String author;
  final String? authorPicture;
  int likesCount;
  bool likedByCurrentUser;

  Post({
    required this.id,
    required this.content,
    this.imageUrl,
    required this.createdAt,
    required this.author,
    this.authorPicture,
    required this.likesCount,
    required this.likedByCurrentUser,
  });

  factory Post.fromJson(Map<String, dynamic> json) {
    return Post(
      id: json['post_id'] ?? 0,
      content: json['content'] ?? '',
      imageUrl: json['image_url'],
      createdAt: DateTime.parse(
        json['created_at'] ?? DateTime.now().toIso8601String(),
      ),
      author: json['author'] ?? 'Неизвестный',
      authorPicture: json['author_picture_url'],
      likesCount: json['likes_count'] ?? 0,
      likedByCurrentUser: json['liked_by_current_user'] ?? false,
    );
  }
}
