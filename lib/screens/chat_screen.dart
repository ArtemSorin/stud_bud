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
  late IO.Socket socket;
  List<Message> _messagesFutureData = [];
  bool _loading = true;
  bool _error = false;

  @override
  void initState() {
    super.initState();
    _loadMessages();
    _initSocket();
  }

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
      });
    });

    socket.onDisconnect((_) {
      print('Socket disconnected');
    });

    socket.onError((error) {
      print('Socket error: $error');
    });
  }

  Future<void> _loadMessages() async {
    try {
      final messages = await MessageService.fetchMessages(widget.chatId);
      setState(() {
        _messagesFutureData = messages;
        _loading = false;
        _error = false;
      });
    } catch (e) {
      setState(() {
        _loading = false;
        _error = true;
      });
    }
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

    _controller.clear();
  }

  @override
  void dispose() {
    socket.disconnect();
    socket.dispose();
    _controller.dispose();
    super.dispose();
  }

  String formatDate(DateTime date) {
    return DateFormat('dd MMMM yyyy', 'ru').format(date);
  }

  String formatTime(DateTime dateTime) {
    return DateFormat('HH:mm').format(dateTime);
  }

  bool isSameDay(DateTime a, DateTime b) {
    return a.year == b.year && a.month == b.month && a.day == b.day;
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
            const SizedBox(width: 10),
            Text(widget.chatUsername),
          ],
        ),
      ),
      body: Column(
        children: [
          Expanded(
            child:
                _loading
                    ? const Center(child: CircularProgressIndicator())
                    : _error
                    ? const Center(child: Text('Ошибка загрузки сообщений'))
                    : _messagesFutureData.isEmpty
                    ? const Center(child: Text('Нет сообщений'))
                    : ListView.builder(
                      reverse: true,
                      itemCount: _messagesFutureData.length,
                      itemBuilder: (context, index) {
                        final message =
                            _messagesFutureData[_messagesFutureData.length -
                                index -
                                1];
                        final isMe = message.isMine;

                        DateTime sentAt = message.sentAt;
                        bool showDateSeparator = false;

                        if (index == _messagesFutureData.length - 1) {
                          showDateSeparator = true;
                        } else {
                          final prevMessage =
                              _messagesFutureData[_messagesFutureData.length -
                                  index -
                                  2];
                          if (!isSameDay(sentAt, prevMessage.sentAt)) {
                            showDateSeparator = true;
                          }
                        }

                        return Column(
                          children: [
                            if (showDateSeparator)
                              Padding(
                                padding: const EdgeInsets.symmetric(
                                  vertical: 10.0,
                                ),
                                child: Row(
                                  children: <Widget>[
                                    const Expanded(child: Divider()),
                                    Padding(
                                      padding: const EdgeInsets.symmetric(
                                        horizontal: 8.0,
                                      ),
                                      child: Text(
                                        formatDate(sentAt),
                                        style: const TextStyle(
                                          color: Colors.grey,
                                        ),
                                      ),
                                    ),
                                    const Expanded(child: Divider()),
                                  ],
                                ),
                              ),
                            Align(
                              alignment:
                                  isMe
                                      ? Alignment.centerRight
                                      : Alignment.centerLeft,
                              child: Container(
                                margin: const EdgeInsets.symmetric(
                                  horizontal: 12,
                                  vertical: 6,
                                ),
                                padding: const EdgeInsets.symmetric(
                                  horizontal: 14,
                                  vertical: 10,
                                ),
                                decoration: BoxDecoration(
                                  color: isMe ? Colors.black : Colors.grey[300],
                                  borderRadius: BorderRadius.circular(12),
                                ),
                                child: Column(
                                  crossAxisAlignment: CrossAxisAlignment.end,
                                  children: [
                                    Text(
                                      message.text,
                                      style: const TextStyle(
                                        fontSize: 16,
                                        color: Colors.white,
                                      ),
                                    ),
                                    const SizedBox(height: 4),
                                    Text(
                                      formatTime(sentAt),
                                      style: const TextStyle(
                                        fontSize: 12,
                                        color: Colors.white70,
                                      ),
                                    ),
                                  ],
                                ),
                              ),
                            ),
                          ],
                        );
                      },
                    ),
          ),
          const Divider(height: 1),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 8.0),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    controller: _controller,
                    decoration: const InputDecoration(
                      hintText: 'Введите сообщение...',
                    ),
                  ),
                ),
                IconButton(
                  icon: const Icon(Icons.send),
                  onPressed: _sendMessage,
                ),
              ],
            ),
          ),
        ],
      ),
    );
  }
}
