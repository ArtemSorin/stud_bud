import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stud_bud/models/message_model.dart';
import '../models/chat_model.dart';
import 'auth_service.dart';

class ChatService {
  static const String baseUrl = 'http://localhost:5000/api/chats';
  //static const String baseUrl = 'http://10.0.2.2:5000/api/chats';

  static Future<List<Chat>> fetchChats() async {
    final token = await AuthService.getToken();

    if (token == null) {
      throw Exception('Токен не найден. Пользователь не авторизован.');
    }

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Chat.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка загрузки чатов: ${response.body}');
    }
  }

  static Future<List<Message>> fetchMessages(int chatId) async {
    final token = await AuthService.getToken();
    final currentUserId = await AuthService.getUserId();

    if (token == null || currentUserId == null) {
      throw Exception('Не удалось получить токен или userId');
    }

    final response = await http.get(
      Uri.parse('$baseUrl/$chatId/messages'),
      headers: {
        'Content-Type': 'application/json',
        'Authorization': 'Bearer $token',
      },
    );

    if (response.statusCode == 200) {
      List jsonList = jsonDecode(response.body);
      return jsonList
          .map((json) => Message.fromJson(json, currentUserId))
          .toList();
    } else {
      throw Exception('Ошибка загрузки сообщений: ${response.body}');
    }
  }
}
