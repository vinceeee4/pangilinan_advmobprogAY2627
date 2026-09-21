import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/login_type.dart';
import '../models/profile_data.dart';
import '../services/user_service.dart';
import '../widgets/custom_text.dart';
import 'signin_screen.dart';

// Enhancement 3: Fetches user data via UserService().getUserData() and
// shows details/actions that depend on which backend (LoginType)
// authenticated the current session.
class ProfileScreen extends StatefulWidget {
  const ProfileScreen({super.key});
  @override
  State<ProfileScreen> createState() => _ProfileScreenState();
}

class _ProfileScreenState extends State<ProfileScreen> {
  late Future<ProfileData?> _profile;

  @override
  void initState() {
    super.initState();
    _profile = UserService().getUserData();
  }

  void _reload() => setState(() => _profile = UserService().getUserData());

  Future<void> _logout() async {
    await UserService().endSession();
    if (!mounted) return;
    Navigator.of(context).pushAndRemoveUntil(
      MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
      (_) => false,
    );
  }

  Future<void> _updateUsername(String currentUsername) async {
    final TextEditingController controller = TextEditingController(
      text: currentUsername,
    );
    final String? newUsername = await showDialog<String>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Update username'),
        content: TextField(
          controller: controller,
          decoration: const InputDecoration(labelText: 'Username'),
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () =>
                Navigator.of(dialogContext).pop(controller.text.trim()),
            child: const Text('Save'),
          ),
        ],
      ),
    );
    if (newUsername == null || newUsername.isEmpty) return;
    try {
      await UserService().updateUsername(username: newUsername);
      _reload();
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Username updated.')));
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not update username.')),
        );
    }
  }

  Future<void> _changePassword(String email) async {
    final TextEditingController currentController = TextEditingController();
    final TextEditingController newController = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Change password'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            TextField(
              controller: currentController,
              obscureText: true,
              decoration: const InputDecoration(
                labelText: 'Current password',
              ),
            ),
            TextField(
              controller: newController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'New password'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Update'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await UserService().resetPasswordFromCurrentPassword(
        currentPassword: currentController.text,
        newPassword: newController.text,
        email: email,
      );
      if (mounted)
        ScaffoldMessenger.of(
          context,
        ).showSnackBar(const SnackBar(content: Text('Password updated.')));
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text(
              'Could not update password. Check your current password.',
            ),
          ),
        );
    }
  }

  Future<void> _deleteAccount(String email) async {
    final TextEditingController passwordController = TextEditingController();
    final bool? confirmed = await showDialog<bool>(
      context: context,
      builder: (BuildContext dialogContext) => AlertDialog(
        title: const Text('Delete account'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            const Text(
              'This cannot be undone. Enter your password to confirm.',
            ),
            const SizedBox(height: 12),
            TextField(
              controller: passwordController,
              obscureText: true,
              decoration: const InputDecoration(labelText: 'Password'),
            ),
          ],
        ),
        actions: <Widget>[
          TextButton(
            onPressed: () => Navigator.of(dialogContext).pop(false),
            child: const Text('Cancel'),
          ),
          FilledButton(
            style: FilledButton.styleFrom(backgroundColor: Colors.red),
            onPressed: () => Navigator.of(dialogContext).pop(true),
            child: const Text('Delete'),
          ),
        ],
      ),
    );
    if (confirmed != true) return;
    try {
      await UserService().deleteAccount(
        email: email,
        password: passwordController.text,
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
        (_) => false,
      );
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(
            content: Text('Could not delete account. Check your password.'),
          ),
        );
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Profile')),
    body: FutureBuilder<ProfileData?>(
      future: _profile,
      builder: (_, AsyncSnapshot<ProfileData?> snapshot) {
        if (snapshot.connectionState == ConnectionState.waiting)
          return const Center(child: CircularProgressIndicator());
        final ProfileData? profile = snapshot.data;
        if (profile == null)
          return const Center(
            child: CustomText('No saved user profile found.'),
          );
        final bool isFirebase = profile.loginType == LoginType.firebase;
        return ListView(
          padding: const EdgeInsets.all(24),
          children: <Widget>[
            Center(
              child: CircleAvatar(
                radius: 52,
                backgroundImage: profile.photoUrl == null
                    ? null
                    : NetworkImage(profile.photoUrl!),
                child: profile.photoUrl == null
                    ? const Icon(Icons.person, size: 52)
                    : null,
              ),
            ),
            const SizedBox(height: 16),
            Text(
              profile.displayName,
              textAlign: TextAlign.center,
              style: const TextStyle(
                fontWeight: FontWeight.bold,
                fontSize: 22,
              ),
            ),
            Center(
              child: Chip(
                label: Text(
                  isFirebase ? 'Firebase account' : 'DummyJSON account',
                ),
              ),
            ),
            const SizedBox(height: 24),
            _field('Email', profile.email),
            if (profile.firstName != null || profile.lastName != null)
              _field(
                'Name',
                '${profile.firstName ?? ''} ${profile.lastName ?? ''}'
                    .trim(),
              ),
            if (profile.age != null) _field('Age', profile.age!),
            if (profile.contactNo != null)
              _field('Contact number', profile.contactNo!),
            const SizedBox(height: 26),
            if (isFirebase) ...<Widget>[
              OutlinedButton.icon(
                onPressed: () => _updateUsername(profile.displayName),
                icon: const Icon(Icons.edit),
                label: const Text('Update Username'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                onPressed: () => _changePassword(profile.email),
                icon: const Icon(Icons.lock_reset),
                label: const Text('Change Password'),
              ),
              const SizedBox(height: 12),
              OutlinedButton.icon(
                style: OutlinedButton.styleFrom(foregroundColor: Colors.red),
                onPressed: () => _deleteAccount(profile.email),
                icon: const Icon(Icons.delete_forever),
                label: const Text('Delete Account'),
              ),
              const SizedBox(height: 12),
            ],
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
