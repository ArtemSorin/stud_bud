import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stud_bud/services/auth_service.dart';

class ProfileService {
  static const String baseUrl = 'http://localhost:5000/api/users/me';
  //static const String baseUrl = 'http://10.0.2.2:5000/api/users/me';

  static Future<Map<String, dynamic>> fetchUserProfile() async {
    final token = await AuthService.getToken();

    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {
        'Authorization': 'Bearer $token',
        'Content-Type': 'application/json',
      },
    );
    print(response.body); // временно добавь

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      throw Exception('Ошибка загрузки профиля: ${response.body}');
    }
  }
}
