import 'package:cloud_firestore/cloud_firestore.dart';

class UserModel {
  final String uid;
  final String name;
  final String email;
  final String profileImage;
  final String status;
  final DateTime lastSeen;
  final List<String> contacts;
  final bool isOnline;

  UserModel({
    required this.uid,
    required this.name,
    required this.email,
    this.profileImage = '',
    this.status = "Hey there! I'm using Chatify.",
    required this.lastSeen,
    this.contacts = const [],
    this.isOnline = false,
  });

  Map<String, dynamic> toJson() {
    return {
      'uid': uid,
      'name': name,
      'email': email,
      'profileImage': profileImage,
      'status': status,
      'lastSeen': Timestamp.fromDate(lastSeen),
      'contacts': contacts,
      'isOnline': isOnline,
    };
  }

  factory UserModel.fromJson(Map<String, dynamic> json) {
    return UserModel(
      uid: json['uid'] ?? '',
      name: json['name'] ?? '',
      email: json['email'] ?? '',
      profileImage: json['profileImage'] ?? '',
      status: json['status'] ?? "Hey there! I'm using Chatify.",
      lastSeen: (json['lastSeen'] as Timestamp?)?.toDate() ?? DateTime.now(),
      contacts: List<String>.from(json['contacts'] ?? []),
      isOnline: json['isOnline'] ?? false,
    );
  }

  UserModel copyWith({
    String? uid,
    String? name,
    String? email,
    String? profileImage,
    String? status,
    DateTime? lastSeen,
    List<String>? contacts,
    bool? isOnline,
  }) {
    return UserModel(
      uid: uid ?? this.uid,
      name: name ?? this.name,
      email: email ?? this.email,
      profileImage: profileImage ?? this.profileImage,
      status: status ?? this.status,
      lastSeen: lastSeen ?? this.lastSeen,
      contacts: contacts ?? this.contacts,
      isOnline: isOnline ?? this.isOnline,
    );
  }
}
