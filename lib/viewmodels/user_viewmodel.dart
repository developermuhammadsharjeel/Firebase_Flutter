import 'package:flutter/material.dart';
import 'dart:io';
import '../models/user_model.dart';
import '../repositories/user_repository.dart';

class UserViewModel extends ChangeNotifier {
  final UserRepository _userRepository = UserRepository();

  bool _isLoading = false;
  String? _errorMessage;
  List<UserModel> _searchResults = [];
  List<UserModel> _contacts = [];

  bool get isLoading => _isLoading;
  String? get errorMessage => _errorMessage;
  List<UserModel> get searchResults => _searchResults;
  List<UserModel> get contacts => _contacts;

  // Search users
  Future<void> searchUsers(String query) async {
    try {
      _isLoading = true;
      notifyListeners();

      _searchResults = await _userRepository.searchUsers(query);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to search users';
      notifyListeners();
    }
  }

  // Add contact
  Future<bool> addContact(String currentUserId, String contactUserId) async {
    try {
      _isLoading = true;
      notifyListeners();

      await _userRepository.addContact(currentUserId, contactUserId);

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to add contact';
      notifyListeners();
      return false;
    }
  }

  // Load contacts
  Future<void> loadContacts(String userId) async {
    try {
      _isLoading = true;
      notifyListeners();

      _contacts = await _userRepository.getContacts(userId);

      _isLoading = false;
      notifyListeners();
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to load contacts';
      notifyListeners();
    }
  }

  // Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      return await _userRepository.getUserById(uid);
    } catch (e) {
      _errorMessage = 'Failed to load user';
      notifyListeners();
      return null;
    }
  }

  // Get user stream
  Stream<UserModel?> getUserStream(String uid) {
    return _userRepository.getUserByIdStream(uid);
  }

  // Update profile
  Future<bool> updateProfile({
    required String uid,
    String? name,
    String? status,
    File? profileImageFile,
  }) async {
    try {
      _isLoading = true;
      notifyListeners();

      String? profileImageUrl;
      if (profileImageFile != null) {
        profileImageUrl = await _userRepository.uploadProfileImage(
          uid,
          profileImageFile,
        );
      }

      await _userRepository.updateProfile(
        uid: uid,
        name: name,
        status: status,
        profileImage: profileImageUrl,
      );

      _isLoading = false;
      notifyListeners();
      return true;
    } catch (e) {
      _isLoading = false;
      _errorMessage = 'Failed to update profile';
      notifyListeners();
      return false;
    }
  }

  // Block user
  Future<bool> blockUser(String currentUserId, String userToBlock) async {
    try {
      await _userRepository.blockUser(currentUserId, userToBlock);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to block user';
      notifyListeners();
      return false;
    }
  }

  // Unblock user
  Future<bool> unblockUser(String currentUserId, String userToUnblock) async {
    try {
      await _userRepository.unblockUser(currentUserId, userToUnblock);
      return true;
    } catch (e) {
      _errorMessage = 'Failed to unblock user';
      notifyListeners();
      return false;
    }
  }

  // Check if blocked
  Future<bool> isUserBlocked(String currentUserId, String userId) async {
    try {
      return await _userRepository.isUserBlocked(currentUserId, userId);
    } catch (e) {
      return false;
    }
  }

  // Clear error
  void clearError() {
    _errorMessage = null;
    notifyListeners();
  }

  // Clear search results
  void clearSearchResults() {
    _searchResults = [];
    notifyListeners();
  }
}
