class Comment {
  final int id;
  final String content;
  final String author;
  final String? avatarUrl;
  final DateTime createdAt;
  final int? parentCommentId;
  final List<Comment> replies;

  Comment({
    required this.id,
    required this.content,
    required this.author,
    this.avatarUrl,
    required this.createdAt,
    this.parentCommentId,
    this.replies = const [],
  });

  factory Comment.fromJson(Map<String, dynamic> json) {
    final user = json['User'] ?? {};
    final repliesJson = json['replies'] as List<dynamic>? ?? [];

    return Comment(
      id: json['comment_id'],
      content: json['content'],
      author: user['username'] ?? 'Unknown',
      avatarUrl: user['profile_picture_url'],
      createdAt: DateTime.parse(json['created_at']),
      parentCommentId: json['parent_comment_id'],
      replies: repliesJson.map((reply) => Comment.fromJson(reply)).toList(),
    );
  }
}
