import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:timeago/timeago.dart' as timeago;
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/chat_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../models/chat_model.dart';
import '../models/user_model.dart';
import 'chat_screen.dart';

class ChatsListScreen extends StatefulWidget {
  const ChatsListScreen({super.key});

  @override
  State<ChatsListScreen> createState() => _ChatsListScreenState();
}

class _ChatsListScreenState extends State<ChatsListScreen> {
  @override
  Widget build(BuildContext context) {
    final authViewModel = context.watch<AuthViewModel>();
    final chatViewModel = context.watch<ChatViewModel>();
    final currentUserId = authViewModel.currentUser?.uid;

    if (currentUserId == null) {
      return const Scaffold(
        body: Center(child: Text('Please log in')),
      );
    }

    return Scaffold(
      appBar: AppBar(
        title: const Text('Chats'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: StreamBuilder<List<Chat>>(
        stream: chatViewModel.getChatsStream(currentUserId),
        builder: (context, snapshot) {
          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}'));
          }

          final chats = snapshot.data ?? [];

          if (chats.isEmpty) {
            return Center(
              child: Column(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Icon(
                    Icons.chat_bubble_outline,
                    size: 80,
                    color: Colors.grey[400],
                  ),
                  const SizedBox(height: 16),
                  Text(
                    'No chats yet',
                    style: TextStyle(
                      fontSize: 18,
                      color: Colors.grey[600],
                    ),
                  ),
                  const SizedBox(height: 8),
                  Text(
                    'Start a conversation with your contacts',
                    style: TextStyle(
                      color: Colors.grey[500],
                    ),
                  ),
                ],
              ),
            );
          }

          return ListView.builder(
            itemCount: chats.length,
            itemBuilder: (context, index) {
              final chat = chats[index];
              final otherUserId = chat.users.firstWhere(
                (id) => id != currentUserId,
                orElse: () => '',
              );

              return _ChatListTile(
                chat: chat,
                otherUserId: otherUserId,
                currentUserId: currentUserId,
              );
            },
          );
        },
      ),
    );
  }
}

class _ChatListTile extends StatelessWidget {
  final Chat chat;
  final String otherUserId;
  final String currentUserId;

  const _ChatListTile({
    required this.chat,
    required this.otherUserId,
    required this.currentUserId,
  });

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.read<UserViewModel>();

    return StreamBuilder<UserModel?>(
      stream: userViewModel.getUserStream(otherUserId),
      builder: (context, snapshot) {
        final user = snapshot.data;

        if (user == null) {
          return const SizedBox.shrink();
        }

        final isMyMessage = chat.lastSenderId == currentUserId;

        return ListTile(
          leading: Stack(
            children: [
              CircleAvatar(
                radius: 25,
                backgroundColor: Colors.teal[100],
                backgroundImage: user.profileImage.isNotEmpty
                    ? NetworkImage(user.profileImage)
                    : null,
                child: user.profileImage.isEmpty
                    ? Text(
                        user.name.isNotEmpty ? user.name[0].toUpperCase() : '?',
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.bold,
                          color: Colors.teal,
                        ),
                      )
                    : null,
              ),
              if (user.isOnline)
                Positioned(
                  bottom: 0,
                  right: 0,
                  child: Container(
                    width: 14,
                    height: 14,
                    decoration: BoxDecoration(
                      color: Colors.green,
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: Colors.white,
                        width: 2,
                      ),
                    ),
                  ),
                ),
            ],
          ),
          title: Text(
            user.name,
            style: const TextStyle(fontWeight: FontWeight.bold),
          ),
          subtitle: Text(
            isMyMessage ? 'You: ${chat.lastMessage}' : chat.lastMessage,
            maxLines: 1,
            overflow: TextOverflow.ellipsis,
            style: TextStyle(
              color: chat.unreadCount > 0 && !isMyMessage
                  ? Colors.black
                  : Colors.grey[600],
              fontWeight: chat.unreadCount > 0 && !isMyMessage
                  ? FontWeight.bold
                  : FontWeight.normal,
            ),
          ),
          trailing: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            crossAxisAlignment: CrossAxisAlignment.end,
            children: [
              Text(
                timeago.format(chat.timestamp, locale: 'en_short'),
                style: TextStyle(
                  fontSize: 12,
                  color: chat.unreadCount > 0 && !isMyMessage
                      ? Colors.teal
                      : Colors.grey[600],
                ),
              ),
              if (chat.unreadCount > 0 && !isMyMessage) ...[
                const SizedBox(height: 4),
                Container(
                  padding: const EdgeInsets.all(6),
                  decoration: const BoxDecoration(
                    color: Colors.teal,
                    shape: BoxShape.circle,
                  ),
                  child: Text(
                    '${chat.unreadCount}',
                    style: const TextStyle(
                      color: Colors.white,
                      fontSize: 10,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
              if (chat.isTyping && !isMyMessage)
                const Text(
                  'typing...',
                  style: TextStyle(
                    fontSize: 12,
                    color: Colors.teal,
                    fontStyle: FontStyle.italic,
                  ),
                ),
            ],
          ),
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  chatId: chat.chatId,
                  receiverUser: user,
                ),
              ),
            );
          },
        );
      },
    );
  }
}
