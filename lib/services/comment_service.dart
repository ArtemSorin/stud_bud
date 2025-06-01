import 'dart:convert';

import 'package:http/http.dart' as http;
import 'package:shared_preferences/shared_preferences.dart';
import 'package:stud_bud/models/comment_model.dart';

class CommentService {
  static const String baseUrl = 'http://localhost:5000/api/comments';
  //static const String baseUrl = 'http://10.0.2.2:5000/api/comments';

  static Future<List<Comment>> fetchComments(int postId) async {
    final response = await http.get(Uri.parse('$baseUrl/$postId'));

    print('Запрос к: $baseUrl/$postId');
    print('Код ответа: ${response.statusCode}');
    print('Тело ответа: ${response.body}');

    if (response.statusCode == 200) {
      final List<dynamic> data = jsonDecode(response.body);
      return data.map((json) => Comment.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка загрузки комментариев');
    }
  }

  static Future<void> addComment(int postId, String content) async {
    final prefs = await SharedPreferences.getInstance();
    final token = prefs.getString('token');

    if (token == null) {
      throw Exception('Пользователь не авторизован');
    }

    final url = Uri.parse('$baseUrl/$postId');
    final response = await http.post(
      url,
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
      body: jsonEncode({'content': content}),
    );

    if (response.statusCode != 201) {
      print(
        'addComment failed: status ${response.statusCode}, body: ${response.body}',
      );
      throw Exception('Ошибка отправки комментария: ${response.statusCode}');
    }
  }
}
