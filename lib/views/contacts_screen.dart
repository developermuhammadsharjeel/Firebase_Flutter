import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../models/user_model.dart';
import 'chat_screen.dart';
import 'search_users_screen.dart';

class ContactsScreen extends StatefulWidget {
  const ContactsScreen({super.key});

  @override
  State<ContactsScreen> createState() => _ContactsScreenState();
}

class _ContactsScreenState extends State<ContactsScreen> {
  @override
  void initState() {
    super.initState();
    _loadContacts();
  }

  Future<void> _loadContacts() async {
    final authViewModel = context.read<AuthViewModel>();
    final userViewModel = context.read<UserViewModel>();
    
    if (authViewModel.currentUser != null) {
      await userViewModel.loadContacts(authViewModel.currentUser!.uid);
    }
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Contacts'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
        actions: [
          IconButton(
            icon: const Icon(Icons.person_add),
            onPressed: () async {
              await Navigator.of(context).push(
                MaterialPageRoute(
                  builder: (_) => const SearchUsersScreen(),
                ),
              );
              // Reload contacts after potentially adding new ones
              _loadContacts();
            },
          ),
        ],
      ),
      body: userViewModel.isLoading
          ? const Center(child: CircularProgressIndicator())
          : userViewModel.contacts.isEmpty
              ? Center(
                  child: Column(
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      Icon(
                        Icons.contacts_outlined,
                        size: 80,
                        color: Colors.grey[400],
                      ),
                      const SizedBox(height: 16),
                      Text(
                        'No contacts yet',
                        style: TextStyle(
                          fontSize: 18,
                          color: Colors.grey[600],
                        ),
                      ),
                      const SizedBox(height: 8),
                      Text(
                        'Add contacts to start chatting',
                        style: TextStyle(
                          color: Colors.grey[500],
                        ),
                      ),
                      const SizedBox(height: 24),
                      ElevatedButton.icon(
                        onPressed: () async {
                          await Navigator.of(context).push(
                            MaterialPageRoute(
                              builder: (_) => const SearchUsersScreen(),
                            ),
                          );
                          _loadContacts();
                        },
                        icon: const Icon(Icons.person_add),
                        label: const Text('Add Contact'),
                        style: ElevatedButton.styleFrom(
                          backgroundColor: Colors.teal,
                          foregroundColor: Colors.white,
                        ),
                      ),
                    ],
                  ),
                )
              : RefreshIndicator(
                  onRefresh: _loadContacts,
                  child: ListView.builder(
                    itemCount: userViewModel.contacts.length,
                    itemBuilder: (context, index) {
                      final contact = userViewModel.contacts[index];
                      return _ContactListTile(contact: contact);
                    },
                  ),
                ),
    );
  }
}

class _ContactListTile extends StatelessWidget {
  final UserModel contact;

  const _ContactListTile({required this.contact});

  @override
  Widget build(BuildContext context) {
    final authViewModel = context.read<AuthViewModel>();
    final chatViewModel = context.read<ChatViewModel>();

    return ListTile(
      leading: Stack(
        children: [
          CircleAvatar(
            radius: 25,
            backgroundColor: Colors.teal[100],
            backgroundImage: contact.profileImage.isNotEmpty
                ? NetworkImage(contact.profileImage)
                : null,
            child: contact.profileImage.isEmpty
                ? Text(
                    contact.name.isNotEmpty
                        ? contact.name[0].toUpperCase()
                        : '?',
                    style: const TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: Colors.teal,
                    ),
                  )
                : null,
          ),
          if (contact.isOnline)
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
        contact.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        contact.status,
        maxLines: 1,
        overflow: TextOverflow.ellipsis,
        style: TextStyle(color: Colors.grey[600]),
      ),
      onTap: () async {
        if (authViewModel.currentUser != null) {
          // Create or get chat
          final chatId = await chatViewModel.createChat(
            authViewModel.currentUser!.uid,
            contact.uid,
          );

          if (chatId != null && context.mounted) {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (_) => ChatScreen(
                  chatId: chatId,
                  receiverUser: contact,
                ),
              ),
            );
          }
        }
      },
    );
  }
}
