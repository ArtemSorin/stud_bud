import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/post_model.dart';
import '../models/comment_model.dart';
import '../services/post_service.dart';
import '../services/comment_service.dart';

class CommentsScreen extends StatefulWidget {
  final int postId;

  const CommentsScreen({super.key, required this.postId});

  @override
  State<CommentsScreen> createState() => _CommentsScreenState();
}

class _CommentsScreenState extends State<CommentsScreen> {
  late Future<Post> _futurePost;
  late Future<List<Comment>> _futureComments;

  bool _showAll = false;
  final _controller = TextEditingController();

  @override
  void initState() {
    super.initState();
    _futurePost = PostService.fetchPostById(widget.postId); // нужен endpoint
    _futureComments = CommentService.fetchComments(widget.postId);
  }

  Future<void> _refreshComments() async {
    setState(() {
      _futureComments = CommentService.fetchComments(widget.postId);
    });
  }

  void _submitComment() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    try {
      await CommentService.addComment(widget.postId, text);
      _controller.clear();
      await _refreshComments();
    } catch (e) {
      print('Ошибка при отправке комментария: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Ошибка при отправке комментария')),
      );
    }
  }

  Widget _buildPost(Post post) {
    return Padding(
      padding: const EdgeInsets.all(16),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              CircleAvatar(
                backgroundImage:
                    post.authorPicture != null
                        ? NetworkImage(post.authorPicture!)
                        : null,
                child: post.authorPicture == null ? Text(post.author[0]) : null,
              ),
              const SizedBox(width: 10),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    post.author,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                  Text(
                    DateFormat.yMMMd().add_Hm().format(post.createdAt),
                    style: const TextStyle(fontSize: 12, color: Colors.grey),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 12),
          Text(post.content),
          if (post.imageUrl != null) ...[
            const SizedBox(height: 10),
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(post.imageUrl!),
            ),
          ],
          const SizedBox(height: 10),
          Row(
            children: [
              Icon(Icons.favorite, color: Colors.red),
              const SizedBox(width: 4),
              Text('${post.likesCount}'),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  Widget _buildCommentTile(Comment comment, {int indent = 0}) {
    return Padding(
      padding: EdgeInsets.only(left: indent.toDouble(), top: 8, right: 8),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          CircleAvatar(
            radius: 16,
            backgroundImage:
                comment.avatarUrl != null
                    ? NetworkImage(comment.avatarUrl!)
                    : null,
            child: comment.avatarUrl == null ? Text(comment.author[0]) : null,
          ),
          const SizedBox(width: 8),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  comment.author,
                  style: const TextStyle(fontWeight: FontWeight.bold),
                ),
                Text(comment.content),
                Text(
                  DateFormat.Hm().format(comment.createdAt),
                  style: const TextStyle(fontSize: 10, color: Colors.grey),
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Комментарии')),
      body: FutureBuilder<Post>(
        future: _futurePost,
        builder: (context, postSnapshot) {
          if (postSnapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (postSnapshot.hasError) {
            print(postSnapshot.error);
            return Center(child: Text('Ошибка загрузки поста'));
          }

          final post = postSnapshot.data!;

          return FutureBuilder<List<Comment>>(
            future: _futureComments,
            builder: (context, commentsSnapshot) {
              if (commentsSnapshot.connectionState == ConnectionState.waiting) {
                return const Center(child: CircularProgressIndicator());
              } else if (commentsSnapshot.hasError) {
                return Center(child: Text('Ошибка загрузки комментариев'));
              }

              final allComments = commentsSnapshot.data!;
              final displayedComments =
                  _showAll ? allComments : allComments.take(5).toList();

              return RefreshIndicator(
                onRefresh: _refreshComments,
                child: Column(
                  children: [
                    _buildPost(post),
                    Expanded(
                      child: ListView(
                        children: [
                          ...displayedComments.map((c) => _buildCommentTile(c)),
                          if (!_showAll && allComments.length > 5)
                            TextButton(
                              onPressed: () => setState(() => _showAll = true),
                              child: const Text('Показать ещё'),
                            ),
                        ],
                      ),
                    ),
                    Padding(
                      padding: const EdgeInsets.symmetric(
                        horizontal: 12,
                        vertical: 8,
                      ),
                      child: Row(
                        children: [
                          Expanded(
                            child: TextField(
                              controller: _controller,
                              decoration: const InputDecoration(
                                hintText: 'Добавить комментарий...',
                                border: OutlineInputBorder(),
                              ),
                            ),
                          ),
                          IconButton(
                            icon: const Icon(Icons.send),
                            onPressed: _submitComment,
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            },
          );
        },
      ),
    );
  }
}
