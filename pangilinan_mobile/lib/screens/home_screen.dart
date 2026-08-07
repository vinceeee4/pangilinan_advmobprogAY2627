import 'package:flutter/material.dart';

import '../constants/constants.dart';
import 'product_screen.dart';
import 'settings_screen.dart';

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Row(
          mainAxisSize: MainAxisSize.min,
          children: <Widget>[
            Image.asset(
              'assets/nubdexchange_logo.png',
              height: 32,
              errorBuilder: (BuildContext context, Object error, StackTrace? stackTrace) => const Icon(Icons.storefront, size: 28),
            ),
            const SizedBox(width: 8),
            const Text(kAppTitle),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.settings),
            onPressed: () {
              Navigator.of(context).push(
                MaterialPageRoute<void>(
                  builder: (BuildContext context) => const SettingsScreen(),
                ),
              );
            },
          ),
        ],
      ),
      body: const ProductScreen(),
    );
  }
}
