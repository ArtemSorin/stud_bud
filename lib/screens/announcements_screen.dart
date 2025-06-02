import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import '../models/announcement_model.dart';
import '../services/announcement_service.dart';

class AnnouncementsScreen extends StatefulWidget {
  const AnnouncementsScreen({super.key});

  @override
  State<AnnouncementsScreen> createState() => _AnnouncementsScreenState();
}

class _AnnouncementsScreenState extends State<AnnouncementsScreen> {
  late Future<List<Announcement>> _futureAnnouncements;

  @override
  void initState() {
    super.initState();
    _futureAnnouncements = AnnouncementService.fetchAnnouncements();
  }

  Future<void> _refresh() async {
    setState(() {
      _futureAnnouncements = AnnouncementService.fetchAnnouncements();
    });
  }

  Widget _buildAnnouncementCard(Announcement a) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16.0, vertical: 8),
      child: Card(
        elevation: 2,
        child: Padding(
          padding: const EdgeInsets.all(12.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Row(
                children: [
                  CircleAvatar(
                    backgroundImage:
                        a.authorPicture != null
                            ? NetworkImage(a.authorPicture!)
                            : null,
                    child: a.authorPicture == null ? Text(a.author[0]) : null,
                  ),
                  const SizedBox(width: 10),
                  Text(
                    a.author,
                    style: const TextStyle(fontWeight: FontWeight.bold),
                  ),
                ],
              ),
              const SizedBox(height: 8),
              Text(
                a.title,
                style: const TextStyle(
                  fontSize: 16,
                  fontWeight: FontWeight.bold,
                ),
              ),
              const SizedBox(height: 6),
              Text(a.description),
              const SizedBox(height: 6),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Text("Категория: ${a.category}"),
                  Text("Город: ${a.location}"),
                ],
              ),
              const SizedBox(height: 4),
              Text(
                DateFormat.yMMMMd().add_Hm().format(
                  DateTime.parse(a.createdAt),
                ),
                style: const TextStyle(color: Colors.grey, fontSize: 12),
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text("Объявления")),
      body: FutureBuilder<List<Announcement>>(
        future: _futureAnnouncements,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка: ${snapshot.error}'));
          }

          final announcements = snapshot.data!;
          return RefreshIndicator(
            onRefresh: _refresh,
            child: ListView(
              children: announcements.map(_buildAnnouncementCard).toList(),
            ),
          );
        },
      ),
    );
  }
}
