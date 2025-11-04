import 'package:cloud_firestore/cloud_firestore.dart';

enum MessageType { text, image, video, file, audio }

class Message {
  final String id;
  final String senderId;
  final String receiverId;
  final String message;
  final DateTime timestamp;
  final MessageType messageType;
  final bool isSeen;
  final String? mediaUrl;

  Message({
    required this.id,
    required this.senderId,
    required this.receiverId,
    required this.message,
    required this.timestamp,
    this.messageType = MessageType.text,
    this.isSeen = false,
    this.mediaUrl,
  });

  Map<String, dynamic> toJson() {
    return {
      'id': id,
      'senderId': senderId,
      'receiverId': receiverId,
      'message': message,
      'timestamp': Timestamp.fromDate(timestamp),
      'messageType': messageType.toString().split('.').last,
      'isSeen': isSeen,
      'mediaUrl': mediaUrl,
    };
  }

  factory Message.fromJson(Map<String, dynamic> json) {
    return Message(
      id: json['id'] ?? '',
      senderId: json['senderId'] ?? '',
      receiverId: json['receiverId'] ?? '',
      message: json['message'] ?? '',
      timestamp: (json['timestamp'] as Timestamp?)?.toDate() ?? DateTime.now(),
      messageType: MessageType.values.firstWhere(
        (e) => e.toString().split('.').last == json['messageType'],
        orElse: () => MessageType.text,
      ),
      isSeen: json['isSeen'] ?? false,
      mediaUrl: json['mediaUrl'],
    );
  }

  Message copyWith({
    String? id,
    String? senderId,
    String? receiverId,
    String? message,
    DateTime? timestamp,
    MessageType? messageType,
    bool? isSeen,
    String? mediaUrl,
  }) {
    return Message(
      id: id ?? this.id,
      senderId: senderId ?? this.senderId,
      receiverId: receiverId ?? this.receiverId,
      message: message ?? this.message,
      timestamp: timestamp ?? this.timestamp,
      messageType: messageType ?? this.messageType,
      isSeen: isSeen ?? this.isSeen,
      mediaUrl: mediaUrl ?? this.mediaUrl,
    );
  }
}
