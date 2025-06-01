import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stud_bud/screens/comments_screen.dart';

import '../models/post_model.dart';
import '../services/post_service.dart';

class FeedScreen extends StatefulWidget {
  const FeedScreen({super.key});

  @override
  _FeedScreenState createState() => _FeedScreenState();
}

class _FeedScreenState extends State<FeedScreen> {
  late Future<List<Post>> _futurePosts;

  @override
  void initState() {
    super.initState();
    _futurePosts = PostService.fetchFeed();
  }

  Future<void> _refresh() async {
    setState(() {
      _futurePosts = PostService.fetchFeed();
    });
  }

  void _handleLike(Post post) async {
    final response = await PostService.toggleLike(post.id);

    setState(() {
      post.likedByCurrentUser = !post.likedByCurrentUser;
      post.likesCount = response['likesCount'];
    });
  }

  Widget _buildPostCard(Post post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
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
                radius: 25,
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
                    DateFormat.yMMMMd().add_Hm().format(post.createdAt),
                    style: const TextStyle(color: Colors.grey, fontSize: 12),
                  ),
                ],
              ),
            ],
          ),
          const SizedBox(height: 10),
          Text(post.content, style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          if (post.imageUrl != null)
            ClipRRect(
              borderRadius: BorderRadius.circular(8.0),
              child: Image.network(
                post.imageUrl!,
                fit: BoxFit.cover,
                errorBuilder: (context, error, stackTrace) {
                  return Container(
                    height: 200,
                    color: Colors.grey[300],
                    alignment: Alignment.center,
                    child: const Text('Ошибка загрузки изображения'),
                  );
                },
              ),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  IconButton(
                    icon: Icon(
                      post.likedByCurrentUser
                          ? Icons.favorite
                          : Icons.favorite_border,
                      color:
                          post.likedByCurrentUser ? Colors.red : Colors.black,
                    ),
                    onPressed: () => _handleLike(post),
                  ),
                  Text('${post.likesCount}'),
                ],
              ),
              Row(
                children: [
                  IconButton(
                    icon: const Icon(Icons.comment, color: Colors.black),
                    onPressed: () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (_) => CommentsScreen(postId: post.id),
                        ),
                      );
                    },
                  ),
                  const Text("0"),
                ],
              ),
            ],
          ),
          const Divider(),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Post>>(
        future: _futurePosts,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final posts = snapshot.data!;

          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(children: [...posts.map(_buildPostCard).toList()]),
          );
        },
      ),
    );
  }
}
