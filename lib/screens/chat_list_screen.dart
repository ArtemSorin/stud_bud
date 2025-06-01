import 'package:flutter/material.dart';
import 'package:stud_bud/screens/chat_screen.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';
import '../services/auth_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<Chat>> _chatsFuture;
  int? _userId;

  @override
  void initState() {
    super.initState();
    _loadUserIdAndChats();
  }

  Future<void> _loadUserIdAndChats() async {
    final userId = await AuthService.getUserId();
    setState(() {
      _userId = userId;
      _chatsFuture = ChatService.fetchChats();
    });
  }

  @override
  Widget build(BuildContext context) {
    if (_userId == null) {
      return const Scaffold(body: Center(child: CircularProgressIndicator()));
    }

    return Scaffold(
      body: FutureBuilder<List<Chat>>(
        future: _chatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return const Center(child: Text('Ошибка загрузки чатов'));
          }

          final chats = snapshot.data!;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage:
                      chat.userAvatar != null
                          ? NetworkImage(chat.userAvatar!)
                          : null,
                  child:
                      chat.userAvatar == null ? Text(chat.username[0]) : null,
                ),
                title: Text(chat.username),
                subtitle: Text(chat.lastMessage),
                trailing: Text(chat.time),
                onTap: () {
                  Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder:
                          (_) => ChatScreen(
                            chatId: chat.chatId,
                            userId: _userId!,
                            chatUsername: chat.username,
                            chatAvatar: chat.userAvatar,
                          ),
                    ),
                  );
                },
              );
            },
          );
        },
      ),
    );
  }
}
