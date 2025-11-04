import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'dart:io';
import '../models/user_model.dart';

class UserRepository {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseStorage _storage = FirebaseStorage.instance;

  // Get user by ID
  Future<UserModel?> getUserById(String uid) async {
    try {
      final doc = await _firestore.collection('users').doc(uid).get();
      if (doc.exists) {
        return UserModel.fromJson(doc.data()!);
      }
      return null;
    } catch (e) {
      rethrow;
    }
  }

  // Get user by ID as stream
  Stream<UserModel?> getUserByIdStream(String uid) {
    return _firestore
        .collection('users')
        .doc(uid)
        .snapshots()
        .map((doc) => doc.exists ? UserModel.fromJson(doc.data()!) : null);
  }

  // Search users by email or name
  Future<List<UserModel>> searchUsers(String query) async {
    try {
      final querySnapshot = await _firestore
          .collection('users')
          .where('email', isGreaterThanOrEqualTo: query)
          .where('email', isLessThanOrEqualTo: '$query\uf8ff')
          .get();

      return querySnapshot.docs
          .map((doc) => UserModel.fromJson(doc.data()))
          .toList();
    } catch (e) {
      rethrow;
    }
  }

  // Add contact
  Future<void> addContact(String currentUserId, String contactUserId) async {
    try {
      // Add contact to current user
      await _firestore.collection('users').doc(currentUserId).update({
        'contacts': FieldValue.arrayUnion([contactUserId])
      });

      // Add current user to contact's contacts
      await _firestore.collection('users').doc(contactUserId).update({
        'contacts': FieldValue.arrayUnion([currentUserId])
      });

      // Create contact document
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('contacts')
          .doc(contactUserId)
          .set({'addedAt': FieldValue.serverTimestamp()});

      await _firestore
          .collection('users')
          .doc(contactUserId)
          .collection('contacts')
          .doc(currentUserId)
          .set({'addedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      rethrow;
    }
  }

  // Get contacts
  Future<List<UserModel>> getContacts(String userId) async {
    try {
      final userDoc = await _firestore.collection('users').doc(userId).get();
      if (!userDoc.exists) return [];

      final contacts = List<String>.from(userDoc.data()?['contacts'] ?? []);
      
      if (contacts.isEmpty) return [];

      final List<UserModel> contactUsers = [];
      for (String contactId in contacts) {
        final user = await getUserById(contactId);
        if (user != null) {
          contactUsers.add(user);
        }
      }

      return contactUsers;
    } catch (e) {
      rethrow;
    }
  }

  // Update user profile
  Future<void> updateProfile({
    required String uid,
    String? name,
    String? status,
    String? profileImage,
  }) async {
    try {
      final Map<String, dynamic> updates = {};
      if (name != null) updates['name'] = name;
      if (status != null) updates['status'] = status;
      if (profileImage != null) updates['profileImage'] = profileImage;

      await _firestore.collection('users').doc(uid).update(updates);
    } catch (e) {
      rethrow;
    }
  }

  // Upload profile image
  Future<String> uploadProfileImage(String uid, File imageFile) async {
    try {
      final ref = _storage.ref().child('profile_images').child('$uid.jpg');
      await ref.putFile(imageFile);
      return await ref.getDownloadURL();
    } catch (e) {
      rethrow;
    }
  }

  // Block user
  Future<void> blockUser(String currentUserId, String userToBlock) async {
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('blocked')
          .doc(userToBlock)
          .set({'blockedAt': FieldValue.serverTimestamp()});
    } catch (e) {
      rethrow;
    }
  }

  // Unblock user
  Future<void> unblockUser(String currentUserId, String userToUnblock) async {
    try {
      await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('blocked')
          .doc(userToUnblock)
          .delete();
    } catch (e) {
      rethrow;
    }
  }

  // Check if user is blocked
  Future<bool> isUserBlocked(String currentUserId, String userId) async {
    try {
      final doc = await _firestore
          .collection('users')
          .doc(currentUserId)
          .collection('blocked')
          .doc(userId)
          .get();
      return doc.exists;
    } catch (e) {
      rethrow;
    }
  }
}
