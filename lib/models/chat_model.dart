class Chat {
  final int chatId;
  final String username;
  final String? userAvatar;
  final String lastMessage;
  final String time;

  Chat({
    required this.chatId,
    required this.username,
    this.userAvatar,
    required this.lastMessage,
    required this.time,
  });

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chat_id'],
      username: json['username'],
      userAvatar: json['user_avatar'],
      lastMessage: json['last_message'],
      time: json['time'],
    );
  }
}
