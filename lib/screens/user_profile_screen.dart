import 'package:flutter/material.dart';
import 'package:stud_bud/services/profile_service.dart';

class ProfilePage extends StatefulWidget {
  const ProfilePage({super.key});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  late Future<Map<String, dynamic>> _profileFuture;

  @override
  void initState() {
    super.initState();
    _profileFuture = ProfileService.fetchUserProfile();
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

          final data = snapshot.data!;
          final interests = List<String>.from(
            data['Interests'].map((i) => i['name']),
          );
          final posts = List<Map<String, dynamic>>.from(data['Posts']);

          return SingleChildScrollView(
            child: Column(
              children: [
                const SizedBox(height: 40),
                CircleAvatar(
                  radius: 60,
                  backgroundImage: NetworkImage(
                    data['avatar_url'] ?? 'https://via.placeholder.com/150',
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
                  data['location'] ?? 'No location',
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
                const Divider(),
                ...posts.map((post) => _buildPost(post)),
              ],
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

  Widget _buildPost(Map<String, dynamic> post) {
    final List images = post['images'] ?? [];

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 10),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(post['content'], style: const TextStyle(fontSize: 16)),
          const SizedBox(height: 10),
          if (images.isNotEmpty)
            GridView.count(
              crossAxisCount: 2,
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              crossAxisSpacing: 10,
              mainAxisSpacing: 10,
              children:
                  images
                      .map<Widget>(
                        (url) => ClipRRect(
                          borderRadius: BorderRadius.circular(8.0),
                          child: Image.network(url, fit: BoxFit.cover),
                        ),
                      )
                      .toList(),
            ),
          const SizedBox(height: 10),
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Row(
                children: [
                  const Icon(Icons.favorite),
                  const SizedBox(width: 5),
                  Text('${post['likes_count'] ?? 0}'),
                ],
              ),
              Row(
                children: [
                  const Icon(Icons.comment),
                  const SizedBox(width: 5),
                  Text('${post['comments_count'] ?? 0}'),
                ],
              ),
            ],
          ),
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
