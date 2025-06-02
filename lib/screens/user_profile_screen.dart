import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stud_bud/models/post_model.dart';
import 'package:stud_bud/services/post_service.dart';
import 'package:stud_bud/services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;

  Map<String, dynamic>? _profileData;
  List<Post> _posts = [];

  @override
  void initState() {
    super.initState();
    _loadProfile();
  }

  void _loadProfile() {
    _profileFuture = ProfileService.fetchUserProfile().then((data) {
      _profileData = data;
      _posts =
          List<Map<String, dynamic>>.from(
              data['Posts'],
            ).map((postJson) => Post.fromJson(postJson)).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      return data;
    });
  }

  Future<void> _refreshProfile() async {
    final data = await ProfileService.fetchUserProfile();
    setState(() {
      _profileData = data;
      _posts =
          List<Map<String, dynamic>>.from(
              data['Posts'],
            ).map((postJson) => Post.fromJson(postJson)).toList()
            ..sort((a, b) => b.createdAt.compareTo(a.createdAt));
      // Обновляем Future, чтобы FutureBuilder сработал
      _profileFuture = Future.value(_profileData);
    });
  }

  void _handleLike(Post post) async {
    final response = await PostService.toggleLike(post.id);
    setState(() {
      // Обновляем состояние конкретного поста локально
      final index = _posts.indexWhere((p) => p.id == post.id);
      if (index != -1) {
        _posts[index].likedByCurrentUser = !post.likedByCurrentUser;
        _posts[index].likesCount = response['likesCount'];
      }
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<Map<String, dynamic>>(
        future: _profileFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState != ConnectionState.done) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final data = _profileData!;
          final interests = List<String>.from(
            data['Interests'].map((i) => i['name']),
          );

          return RefreshIndicator(
            onRefresh: _refreshProfile,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              child: Column(
                children: [
                  const SizedBox(height: 40),
                  CircleAvatar(
                    radius: 60,
                    backgroundImage:
                        data['profile_picture_url'] != null &&
                                data['profile_picture_url'].isNotEmpty
                            ? NetworkImage(
                              'http://localhost:5000${data['profile_picture_url']}',
                            )
                            : const NetworkImage(
                              'https://via.placeholder.com/150',
                            ),
                  ),

                  const SizedBox(height: 16),
                  Text(
                    '${data['first_name']} ${data['last_name']}',
                    style: const TextStyle(
                      fontSize: 24,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  Text(
                    data['location'] ?? 'Локация не указана',
                    style: const TextStyle(fontSize: 18, color: Colors.grey),
                  ),
                  const SizedBox(height: 8),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                    children: [
                      _buildProfileDetail(
                        'Age',
                        _calculateAge(data['birth_date']).toString(),
                      ),
                      _buildProfileDetail('Gender', data['gender'] ?? '-'),
                    ],
                  ),
                  const SizedBox(height: 16),
                  _buildInterestChips(interests),
                  const Divider(thickness: 1),
                  ..._posts.map(_buildPostCard),
                ],
              ),
            ),
          );
        },
      ),
    );
  }

  Widget _buildProfileDetail(String label, String value) {
    return Column(
      children: [
        Text(label, style: const TextStyle(fontSize: 18, color: Colors.grey)),
        Text(
          value,
          style: const TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildInterestChips(List<String> interests) {
    return Wrap(
      spacing: 8.0,
      runSpacing: 4.0,
      children:
          interests
              .map(
                (interest) => Chip(
                  label: Text(interest),
                  backgroundColor: Colors.black,
                  labelStyle: const TextStyle(color: Colors.white),
                ),
              )
              .toList(),
    );
  }

  Widget _buildPostCard(Post post) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Row(
            children: [
              Text(
                DateFormat.yMMMMd().add_Hm().format(post.createdAt),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
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
                    onPressed: () {},
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

  int _calculateAge(String? birthDate) {
    if (birthDate == null) return 0;
    final bd = DateTime.parse(birthDate);
    final now = DateTime.now();
    return now.year -
        bd.year -
        ((now.month < bd.month || (now.month == bd.month && now.day < bd.day))
            ? 1
            : 0);
  }
}
