import 'package:firebase_core/firebase_core.dart';
import 'package:flutter/material.dart';
import 'package:flutter_screenutil/flutter_screenutil.dart';
import 'package:provider/provider.dart';

import 'constants/constants.dart';
import 'firebase_options.dart';
import 'providers/theme_provider.dart';
import 'screens/splash_screen.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(
    options: DefaultFirebaseOptions.currentPlatform,
  );
  runApp(const App());
}

class App extends StatelessWidget {
  const App({super.key});

  @override
  Widget build(BuildContext context) {
    // Lab Activity 6: flutter_screenutil lets the chat screens' .w/.h/.sp
    // sizing scale correctly across device sizes.
    return ScreenUtilInit(
      designSize: const Size(412, 715),
      minTextAdapt: true,
      splitScreenMode: true,
      builder: (BuildContext context, Widget? child) {
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
      },
    );
  }
}
