# Chatify - WhatsApp Clone in Flutter with Firebase

A full-featured real-time messaging application built with Flutter and Firebase, replicating core WhatsApp functionality.

![Flutter](https://img.shields.io/badge/Flutter-3.35.7-blue)
![Firebase](https://img.shields.io/badge/Firebase-Latest-orange)
![License](https://img.shields.io/badge/License-MIT-green)

## 📱 Features

### Authentication
- ✅ Email & Password sign up
- ✅ Email & Password login
- ✅ Password reset functionality
- ✅ User profile management
- ✅ Persistent authentication state

### User Management
- ✅ Search users by email
- ✅ Add contacts
- ✅ View contacts list
- ✅ Update profile picture
- ✅ Update name and status
- ✅ Online/Offline status tracking
- ✅ Last seen timestamp

### Real-time Chat
- ✅ One-on-one messaging
- ✅ Real-time message delivery
- ✅ Message status indicators (✓ sent, ✓✓ delivered, ✓✓✓ seen)
- ✅ Typing indicators
- ✅ Chat list with latest messages
- ✅ Unread message count

### Media Sharing
- ✅ Send images from gallery
- ✅ Send files
- ✅ Media upload to Firebase Storage
- ✅ Image preview in chat

### Advanced Features
- ✅ Delete message for me
- ✅ Delete message for everyone
- ✅ Block/Unblock users
- ✅ Push notifications (Firebase Cloud Messaging)
- ✅ App lifecycle management (online status)

## 🏗️ Architecture

The app follows **MVVM (Model-View-ViewModel)** architecture pattern with clear separation of concerns:

```
lib/
├── models/           # Data models (User, Message, Chat)
├── repositories/     # Firebase CRUD operations
├── viewmodels/       # Business logic & state management
├── views/           # UI screens
├── services/        # External services (Notifications)
└── main.dart        # App entry point
```

### Architecture Layers

1. **Model Layer**: Data classes with JSON serialization
   - `UserModel`: User profile data
   - `Message`: Chat message data
   - `Chat`: Chat conversation data

2. **Repository Layer**: Firebase operations
   - `AuthRepository`: Authentication operations
   - `UserRepository`: User CRUD operations
   - `ChatRepository`: Chat & messaging operations

3. **ViewModel Layer**: State management with Provider
   - `AuthViewModel`: Auth state & operations
   - `UserViewModel`: User-related state
   - `ChatViewModel`: Chat state & operations

4. **View Layer**: Flutter UI widgets
   - Authentication screens
   - Chat screens
   - Profile & settings screens

## 🗄️ Database Structure

### Firestore Collections

```
users/
  {uid}/
    - uid: string
    - name: string
    - email: string
    - profileImage: string
    - status: string
    - lastSeen: timestamp
    - contacts: array<string>
    - isOnline: boolean
    
    contacts/
      {contact_uid}/
        - addedAt: timestamp
    
    blocked/
      {blocked_uid}/
        - blockedAt: timestamp

chats/
  {chatId}/
    - chatId: string (format: userId1_userId2)
    - users: array<string>
    - lastMessage: string
    - timestamp: timestamp
    - lastSenderId: string
    - unreadCount: number
    - isTyping: boolean
    
    messages/
      {messageId}/
        - id: string
        - senderId: string
        - receiverId: string
        - message: string
        - timestamp: timestamp
        - messageType: string (text|image|video|file|audio)
        - isSeen: boolean
        - mediaUrl: string (optional)
```

### Firebase Storage Structure

```
profile_images/
  {uid}.jpg

chat_media/
  {chatId}/
    {messageId}_image.jpg
    {messageId}_video.mp4
    {messageId}_file.pdf
```

## 🛠️ Tech Stack

| Component | Technology |
|-----------|-----------|
| Framework | Flutter 3.35+ |
| Backend | Firebase |
| Authentication | Firebase Authentication |
| Database | Cloud Firestore |
| Storage | Firebase Storage |
| Push Notifications | Firebase Cloud Messaging |
| State Management | Provider |
| UI Framework | Material 3 Design |

## 📦 Dependencies

```yaml
dependencies:
  # Firebase
  firebase_core: ^3.3.0
  firebase_auth: ^5.1.4
  cloud_firestore: ^5.2.1
  firebase_storage: ^12.1.3
  firebase_messaging: ^15.0.4
  
  # State Management
  provider: ^6.1.2
  
  # UI & Media
  cached_network_image: ^3.3.1
  image_picker: ^1.1.2
  file_picker: ^8.0.6
  intl: ^0.19.0
  timeago: ^3.7.0
  
  # Utilities
  uuid: ^4.4.2
  shared_preferences: ^2.2.3
  permission_handler: ^11.3.1
  flutter_local_notifications: ^17.2.2
```

## 🚀 Getting Started

### Prerequisites

- Flutter SDK (3.0.0 or higher)
- Dart SDK (3.0.0 or higher)
- Firebase account
- Android Studio / Xcode for mobile development

### Firebase Setup

1. **Create a Firebase Project**
   - Go to [Firebase Console](https://console.firebase.google.com/)
   - Create a new project
   - Add an Android and/or iOS app

2. **Enable Firebase Services**
   - Enable **Authentication** (Email/Password)
   - Enable **Cloud Firestore**
   - Enable **Firebase Storage**
   - Enable **Cloud Messaging**

3. **Configure FlutterFire**

   Install FlutterFire CLI:
   ```bash
   dart pub global activate flutterfire_cli
   ```

   Run configuration:
   ```bash
   flutterfire configure
   ```

   This will:
   - Generate `firebase_options.dart`
   - Download `google-services.json` (Android)
   - Download `GoogleService-Info.plist` (iOS)

### Installation

1. **Clone the repository**
   ```bash
   git clone https://github.com/developermuhammadsharjeel/Firebase_Flutter.git
   cd Firebase_Flutter
   ```

2. **Install dependencies**
   ```bash
   flutter pub get
   ```

3. **Run the app**
   ```bash
   flutter run
   ```

## 🔒 Security Rules

### Firestore Security Rules

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User documents
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
      
      // User contacts
      match /contacts/{contactId} {
        allow read, write: if request.auth.uid == userId;
      }
      
      // Blocked users
      match /blocked/{blockedId} {
        allow read, write: if request.auth.uid == userId;
      }
    }
    
    // Chat documents
    match /chats/{chatId} {
      allow read: if request.auth.uid in resource.data.users;
      allow write: if request.auth.uid in request.resource.data.users;
      
      // Messages in chat
      match /messages/{messageId} {
        allow read: if request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.users;
        allow create: if request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.users;
        allow update, delete: if request.auth.uid == resource.data.senderId;
      }
    }
  }
}
```

### Storage Security Rules

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images
    match /profile_images/{userId}.jpg {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
    }
    
    // Chat media
    match /chat_media/{chatId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null;
    }
  }
}
```

## 📱 Screenshots

*Screenshots will be available after deployment*

## 🎯 Future Enhancements

- [ ] Voice messages
- [ ] Video calls
- [ ] Audio calls
- [ ] Group chats
- [ ] Status/Stories feature
- [ ] Message reactions (emojis)
- [ ] Message forwarding
- [ ] Dark mode
- [ ] Chat backup & restore
- [ ] End-to-end encryption
- [ ] Read receipts settings
- [ ] Custom notification sounds
- [ ] Message search
- [ ] Media gallery viewer
- [ ] Chat export

## 🤝 Contributing

Contributions are welcome! Please feel free to submit a Pull Request.

1. Fork the project
2. Create your feature branch (`git checkout -b feature/AmazingFeature`)
3. Commit your changes (`git commit -m 'Add some AmazingFeature'`)
4. Push to the branch (`git push origin feature/AmazingFeature`)
5. Open a Pull Request

## 📄 License

This project is licensed under the MIT License - see the LICENSE file for details.

## 👨‍💻 Author

**Muhammad Sharjeel**
- GitHub: [@developermuhammadsharjeel](https://github.com/developermuhammadsharjeel)

## 🙏 Acknowledgments

- Flutter team for the amazing framework
- Firebase team for the comprehensive backend services
- The Flutter community for helpful packages and resources

## 📞 Support

For support, email your-email@example.com or open an issue in this repository.

---

**Note**: This is a demonstration project. For production use, implement additional security measures, error handling, and testing.