import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:uuid/uuid.dart';
import 'dart:io';
import '../models/chat_model.dart';
import '../models/message_model.dart';

class ChatRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;
  final _uuid = const Uuid();

  // Generate chat ID
  String generateChatId(String userId1, String userId2) {
    final ids = [userId1, userId2]..sort();
    return '${ids[0]}_${ids[1]}';
  }

  // Create or get chat
  Future<String> createChat(String currentUserId, String receiverId) async {
    try {
      final chatId = generateChatId(currentUserId, receiverId);
      final chatDoc = await _firestore.collection('chats').doc(chatId).get();

      if (!chatDoc.exists) {
        final chat = Chat(
          chatId: chatId,
          users: [currentUserId, receiverId],
          lastMessage: '',
          timestamp: DateTime.now(),
          lastSenderId: currentUserId,
        );

        await _firestore.collection('chats').doc(chatId).set(chat.toJson());
      }

      return chatId;
    } catch (e) {
      rethrow;
    }
  }

  // Send text message
  Future<void> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String message,
    MessageType messageType = MessageType.text,
    String? mediaUrl,
  }) async {
    try {
      final messageId = _uuid.v4();
      final messageObj = Message(
        id: messageId,
        senderId: senderId,
        receiverId: receiverId,
        message: message,
        timestamp: DateTime.now(),
        messageType: messageType,
        mediaUrl: mediaUrl,
      );

      // Add message to chat
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .set(messageObj.toJson());

      // Update chat last message
      await _firestore.collection('chats').doc(chatId).update({
        'lastMessage': message,
        'timestamp': FieldValue.serverTimestamp(),
        'lastSenderId': senderId,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Upload media
  Future<String> uploadMedia(String chatId, File file, String fileType) async {
    try {
      final fileName = '${_uuid.v4()}_$fileType';
      final ref = _storage
          .ref()
          .child('chat_media')
          .child(chatId)
          .child(fileName);
      
      await ref.putFile(file);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Send media message
  Future<void> sendMediaMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required File file,
    required MessageType messageType,
  }) async {
    try {
      // Upload media
      final mediaUrl = await uploadMedia(
        chatId,
        file,
        messageType.toString().split('.').last,
      );

      // Send message with media URL
      await sendMessage(
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        message: messageType == MessageType.image
            ? '📷 Image'
            : messageType == MessageType.video
                ? '🎥 Video'
                : messageType == MessageType.audio
                    ? '🎵 Audio'
                    : '📎 File',
        messageType: messageType,
        mediaUrl: mediaUrl,
      );
    } catch (e) {
      rethrow;
    }
  }

  // Get messages stream
  Stream<List<Message>> getMessagesStream(String chatId) {
    return _firestore
        .collection('chats')
        .doc(chatId)
        .collection('messages')
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) => snapshot.docs
            .map((doc) => Message.fromJson(doc.data()))
            .toList());
  }

  // Get chats stream for user
  Stream<List<Chat>> getChatsStream(String userId) {
    return _firestore
        .collection('chats')
        .where('users', arrayContains: userId)
        .orderBy('timestamp', descending: true)
        .snapshots()
        .map((snapshot) =>
            snapshot.docs.map((doc) => Chat.fromJson(doc.data())).toList());
  }

  // Mark message as seen
  Future<void> markMessageAsSeen(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({'isSeen': true});
    } catch (e) {
      rethrow;
    }
  }

  // Mark all messages as seen
  Future<void> markAllMessagesAsSeen(String chatId, String receiverId) async {
    try {
      final messagesSnapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: receiverId)
          .where('isSeen', isEqualTo: false)
          .get();

      final batch = _firestore.batch();
      for (var doc in messagesSnapshot.docs) {
        batch.update(doc.reference, {'isSeen': true});
      }
      await batch.commit();
    } catch (e) {
      rethrow;
    }
  }

  // Set typing status
  Future<void> setTypingStatus(String chatId, bool isTyping) async {
    try {
      await _firestore.collection('chats').doc(chatId).update({
        'isTyping': isTyping,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete message for me
  Future<void> deleteMessageForMe(
      String chatId, String messageId, String userId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'deletedFor': FieldValue.arrayUnion([userId])
      });
    } catch (e) {
      rethrow;
    }
  }

  // Delete message for everyone
  Future<void> deleteMessageForEveryone(String chatId, String messageId) async {
    try {
      await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .doc(messageId)
          .update({
        'message': 'This message was deleted',
        'deletedForEveryone': true,
      });
    } catch (e) {
      rethrow;
    }
  }

  // Get unread message count
  Future<int> getUnreadMessageCount(String chatId, String userId) async {
    try {
      final snapshot = await _firestore
          .collection('chats')
          .doc(chatId)
          .collection('messages')
          .where('receiverId', isEqualTo: userId)
          .where('isSeen', isEqualTo: false)
          .get();

      return snapshot.docs.length;
    } catch (e) {
      rethrow;
    }
  }
}
