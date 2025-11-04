import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import '../viewmodels/auth_viewmodel.dart';
import '../viewmodels/user_viewmodel.dart';
import '../models/user_model.dart';

class SearchUsersScreen extends StatefulWidget {
  const SearchUsersScreen({super.key});

  @override
  State<SearchUsersScreen> createState() => _SearchUsersScreenState();
}

class _SearchUsersScreenState extends State<SearchUsersScreen> {
  final _searchController = TextEditingController();

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  Future<void> _searchUsers(String query) async {
    if (query.trim().isEmpty) {
      context.read<UserViewModel>().clearSearchResults();
      return;
    }
    await context.read<UserViewModel>().searchUsers(query.trim());
  }

  @override
  Widget build(BuildContext context) {
    final userViewModel = context.watch<UserViewModel>();
    final authViewModel = context.read<AuthViewModel>();

    return Scaffold(
      appBar: AppBar(
        title: const Text('Add Contact'),
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      body: Column(
        children: [
          // Search Bar
          Padding(
            padding: const EdgeInsets.all(16.0),
            child: TextField(
              controller: _searchController,
              decoration: InputDecoration(
                hintText: 'Search by email',
                prefixIcon: const Icon(Icons.search),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(30),
                ),
                filled: true,
                fillColor: Colors.grey[100],
              ),
              onChanged: _searchUsers,
            ),
          ),

          // Search Results
          Expanded(
            child: userViewModel.isLoading
                ? const Center(child: CircularProgressIndicator())
                : userViewModel.searchResults.isEmpty
                    ? Center(
                        child: Column(
                          mainAxisAlignment: MainAxisAlignment.center,
                          children: [
                            Icon(
                              Icons.person_search,
                              size: 80,
                              color: Colors.grey[400],
                            ),
                            const SizedBox(height: 16),
                            Text(
                              _searchController.text.isEmpty
                                  ? 'Search for users'
                                  : 'No users found',
                              style: TextStyle(
                                fontSize: 18,
                                color: Colors.grey[600],
                              ),
                            ),
                          ],
                        ),
                      )
                    : ListView.builder(
                        itemCount: userViewModel.searchResults.length,
                        itemBuilder: (context, index) {
                          final user = userViewModel.searchResults[index];
                          
                          // Don't show current user in search results
                          if (user.uid == authViewModel.currentUser?.uid) {
                            return const SizedBox.shrink();
                          }

                          return _UserSearchTile(user: user);
                        },
                      ),
          ),
        ],
      ),
    );
  }
}

class _UserSearchTile extends StatelessWidget {
  final UserModel user;

  const _UserSearchTile({required this.user});

  Future<void> _addContact(BuildContext context) async {
    final authViewModel = context.read<AuthViewModel>();
    final userViewModel = context.read<UserViewModel>();

    if (authViewModel.currentUser != null) {
      final success = await userViewModel.addContact(
        authViewModel.currentUser!.uid,
        user.uid,
      );

      if (context.mounted) {
        if (success) {
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(
              content: Text('${user.name} added to contacts'),
              backgroundColor: Colors.green,
            ),
          );
          Navigator.of(context).pop();
        } else {
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(
              content: Text('Failed to add contact'),
            ),
          );
        }
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return ListTile(
      leading: CircleAvatar(
        radius: 25,
        backgroundColor: Colors.teal[100],
        backgroundImage:
            user.profileImage.isNotEmpty ? NetworkImage(user.profileImage) : null,
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
      title: Text(
        user.name,
        style: const TextStyle(fontWeight: FontWeight.bold),
      ),
      subtitle: Text(
        user.email,
        style: TextStyle(color: Colors.grey[600]),
      ),
      trailing: ElevatedButton(
        onPressed: () => _addContact(context),
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.teal,
          foregroundColor: Colors.white,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
        ),
        child: const Text('Add'),
      ),
    );
  }
}
