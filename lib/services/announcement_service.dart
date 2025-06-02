import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/announcement_model.dart';
import 'auth_service.dart';

class AnnouncementService {
  static Future<List<Announcement>> fetchAnnouncements() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('http://localhost:5000/api/announcements'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      final List jsonList = json.decode(response.body);
      return jsonList.map((e) => Announcement.fromJson(e)).toList();
    } else {
      throw Exception('Ошибка загрузки объявлений');
    }
  }
}
