import 'dart:convert';
import 'package:http/http.dart' as http;
import 'package:stud_bud/models/post_model.dart';
import 'auth_service.dart';

class PostService {
  static const String baseUrl = 'http://localhost:5000/api/posts';
  //static const String baseUrl = 'http://10.0.2.2:5000/api/posts';

  static Future<List<Post>> fetchFeed() async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse(baseUrl),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      List jsonList = jsonDecode(response.body);
      return jsonList.map((json) => Post.fromJson(json)).toList();
    } else {
      throw Exception('Ошибка загрузки постов');
    }
  }

  static Future<Map<String, dynamic>> toggleLike(int postId) async {
    final token = await AuthService.getToken();
    final response = await http.post(
      Uri.parse('$baseUrl/$postId/like'),
      headers: {'Authorization': 'Bearer $token'},
    );

    if (response.statusCode == 200) {
      return jsonDecode(response.body);
    } else {
      print("LIKE ERROR: ${response.body}");
      throw Exception('Ошибка при лайке');
    }
  }

  static Future<Post> fetchPostById(int postId) async {
    final token = await AuthService.getToken();
    final response = await http.get(
      Uri.parse('$baseUrl/$postId'),
      headers: {'Authorization': 'Bearer $token'},
    );
    print('fetchPostById status: ${response.statusCode}');
    print('fetchPostById body: ${response.body}');
    if (response.statusCode == 200) {
      return Post.fromJson(json.decode(response.body));
    } else {
      throw Exception('Ошибка загрузки поста');
    }
  }
}
