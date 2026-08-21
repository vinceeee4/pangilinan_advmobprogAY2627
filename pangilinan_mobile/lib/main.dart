import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'constants/constants.dart';
import 'providers/theme_provider.dart';
import 'screens/home_screen.dart';
import 'screens/splash_screen.dart';

void main() {
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider<ThemeProvider>(
      create: (_) => ThemeProvider(),
      child: Consumer<ThemeProvider>(
        builder: (BuildContext context, ThemeProvider provider, Widget? child) {
          return MaterialApp(
            title: kAppTitle,
            themeMode: provider.themeMode,
            theme: ThemeData(
              brightness: Brightness.light,
              primaryColor: kPrimaryColor,
              scaffoldBackgroundColor: kLightBackground,
              appBarTheme: const AppBarTheme(backgroundColor: kPrimaryColor),
            ),
            darkTheme: ThemeData(
              brightness: Brightness.dark,
              scaffoldBackgroundColor: kDarkBackground,
              appBarTheme: const AppBarTheme(backgroundColor: Colors.black87),
            ),
            home: const SplashScreen(),
          );
        },
      ),
    );
  }
}
