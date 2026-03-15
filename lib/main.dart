import 'package:ccna_command_hub/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:ccna_command_hub/themes/app_theme.dart';
import 'firebase_options.dart';
import 'package:firebase_core/firebase_core.dart';

// value notifier for Dark Mode
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  // // এটি অবশ্যই সবার আগে দিতে হবে
  WidgetsFlutterBinding.ensureInitialized();
  //
  // // ফায়ারবেস ইনিশিয়ালাইজ করা
  // await Firebase.initializeApp(
  //   options: DefaultFirebaseOptions.currentPlatform,
  // );

  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ValueListenableBuilder<ThemeMode>(
      valueListenable: themeNotifier,
      builder: (_, ThemeMode currentMode, __) {
        return MaterialApp(
          debugShowCheckedModeBanner: false,
          title: 'CCNA Command Hub',


          theme: AppTheme.lightTheme,
          darkTheme: AppTheme.dartTheme,

          themeMode: currentMode,

          home: const SplashScreen(),
        );
      },
    );
  }
}