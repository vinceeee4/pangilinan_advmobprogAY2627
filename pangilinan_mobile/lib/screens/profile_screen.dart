import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../models/user.dart';
import '../services/user_service.dart';
import 'signin_screen.dart';
import '../widgets/custom_text.dart';

// Enhancement 3: Displays the saved User model and lets the user end the saved session.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<User?> _user;
  @override
  void initState() {
    super.initState();
    _user = UserService().getUser();
  }

  Future<void> _logout() async {
    await UserService().logout();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
      (_) => false,
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: FutureBuilder<User?>(
      future: _user,
      builder: (_, AsyncSnapshot<User?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        final User? user = snapshot.data;
        if (user == null)
          return const Center(
            child: CustomText('No saved user profile found.'),
          );
        return ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            Center(
              child: CircleAvatar(
                radius: 52,
                backgroundImage: user.image.isEmpty
                    ? null
                    : NetworkImage(user.image),
                child: user.image.isEmpty
                    ? const Icon(Icons.person, size: 52)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              user.username,
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 22),
            ),
            const SizedBox(height: 24),
            _field('Name', '${user.firstName} ${user.lastName}'),
            _field('Email', user.email),
            _field('Gender', user.gender),
            _field('User ID', '${user.id}'),
            const SizedBox(height: 26),
            OutlinedButton.icon(
              onPressed: _logout,
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
            ),
          ],
        );
      },
    ),
  );
  Widget _field(String label, String value) => Card(
    child: ListTile(title: Text(label), subtitle: Text(value)),
  );
}
