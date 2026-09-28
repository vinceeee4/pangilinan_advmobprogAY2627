import 'package:flutter/material.dart';

import '../constants/constants.dart';
import 'cart_screen.dart';
import 'chat_screen.dart';
import 'product_screen.dart';
import 'profile_screen.dart';
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
              errorBuilder:
                  (
                    BuildContext context,
                    Object error,
                    StackTrace? stackTrace,
                  ) => const Icon(Icons.storefront, size: 28),
            ),
            const SizedBox(width: 8),
            const Text(kAppTitle),
          ],
        ),
        actions: <Widget>[
          IconButton(
            icon: const Icon(Icons.shopping_cart),
            tooltip: 'My cart',
            onPressed: () => Navigator.of(
              context,
            ).push(MaterialPageRoute<void>(builder: (_) => const CartScreen())),
          ),
          IconButton(
            icon: const Icon(Icons.person),
            tooltip: 'Profile',
            onPressed: () => Navigator.of(context).push(
              MaterialPageRoute<void>(builder: (_) => const ProfileScreen()),
            ),
          ),
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
      // Lab Activity 6, Enhancement 1 & 2: FAB now opens the real chat list
      // (all registered users, minus the signed-in one, searchable by name
      // or email) instead of the old placeholder dialog.
      floatingActionButton: FloatingActionButton(
        tooltip: 'Chat',
        child: const Icon(Icons.chat),
        onPressed: () => Navigator.of(
          context,
        ).push(MaterialPageRoute<void>(builder: (_) => const ChatScreen())),
      ),
    );
  }
}
