import 'package:flutter/material.dart';
import '../constants/constants.dart';
import '../services/user_service.dart';
import 'home_screen.dart';
import 'signin_screen.dart';

// Enhancement 1: Persistent authentication checks SharedPreferences before choosing Home or Sign In.
class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});
  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _continue();
  }

  Future<void> _continue() async {
    await Future<void>.delayed(const Duration(milliseconds: 700));
    final bool loggedIn = await UserService().isLoggedIn();
    if (!mounted) return;
    Navigator.of(context).pushReplacement(
      MaterialPageRoute<void>(
        builder: (_) => loggedIn ? const HomeScreen() : const SignInScreen(),
      ),
    );
  }

  @override
  Widget build(BuildContext context) => Scaffold(
    body: Center(
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: <Widget>[
          const Icon(Icons.storefront, size: 70, color: kPrimaryColor),
          const SizedBox(height: 14),
          const Text(
            kAppTitle,
            style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 20),
          const CircularProgressIndicator(),
        ],
      ),
    ),
  );
}
