import 'dart:convert';
import 'package:http/http.dart' as http;
import '../models/message_model.dart';
import 'auth_service.dart';

class MessageService {
  static const baseUrl = 'http://localhost:5000/api/messages';

  static Future<List<Message>> fetchMessages(int chatId) async {
    final token = await AuthService.getToken();
    final userId = await AuthService.getUserId();

    final response = await http.get(
      Uri.parse('$baseUrl/$chatId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );

    if (response.statusCode == 200) {
      final List decoded = jsonDecode(response.body);
      return decoded.map((e) => Message.fromJson(e, userId!)).toList();
    } else {
      throw Exception('Ошибка загрузки сообщений: ${response.body}');
    }
  }

  static Future<void> sendMessage(int chatId, String text) async {
    final token = await AuthService.getToken();

    final response = await http.post(
      Uri.parse('$baseUrl/$chatId'),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
      body: jsonEncode({'text': text}),
    );

    if (response.statusCode != 201) {
      throw Exception('Ошибка отправки сообщения: ${response.body}');
    }
  }
}
