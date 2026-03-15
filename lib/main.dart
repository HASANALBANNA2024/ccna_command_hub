import 'package:ccna_command_hub/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:ccna_command_hub/themes/app_theme.dart';

// value notifier for Dark Mode
final ValueNotifier<ThemeMode> themeNotifier = ValueNotifier(ThemeMode.light);

void main() {
  // ১. ফ্লাটার বাইন্ডিং নিশ্চিত করা
  WidgetsFlutterBinding.ensureInitialized();

  // অফলাইন মোডে Firebase.initializeApp() এর আর প্রয়োজন নেই।
  // সরাসরি অ্যাপ রান করা হচ্ছে।

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