import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../services/chat_service.dart';
import '../services/user_service.dart';
import 'chat_detail_screen.dart';

// Lab Activity 6, Enhancement 1 & 2: Lists every registered user except the
// signed-in one, with a search bar to filter by name or email.
class ChatScreen extends StatefulWidget {
  const ChatScreen({super.key});

  @override
  State<ChatScreen> createState() => _ChatScreenState();
}

class _ChatScreenState extends State<ChatScreen> {
  final ChatService _chatService = ChatService();
  final TextEditingController _searchController = TextEditingController();
  String _query = '';

  @override
  void dispose() {
    _searchController.dispose();
    super.dispose();
  }

  String _displayName(Map<String, dynamic> user) {
    final String first = (user['firstName'] ?? '').toString().trim();
    final String last = (user['lastName'] ?? '').toString().trim();
    final String full = '$first $last'.trim();
    if (full.isNotEmpty) return full;
    final String username = (user['username'] ?? '').toString().trim();
    if (username.isNotEmpty) return username;
    return (user['email'] ?? 'Unknown user').toString();
  }

  @override
  Widget build(BuildContext context) {
    final String? currentUid = UserService().currentFirebaseUser?.uid;
    return Scaffold(
      appBar: AppBar(title: const Text('Chats')),
      body: Column(
        children: <Widget>[
          Padding(
            padding: const EdgeInsets.fromLTRB(16, 12, 16, 8),
            child: TextField(
              controller: _searchController,
              onChanged: (String value) =>
                  setState(() => _query = value.trim().toLowerCase()),
              decoration: InputDecoration(
                hintText: 'Search by name or email',
                prefixIcon: const Icon(Icons.search),
                suffixIcon: _query.isEmpty
                    ? null
                    : IconButton(
                        icon: const Icon(Icons.clear),
                        onPressed: () {
                          _searchController.clear();
                          setState(() => _query = '');
                        },
                      ),
                border: OutlineInputBorder(
                  borderRadius: BorderRadius.circular(kBorderRadius),
                ),
              ),
            ),
          ),
          Expanded(
            child: StreamBuilder<List<Map<String, dynamic>>>(
              stream: _chatService.getUsersStream(),
              builder: (
                BuildContext context,
                AsyncSnapshot<List<Map<String, dynamic>>> snapshot,
              ) {
                if (snapshot.hasError)
                  return const Center(child: Text('Could not load users.'));
                if (!snapshot.hasData)
                  return const Center(child: CircularProgressIndicator());

                // Enhancement 1: never show the signed-in user in their own
                // chat list.
                List<Map<String, dynamic>> users = snapshot.data!
                    .where(
                      (Map<String, dynamic> user) => user['uid'] != currentUid,
                    )
                    .toList();

                // Enhancement 2: filter by name or email as the user types.
                if (_query.isNotEmpty) {
                  users = users.where((Map<String, dynamic> user) {
                    final String name = _displayName(user).toLowerCase();
                    final String email = (user['email'] ?? '')
                        .toString()
                        .toLowerCase();
                    return name.contains(_query) || email.contains(_query);
                  }).toList();
                }

                if (users.isEmpty)
                  return Center(
                    child: Text(
                      _query.isEmpty
                          ? 'No other registered users yet.'
                          : 'No users match "$_query".',
                      style: kProductSubtitleStyle,
                    ),
                  );

                return ListView.separated(
                  itemCount: users.length,
                  separatorBuilder: (_, __) => const Divider(height: 1),
                  itemBuilder: (BuildContext context, int index) {
                    final Map<String, dynamic> user = users[index];
                    final String name = _displayName(user);
                    final String email = (user['email'] ?? '').toString();
                    return ListTile(
                      leading: CircleAvatar(
                        backgroundColor: kPrimaryColor,
                        child: Text(
                          name.isNotEmpty ? name[0].toUpperCase() : '?',
                          style: const TextStyle(color: Colors.white),
                        ),
                      ),
                      title: Text(name),
                      subtitle: Text(email),
                      onTap: () => Navigator.of(context).push(
                        MaterialPageRoute<void>(
                          builder: (_) => ChatDetailScreen(
                            otherUserId: (user['uid'] ?? '').toString(),
                            otherUserName: name,
                            otherUserEmail: email,
                          ),
                        ),
                      ),
                    );
                  },
                );
              },
            ),
          ),
        ],
      ),
    );
  }
}
