class Announcement {
  final int id;
  final String title;
  final String description;
  final String category;
  final String location;
  final String createdAt;
  final String author;
  final String? authorPicture;

  Announcement({
    required this.id,
    required this.title,
    required this.description,
    required this.category,
    required this.location,
    required this.createdAt,
    required this.author,
    this.authorPicture,
  });

  factory Announcement.fromJson(Map<String, dynamic> json) {
    final authorData = json['announcementAuthor'];

    return Announcement(
      id: json['announcement_id'],
      title: json['title'],
      description: json['description'],
      category: json['category'],
      location: json['location'] ?? '',
      createdAt: json['created_at'],
      author:
          authorData != null
              ? authorData['username'] ?? 'Неизвестно'
              : 'Неизвестно',
      authorPicture:
          authorData != null ? authorData['profile_picture_url'] : null,
    );
  }
}
