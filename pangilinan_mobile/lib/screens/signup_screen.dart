import 'package:firebase_auth/firebase_auth.dart' as firebase_auth;
import 'package:flutter/material.dart';

import '../constants/constants.dart';
import '../models/firebase_profile.dart';
import '../services/user_service.dart';
import 'home_screen.dart';

// Enhancement 2: Sign-up UI collects the same fields DummyJSON's /users
// endpoint exposes (see dummyjson.com/users) but creates the account
// through the Firebase Auth SDK instead of a REST call.
class SignUpScreen extends StatefulWidget {
  const SignUpScreen({super.key});
  @override
  State<SignUpScreen> createState() => _SignUpScreenState();
}

class _SignUpScreenState extends State<SignUpScreen> {
  final GlobalKey<FormState> _formKey = GlobalKey<FormState>();
  final TextEditingController _fName = TextEditingController();
  final TextEditingController _lName = TextEditingController();
  final TextEditingController _age = TextEditingController();
  final TextEditingController _contactNo = TextEditingController();
  final TextEditingController _username = TextEditingController();
  final TextEditingController _email = TextEditingController();
  final TextEditingController _password = TextEditingController();
  final TextEditingController _confirmPassword = TextEditingController();
  bool _loading = false;
  bool _obscurePassword = true;

  @override
  void dispose() {
    _fName.dispose();
    _lName.dispose();
    _age.dispose();
    _contactNo.dispose();
    _username.dispose();
    _email.dispose();
    _password.dispose();
    _confirmPassword.dispose();
    super.dispose();
  }

  Future<void> _signUp() async {
    if (!(_formKey.currentState?.validate() ?? false)) return;
    setState(() => _loading = true);
    try {
      final firebase_auth.UserCredential credential = await UserService()
          .createAccount(
            email: _email.text.trim(),
            password: _password.text,
          );
      final String uid = credential.user!.uid;
      await UserService().updateUsername(username: _username.text.trim());
      await UserService().saveFirebaseProfile(
        FirebaseProfile(
          uid: uid,
          fName: _fName.text.trim(),
          lName: _lName.text.trim(),
          age: _age.text.trim(),
          contactNo: _contactNo.text.trim(),
          username: _username.text.trim(),
          email: _email.text.trim(),
        ),
      );
      // Lab Activity 6: mirror the new account into Firestore's 'Users'
      // collection so it immediately shows up in everyone else's chat list.
      await UserService().upsertFirestoreUser(
        uid: uid,
        email: _email.text.trim(),
        firstName: _fName.text.trim(),
        lastName: _lName.text.trim(),
        username: _username.text.trim(),
      );
      if (!mounted) return;
      Navigator.of(context).pushAndRemoveUntil(
        MaterialPageRoute<void>(builder: (_) => const HomeScreen()),
        (_) => false,
      );
    } on firebase_auth.FirebaseAuthException catch (e) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text(e.message ?? 'Could not create account.')),
        );
    } catch (_) {
      if (mounted)
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('Could not create account.')),
        );
    } finally {
      if (mounted) setState(() => _loading = false);
    }
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    appBar: AppBar(title: const Text('Create account')),
    body: SafeArea(
      child: SingleChildScrollView(
        padding: const EdgeInsets.all(24),
        child: Form(
          key: _formKey,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: <Widget>[
              const Text(
                'Sign up with Firebase',
                style: TextStyle(fontSize: 22, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 4),
              const Text(
                'Fields follow the DummyJSON user schema for comparison.',
                style: kProductSubtitleStyle,
              ),
              const SizedBox(height: 24),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _fName,
                      decoration: const InputDecoration(
                        labelText: 'First name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? value) =>
                          value == null || value.trim().isEmpty
                          ? 'Required'
                          : null,
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: TextFormField(
                      controller: _lName,
                      decoration: const InputDecoration(
                        labelText: 'Last name',
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? value) =>
                          value == null || value.trim().isEmpty
                          ? 'Required'
                          : null,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: <Widget>[
                  Expanded(
                    child: TextFormField(
                      controller: _age,
                      keyboardType: TextInputType.number,
                      decoration: const InputDecoration(
                        labelText: 'Age',
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? value) {
                        final int? age = int.tryParse(value?.trim() ?? '');
                        if (age == null || age <= 0 || age > 120)
                          return 'Enter a valid age';
                        return null;
                      },
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    flex: 2,
                    child: TextFormField(
                      controller: _contactNo,
                      keyboardType: TextInputType.phone,
                      decoration: const InputDecoration(
                        labelText: 'Contact number',
                        border: OutlineInputBorder(),
                      ),
                      validator: (String? value) {
                        final String digits =
                            value?.replaceAll(RegExp(r'[^0-9]'), '') ?? '';
                        return digits.length < 7
                            ? 'Enter a valid contact number'
                            : null;
                      },
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _username,
                decoration: const InputDecoration(
                  labelText: 'Username',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) =>
                    value == null || value.trim().length < 3
                    ? 'At least 3 characters'
                    : null,
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _email,
                keyboardType: TextInputType.emailAddress,
                decoration: const InputDecoration(
                  labelText: 'Email address',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) {
                  final String email = value?.trim() ?? '';
                  final RegExp emailPattern = RegExp(
                    r'^[^@\s]+@[^@\s]+\.[^@\s]+$',
                  );
                  return emailPattern.hasMatch(email)
                      ? null
                      : 'Enter a valid email address';
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _password,
                obscureText: _obscurePassword,
                decoration: InputDecoration(
                  labelText: 'Password',
                  border: const OutlineInputBorder(),
                  suffixIcon: IconButton(
                    icon: Icon(
                      _obscurePassword
                          ? Icons.visibility
                          : Icons.visibility_off,
                    ),
                    onPressed: () =>
                        setState(() => _obscurePassword = !_obscurePassword),
                  ),
                ),
                validator: (String? value) {
                  final String password = value ?? '';
                  if (password.length < 8) return 'At least 8 characters';
                  if (!RegExp(r'[A-Za-z]').hasMatch(password) ||
                      !RegExp(r'[0-9]').hasMatch(password))
                    return 'Include a letter and a number';
                  return null;
                },
              ),
              const SizedBox(height: 16),
              TextFormField(
                controller: _confirmPassword,
                obscureText: _obscurePassword,
                decoration: const InputDecoration(
                  labelText: 'Confirm password',
                  border: OutlineInputBorder(),
                ),
                validator: (String? value) => value != _password.text
                    ? 'Passwords do not match'
                    : null,
              ),
              const SizedBox(height: 24),
              ElevatedButton(
                onPressed: _loading ? null : _signUp,
                child: Padding(
                  padding: const EdgeInsets.all(14),
                  child: _loading
                      ? const SizedBox(
                          width: 22,
                          height: 22,
                          child: CircularProgressIndicator(strokeWidth: 2),
                        )
                      : const Text('Create account'),
                ),
              ),
            ],
          ),
        ),
      ),
    ),
  );
}
