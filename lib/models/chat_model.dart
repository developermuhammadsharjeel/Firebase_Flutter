import 'package:cloud_firestore/cloud_firestore.dart';

class Chat {
  final String chatId;
  final List<String> users;
  final String lastMessage;
  final DateTime timestamp;
  final String lastSenderId;
  final int unreadCount;
  final bool isTyping;

  Chat({
    required this.chatId,
    required this.users,
    required this.lastMessage,
    required this.timestamp,
    required this.lastSenderId,
    this.unreadCount = 0,
    this.isTyping = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'chatId': chatId,
      'users': users,
      'lastMessage': lastMessage,
      'timestamp': Timestamp.fromDate(timestamp),
      'lastSenderId': lastSenderId,
      'unreadCount': unreadCount,
      'isTyping': isTyping,
    };
  }

  factory Chat.fromJson(Map<String, dynamic> json) {
    return Chat(
      chatId: json['chatId'] ?? '',
      users: List<String>.from(json['users'] ?? []),
      lastMessage: json['lastMessage'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      lastSenderId: json['lastSenderId'] ?? '',
      unreadCount: json['unreadCount'] ?? 0,
      isTyping: json['isTyping'] ?? false,
    );
  }

  Chat copyWith({
    String? chatId,
    List<String>? users,
    String? lastMessage,
    DateTime? timestamp,
    String? lastSenderId,
    int? unreadCount,
    bool? isTyping,
  }) {
    return Chat(
      chatId: chatId ?? this.chatId,
      users: users ?? this.users,
      lastMessage: lastMessage ?? this.lastMessage,
      timestamp: timestamp ?? this.timestamp,
      lastSenderId: lastSenderId ?? this.lastSenderId,
      unreadCount: unreadCount ?? this.unreadCount,
      isTyping: isTyping ?? this.isTyping,
    );
  }
}
