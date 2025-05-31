import 'package:flutter/material.dart';
import 'package:stud_bud/screens/chat_screen.dart';
import '../models/chat_model.dart';
import '../services/chat_service.dart';

class ChatListScreen extends StatefulWidget {
  const ChatListScreen({super.key});

  @override
  _ChatListScreenState createState() => _ChatListScreenState();
}

class _ChatListScreenState extends State<ChatListScreen> {
  late Future<List<Chat>> _chatsFuture;

  @override
  void initState() {
    super.initState();
    _chatsFuture = ChatService.fetchChats();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: FutureBuilder<List<Chat>>(
        future: _chatsFuture,
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return Center(child: CircularProgressIndicator());
          } else if (snapshot.hasError) {
            return Center(child: Text('Ошибка загрузки чатов'));
          }

          final chats = snapshot.data!;
          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              return ListTile(
                leading: CircleAvatar(
                  backgroundImage: NetworkImage(chat.userAvatar ?? ''),
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
