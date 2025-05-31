class Message {
  final String text;
  final DateTime sentAt;
  final bool isMine;

  Message({required this.text, required this.sentAt, required this.isMine});

  factory Message.fromJson(Map<String, dynamic> json, int currentUserId) {
    return Message(
      text: json['text'],
      sentAt: DateTime.parse(json['sent_at']),
      isMine: json['sender_id'] == currentUserId,
    );
  }
}
