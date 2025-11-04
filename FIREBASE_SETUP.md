# Firebase Setup Guide for Chatify

This guide will help you set up Firebase for the Chatify app.

## Step 1: Create a Firebase Project

1. Go to [Firebase Console](https://console.firebase.google.com/)
2. Click "Add project"
3. Enter project name: "Chatify" (or your preferred name)
4. Follow the setup wizard
5. Click "Create project"

## Step 2: Register Your App

### For Android:

1. In Firebase Console, click the Android icon
2. Enter Android package name: `com.chatify.app`
3. Enter app nickname (optional): "Chatify Android"
4. Download `google-services.json`
5. Place it in: `android/app/google-services.json`

### For iOS:

1. In Firebase Console, click the iOS icon
2. Enter iOS bundle ID: `com.chatify.app`
3. Enter app nickname (optional): "Chatify iOS"
4. Download `GoogleService-Info.plist`
5. Place it in: `ios/Runner/GoogleService-Info.plist`

## Step 3: Enable Firebase Services

### Authentication

1. Go to Firebase Console → Authentication
2. Click "Get Started"
3. Enable "Email/Password" sign-in method
4. Save changes

### Cloud Firestore

1. Go to Firebase Console → Firestore Database
2. Click "Create database"
3. Choose "Start in test mode" (we'll add security rules later)
4. Select your region
5. Click "Enable"

### Firebase Storage

1. Go to Firebase Console → Storage
2. Click "Get Started"
3. Choose "Start in test mode"
4. Click "Done"

### Cloud Messaging (Optional - for notifications)

1. Go to Firebase Console → Cloud Messaging
2. Cloud Messaging is automatically enabled
3. For iOS, you'll need to upload your APNs key

## Step 4: Install FlutterFire CLI

```bash
# Install FlutterFire CLI globally
dart pub global activate flutterfire_cli

# Make sure it's in your PATH
export PATH="$PATH":"$HOME/.pub-cache/bin"
```

## Step 5: Configure FlutterFire

Run the following command in your project root:

```bash
flutterfire configure
```

This will:
- Detect your Firebase projects
- Let you select which project to use
- Generate `lib/firebase_options.dart`
- Update platform-specific configuration files

Select your project and platforms (Android/iOS) when prompted.

## Step 6: Update Security Rules

### Firestore Rules

Go to Firestore → Rules and replace with:

```javascript
rules_version = '2';
service cloud.firestore {
  match /databases/{database}/documents {
    // User documents
    match /users/{userId} {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId;
      
      match /contacts/{contactId} {
        allow read, write: if request.auth.uid == userId;
      }
      
      match /blocked/{blockedId} {
        allow read, write: if request.auth.uid == userId;
      }
    }
    
    // Chat documents
    match /chats/{chatId} {
      allow read: if request.auth.uid in resource.data.users;
      allow write: if request.auth.uid in request.resource.data.users;
      
      match /messages/{messageId} {
        allow read: if request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.users;
        allow create: if request.auth.uid in get(/databases/$(database)/documents/chats/$(chatId)).data.users;
        allow update, delete: if request.auth.uid == resource.data.senderId;
      }
    }
  }
}
```

### Storage Rules

Go to Storage → Rules and replace with:

```javascript
rules_version = '2';
service firebase.storage {
  match /b/{bucket}/o {
    // Profile images
    match /profile_images/{userId}.jpg {
      allow read: if request.auth != null;
      allow write: if request.auth.uid == userId && request.resource.size < 5 * 1024 * 1024;
    }
    
    // Chat media
    match /chat_media/{chatId}/{fileName} {
      allow read: if request.auth != null;
      allow write: if request.auth != null && request.resource.size < 10 * 1024 * 1024;
    }
  }
}
```

## Step 7: Test the Connection

Run your app:

```bash
flutter run
```

Try signing up with a test account. If successful, you should see:
- User created in Firebase Authentication
- User document created in Firestore

## Step 8: Enable Indexes (Optional but Recommended)

As you use the app, Firestore may suggest creating indexes for queries. You can create them via:

1. Firebase Console → Firestore → Indexes
2. Or click the link in error messages when running queries

Common indexes needed:
- `chats` collection: `users` (Array) + `timestamp` (Descending)
- `messages` subcollection: `receiverId` (Ascending) + `isSeen` (Ascending)

## Troubleshooting

### Issue: Firebase not initialized

**Solution**: Make sure you've run `flutterfire configure` and that `firebase_options.dart` exists.

### Issue: Authentication errors

**Solution**: Check that Email/Password authentication is enabled in Firebase Console.

### Issue: Permission denied errors

**Solution**: Verify that Firestore and Storage security rules are properly configured.

### Issue: Android build fails

**Solution**: 
- Ensure `google-services.json` is in `android/app/`
- Check that `android/build.gradle.kts` includes the Google Services plugin
- Run `flutter clean` and rebuild

### Issue: iOS build fails

**Solution**:
- Ensure `GoogleService-Info.plist` is in `ios/Runner/`
- Open `ios/Runner.xcworkspace` in Xcode and verify the file is included
- Run `pod install` in the `ios` directory

## Additional Configuration

### Android Push Notifications

Add to `android/app/src/main/AndroidManifest.xml`:

```xml
<meta-data
    android:name="com.google.firebase.messaging.default_notification_channel_id"
    android:value="chatify_channel" />
```

### iOS Push Notifications

1. Enable Push Notifications capability in Xcode
2. Upload APNs key to Firebase Console
3. Add notification permissions to `Info.plist` (already included)

## Next Steps

1. Test all features: authentication, messaging, media upload
2. Monitor usage in Firebase Console
3. Set up Firebase Analytics (optional)
4. Configure Cloud Functions for advanced features (optional)
5. Deploy security rules to production mode

## Support

For issues specific to Firebase setup:
- [Firebase Documentation](https://firebase.google.com/docs)
- [FlutterFire Documentation](https://firebase.flutter.dev/)

For issues with the Chatify app, please open an issue on GitHub.
