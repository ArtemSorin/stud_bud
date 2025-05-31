import 'package:flutter/material.dart';

import '../services/auth_service.dart';

class RegisterScreen extends StatefulWidget {
  const RegisterScreen({super.key});

  @override
  _RegisterScreenState createState() => _RegisterScreenState();
}

class _RegisterScreenState extends State<RegisterScreen> {
  final _formKey = GlobalKey<FormState>();
  String username = '', email = '', password = '';

  void _submit() async {
    if (_formKey.currentState!.validate()) {
      bool success = await AuthService.registerUser(
        username: username,
        email: email,
        password: password,
      );

      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text(success ? 'Регистрация успешна!' : 'Ошибка')),
      );

      if (success) {
        //Навигация после регистрации
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: SingleChildScrollView(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            children: [
              SizedBox(height: 160),
              SizedBox(height: 24),
              Text(
                'Создать аккаунт',
                style: TextStyle(fontSize: 28, fontWeight: FontWeight.bold),
              ),
              SizedBox(height: 8),
              Text(
                'Присоединяйся, и найди партнера по учебе!',
                style: TextStyle(fontSize: 16, color: Colors.grey),
              ),
              SizedBox(height: 32),
              Form(
                key: _formKey,
                child: Column(
                  children: [
                    _buildInputField(
                      label: 'Логин',
                      onChanged: (val) => username = val,
                      validator: (val) => val!.isEmpty ? 'Введите логин' : null,
                    ),
                    SizedBox(height: 16),
                    _buildInputField(
                      label: 'Email',
                      onChanged: (val) => email = val,
                      validator: (val) => val!.isEmpty ? 'Введите email' : null,
                    ),
                    SizedBox(height: 16),
                    _buildInputField(
                      label: 'Пароль',
                      obscureText: true,
                      onChanged: (val) => password = val,
                      validator:
                          (val) => val!.isEmpty ? 'Введите пароль' : null,
                    ),
                    SizedBox(height: 32),
                    SizedBox(
                      width: double.infinity,
                      child: ElevatedButton(
                        onPressed: _submit,
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.black,
                          foregroundColor: Colors.white,
                          padding: EdgeInsets.symmetric(vertical: 14),
                          shape: RoundedRectangleBorder(
                            borderRadius: BorderRadius.circular(12),
                          ),
                        ),
                        child: Text(
                          'Зарегистрироваться',
                          style: TextStyle(fontSize: 18),
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildInputField({
    required String label,
    bool obscureText = false,
    required Function(String) onChanged,
    String? Function(String?)? validator,
  }) {
    return TextFormField(
      obscureText: obscureText,
      onChanged: onChanged,
      validator: validator,
      decoration: InputDecoration(
        labelText: label,
        labelStyle: TextStyle(color: Colors.grey),
        border: OutlineInputBorder(borderRadius: BorderRadius.circular(12)),
        focusedBorder: OutlineInputBorder(
          borderRadius: BorderRadius.circular(12),
          borderSide: BorderSide(color: Colors.black),
        ),
      ),
    );
  }
}
