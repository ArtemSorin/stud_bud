import 'package:flutter/material.dart';
import 'package:intl/intl.dart';
import 'package:stud_bud/services/auth_service.dart';
import 'package:stud_bud/services/chat_service.dart';
import '../models/message_model.dart';
import '../services/message_service.dart';
import 'package:socket_io_client/socket_io_client.dart' as IO;

class ChatScreen extends StatefulWidget {
  final int userId;
  final int chatId;
  final String chatUsername;
  final String? chatAvatar;

  const ChatScreen({
    super.key,
    required this.userId,
    required this.chatId,
    required this.chatUsername,
    this.chatAvatar,
  });

  @override
  _ChatScreenState createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final TextEditingController _controller = TextEditingController();
  late Future<List<Message>> _messagesFuture;
  late IO.Socket socket;

  void _initSocket() {
    socket = IO.io('http://localhost:5000', <String, dynamic>{
      'transports': ['websocket'],
      'autoConnect': false,
    });

    socket.connect();

    socket.onConnect((_) {
      socket.emit('joinChat', widget.chatId);
    });

    socket.on('newMessage', (data) {
      final msg = Message.fromJson(data, widget.userId);
      setState(() {
        _messagesFutureData.add(msg);
        _messagesFuture = Future.value(List.from(_messagesFutureData));
      });
    });
  }

  List<Message> _messagesFutureData = [];

  @override
  void initState() {
    super.initState();
    _messagesFuture = ChatService.fetchMessages(widget.chatId);
    _loadMessages();
    _initSocket();
  }

  Future<void> _loadMessages() async {
    final messages = await MessageService.fetchMessages(widget.chatId);
    _messagesFutureData = messages;
    setState(() {
      _messagesFuture = Future.value(messages);
    });
  }

  Future<void> _sendMessage() async {
    final text = _controller.text.trim();
    if (text.isEmpty) return;

    final userId = await AuthService.getUserId();

    socket.emit('sendMessage', {
      'chatId': widget.chatId,
      'userId': userId,
      'text': text,
    });

    @override
    void dispose() {
      socket.disconnect();
      socket.dispose();
      super.dispose();
    }

    _controller.clear();
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'ru').format(date);
  }

  String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          children: [
            CircleAvatar(
              backgroundImage:
                  widget.chatAvatar != null
                      ? NetworkImage(widget.chatAvatar!)
                      : null,
              child:
                  widget.chatAvatar == null
                      ? Text(widget.chatUsername[0])
                      : null,
            ),
            SizedBox(width: 10),
            Text(widget.chatUsername),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child: FutureBuilder<List<Message>>(
              future: _messagesFuture,
              builder: (context, snapshot) {
                if (snapshot.connectionState == ConnectionState.waiting) {
                  return Center(child: CircularProgressIndicator());
                } else if (snapshot.hasError) {
                  return Center(child: Text('Ошибка загрузки сообщений'));
                }

                final messages = snapshot.data!;
                return ListView.builder(
                  reverse: true,
                  itemCount: messages.length,
                  itemBuilder: (context, index) {
                    final message = messages[messages.length - index - 1];
                    final isMe = message.isMine;

                    DateTime sentAt = message.sentAt;
                    bool showDateSeparator = false;

                    if (index == messages.length - 1) {
                      showDateSeparator = true;
                    } else {
                      final prevMessage = messages[messages.length - index - 2];
                      if (!isSameDay(sentAt, prevMessage.sentAt)) {
                        showDateSeparator = true;
                      }
                    }

                    return Column(
                      children: [
                        if (showDateSeparator)
                          Padding(
                            padding: const EdgeInsets.symmetric(vertical: 10.0),
                            child: Row(
                              children: <Widget>[
                                Expanded(child: Divider()),
                                Padding(
                                  padding: const EdgeInsets.symmetric(
                                    horizontal: 8.0,
                                  ),
                                  child: Text(
                                    formatDate(sentAt),
                                    style: TextStyle(color: Colors.grey),
                                  ),
                                ),
                                Expanded(child: Divider()),
                              ],
                            ),
                          ),
                        Align(
                          alignment:
                              isMe
                                  ? Alignment.centerRight
                                  : Alignment.centerLeft,
                          child: Container(
                            margin: EdgeInsets.symmetric(
                              horizontal: 12,
                              vertical: 6,
                            ),
                            padding: EdgeInsets.symmetric(
                              horizontal: 14,
                              vertical: 10,
                            ),
                            decoration: BoxDecoration(
                              color: isMe ? Colors.blue[200] : Colors.grey[300],
                              borderRadius: BorderRadius.circular(12),
                            ),
                            child: Column(
                              crossAxisAlignment: CrossAxisAlignment.end,
                              children: [
                                Text(
                                  message.text,
                                  style: TextStyle(fontSize: 16),
                                ),
                                SizedBox(height: 4),
                                Text(
                                  formatTime(sentAt),
                                  style: TextStyle(
                                    fontSize: 12,
                                    color: Colors.black54,
                                  ),
                                ),
                              ],
                            ),
                          ),
                        ),
                      ],
                    );
                  },
                );
              },
            ),
          ),
          Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: InputDecoration(
                      hintText: 'Введите сообщение...',
                    ),
                  ),
                ),
                IconButton(icon: Icon(Icons.send), onPressed: _sendMessage),
              ],
            ),
          ),
        ],
      ),
    );
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
  }
}
