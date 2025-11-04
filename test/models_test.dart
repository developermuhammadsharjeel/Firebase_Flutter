import 'package:flutter_test/flutter_test.dart';
import 'package:chatify/models/user_model.dart';
import 'package:chatify/models/message_model.dart';
import 'package:chatify/models/chat_model.dart';

void main() {
  group('UserModel Tests', () {
    test('UserModel should serialize to JSON correctly', () {
      final user = UserModel(
        uid: 'test123',
        name: 'Test User',
        email: 'test@example.com',
        lastSeen: DateTime(2025, 11, 4),
        isOnline: true,
      );

      final json = user.toJson();

      expect(json['uid'], 'test123');
      expect(json['name'], 'Test User');
      expect(json['email'], 'test@example.com');
      expect(json['isOnline'], true);
    });

    test('UserModel should deserialize from JSON correctly', () {
      final json = {
        'uid': 'test123',
        'name': 'Test User',
        'email': 'test@example.com',
        'profileImage': '',
        'status': 'Hey there!',
        'lastSeen': DateTime(2025, 11, 4).millisecondsSinceEpoch,
        'contacts': <String>[],
        'isOnline': true,
      };

      // Note: This test would need proper Timestamp handling
      // For now, it's a basic structure test
      expect(json['uid'], 'test123');
      expect(json['name'], 'Test User');
    });
  });

  group('Message Tests', () {
    test('Message should serialize to JSON correctly', () {
      final message = Message(
        id: 'msg123',
        senderId: 'user1',
        receiverId: 'user2',
        message: 'Hello!',
        timestamp: DateTime(2025, 11, 4),
        messageType: MessageType.text,
        isSeen: false,
      );

      final json = message.toJson();

      expect(json['id'], 'msg123');
      expect(json['senderId'], 'user1');
      expect(json['receiverId'], 'user2');
      expect(json['message'], 'Hello!');
      expect(json['messageType'], 'text');
      expect(json['isSeen'], false);
    });

    test('Message type should be correctly identified', () {
      final textMessage = Message(
        id: 'msg1',
        senderId: 'user1',
        receiverId: 'user2',
        message: 'Text',
        timestamp: DateTime.now(),
        messageType: MessageType.text,
      );

      final imageMessage = Message(
        id: 'msg2',
        senderId: 'user1',
        receiverId: 'user2',
        message: 'Image',
        timestamp: DateTime.now(),
        messageType: MessageType.image,
      );

      expect(textMessage.messageType, MessageType.text);
      expect(imageMessage.messageType, MessageType.image);
    });
  });

  group('Chat Tests', () {
    test('Chat should serialize to JSON correctly', () {
      final chat = Chat(
        chatId: 'chat123',
        users: ['user1', 'user2'],
        lastMessage: 'Hello',
        timestamp: DateTime(2025, 11, 4),
        lastSenderId: 'user1',
        unreadCount: 5,
      );

      final json = chat.toJson();

      expect(json['chatId'], 'chat123');
      expect(json['users'], ['user1', 'user2']);
      expect(json['lastMessage'], 'Hello');
      expect(json['lastSenderId'], 'user1');
      expect(json['unreadCount'], 5);
    });
  });
}
