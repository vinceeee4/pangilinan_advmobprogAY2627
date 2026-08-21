import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import '../constants/constants.dart';
import '../providers/theme_provider.dart';
import '../widgets/custom_text.dart';
import '../services/user_service.dart';
import 'signin_screen.dart';

class SettingsScreen extends StatelessWidget {
  const SettingsScreen({super.key});

  @override
  Widget build(BuildContext context) {
    final ThemeProvider themeProvider = Provider.of<ThemeProvider>(context);

    return Scaffold(
      appBar: AppBar(title: const Text('Settings')),
      body: Padding(
        padding: const EdgeInsets.all(kDefaultPadding),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: <Widget>[
            // Enhancement 3: Settings Page
            SwitchListTile(
              title: const CustomText('Dark Theme'),
              value: themeProvider.isDark,
              onChanged: themeProvider.toggleTheme,
            ),
            const SizedBox(height: kDefaultPadding),
            const CustomText('About App', style: kProductTitleStyle),
            const SizedBox(height: 8),
            const CustomText(
              'This app shows products from a sample API with search, details, and theme switching.',
            ),
            const SizedBox(height: kDefaultPadding),
            const CustomText('Version', style: kProductTitleStyle),
            const SizedBox(height: 8),
            const CustomText('1.0.0'),
            const SizedBox(height: kDefaultPadding),
            OutlinedButton.icon(
              icon: const Icon(Icons.logout),
              label: const Text('Log Out'),
              onPressed: () async {
                await UserService().logout();
                if (!context.mounted) return;
                Navigator.of(context).pushAndRemoveUntil(
                  MaterialPageRoute<void>(builder: (_) => const SignInScreen()),
                  (_) => false,
                );
              },
            ),
          ],
        ),
      ),
    );
  }
}
