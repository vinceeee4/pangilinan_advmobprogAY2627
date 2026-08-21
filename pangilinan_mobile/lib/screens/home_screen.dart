import 'package:flutter/material.dart';

import '../constants/constants.dart';
import 'product_screen.dart';
import 'settings_screen.dart';
import 'cart_screen.dart';
import 'profile_screen.dart';

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
      // Enhancement 2: Chat is a FAB and is not present on CartScreen's scaffold.
      floatingActionButton: FloatingActionButton(
        tooltip: 'Chat',
        child: const Icon(Icons.chat),
        onPressed: () => showDialog<void>(
          context: context,
          builder: (_) => AlertDialog(
            title: const Text('Chat'),
            content: const Text('Chat support is ready to help.'),
            actions: <Widget>[
              TextButton(
                onPressed: () => Navigator.of(context).pop(),
                child: const Text('Close'),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
