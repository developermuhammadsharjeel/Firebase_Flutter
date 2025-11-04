import 'package:flutter/material.dart';
import 'dart:io';
import '../models/chat_model.dart';
import '../models/message_model.dart';
import '../repositories/chat_repository.dart';

class ChatViewModel extends ChangeNotifier {
  final ChatRepository _chatRepository = ChatRepository();

  bool _isLoading = false;
  String? _errorMessage;
  bool _isSending = false;

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  bool get isSending => _isSending;

  // Create or get chat
  Future<String?> createChat(String currentUserId, String receiverId) async {
    try {
      _isLoading = true;
      notifyListeners();

      final chatId = await _chatRepository.createChat(currentUserId, receiverId);

      _isLoading = false;
      notifyListeners();
      return chatId;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to create chat';
      notifyListeners();
      return null;
    }
  }

  // Send text message
  Future<bool> sendMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required String message,
  }) async {
    try {
      _isSending = true;
      notifyListeners();

      await _chatRepository.sendMessage(
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        message: message,
      );

      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSending = false;
      _errorMessage = 'Failed to send message';
      notifyListeners();
      return false;
    }
  }

  // Send media message
  Future<bool> sendMediaMessage({
    required String chatId,
    required String senderId,
    required String receiverId,
    required File file,
    required MessageType messageType,
  }) async {
    try {
      _isSending = true;
      notifyListeners();

      await _chatRepository.sendMediaMessage(
        chatId: chatId,
        senderId: senderId,
        receiverId: receiverId,
        file: file,
        messageType: messageType,
      );

      _isSending = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isSending = false;
      _errorMessage = 'Failed to send media';
      notifyListeners();
      return false;
    }
  }

  // Get messages stream
  Stream<List<Message>> getMessagesStream(String chatId) {
    return _chatRepository.getMessagesStream(chatId);
  }

  // Get chats stream
  Stream<List<Chat>> getChatsStream(String userId) {
    return _chatRepository.getChatsStream(userId);
  }

  // Mark message as seen
  Future<void> markMessageAsSeen(String chatId, String messageId) async {
    try {
      await _chatRepository.markMessageAsSeen(chatId, messageId);
    } catch (e) {
      // Silent fail
    }
  }

  // Mark all messages as seen
  Future<void> markAllMessagesAsSeen(String chatId, String receiverId) async {
    try {
      await _chatRepository.markAllMessagesAsSeen(chatId, receiverId);
    } catch (e) {
      // Silent fail
    }
  }

  // Set typing status
  Future<void> setTypingStatus(String chatId, bool isTyping) async {
    try {
      await _chatRepository.setTypingStatus(chatId, isTyping);
    } catch (e) {
      // Silent fail
    }
  }

  // Delete message for me
  Future<bool> deleteMessageForMe(
      String chatId, String messageId, String userId) async {
    try {
      await _chatRepository.deleteMessageForMe(chatId, messageId, userId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete message';
      notifyListeners();
      return false;
    }
  }

  // Delete message for everyone
  Future<bool> deleteMessageForEveryone(String chatId, String messageId) async {
    try {
      await _chatRepository.deleteMessageForEveryone(chatId, messageId);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to delete message';
      notifyListeners();
      return false;
    }
  }

  // Get unread count
  Future<int> getUnreadMessageCount(String chatId, String userId) async {
    try {
      return await _chatRepository.getUnreadMessageCount(chatId, userId);
    } catch (e) {
      return 0;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Generate chat ID
  String generateChatId(String userId1, String userId2) {
    return _chatRepository.generateChatId(userId1, userId2);
  }
}
