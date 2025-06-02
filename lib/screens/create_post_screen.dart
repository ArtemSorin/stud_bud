import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:http/http.dart' as http;
import 'package:mime/mime.dart';
import 'package:http_parser/http_parser.dart';
import 'package:stud_bud/services/auth_service.dart';

class CreatePostScreen extends StatefulWidget {
  const CreatePostScreen({super.key});

  @override
  State<CreatePostScreen> createState() => _CreatePostScreenState();
}

class _CreatePostScreenState extends State<CreatePostScreen> {
  final TextEditingController _contentController = TextEditingController();
  File? _imageFile;
  bool _isLoading = false;

  Future<void> _pickImage() async {
    final pickedFile = await ImagePicker().pickImage(
      source: ImageSource.gallery,
    );

    if (pickedFile != null) {
      setState(() {
        _imageFile = File(pickedFile.path);
      });
    }
  }

  Future<void> _submitPost() async {
    if (_contentController.text.isEmpty) return;

    setState(() => _isLoading = true);

    final userId = await AuthService.getUserId();
    if (userId == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Ошибка: пользователь не авторизован')),
      );
      setState(() => _isLoading = false);
      return;
    }

    final uri = Uri.parse('http://localhost:5000/api/posts');

    final token = await AuthService.getToken();

    var request =
        http.MultipartRequest('POST', uri)
          ..fields['content'] = _contentController.text
          ..headers['Authorization'] = 'Bearer $token';

    if (_imageFile != null) {
      final mimeType = lookupMimeType(_imageFile!.path)!.split('/');
      request.files.add(
        await http.MultipartFile.fromPath(
          'image',
          _imageFile!.path,
          contentType: MediaType(mimeType[0], mimeType[1]),
        ),
      );
    }

    final response = await request.send();
    final responseBody = await response.stream.bytesToString();

    setState(() => _isLoading = false);

    if (response.statusCode == 200) {
      Navigator.pop(context, true);
    } else {
      print("POST ERROR: $responseBody");
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Новый пост')),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            TextField(
              controller: _contentController,
              maxLines: 5,
              decoration: const InputDecoration(
                hintText: 'Чем хотите поделиться?',
                border: OutlineInputBorder(),
              ),
            ),
            const SizedBox(height: 10),
            if (_imageFile != null) Image.file(_imageFile!, height: 200),
            Row(
              children: [
                IconButton(
                  icon: const Icon(Icons.image),
                  onPressed: _pickImage,
                ),
                const Spacer(),
                ElevatedButton(
                  onPressed: _isLoading ? null : _submitPost,
                  child:
                      _isLoading
                          ? const CircularProgressIndicator()
                          : const Text('Опубликовать'),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}
