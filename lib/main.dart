import 'package:ccna_command_hub/screens/splash_screen.dart';
import 'package:flutter/material.dart';
import 'package:ccna_command_hub/themes/app_theme.dart';

void main()
{
  runApp(const MyApp());
}

class MyApp extends StatelessWidget
{
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
   return MaterialApp(
     debugShowCheckedModeBanner: false,
     title: 'CCNA Command Hub',
     // Theme Connect
     theme: AppTheme.lightTheme,
     darkTheme: AppTheme.dartTheme,
     themeMode: ThemeMode.system,

     // call to splash screen
     home:  const SplashScreen(),

   );
  }
}