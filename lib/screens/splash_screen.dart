import 'dart:async';
import 'package:ccna_command_hub/screens/dashboard_screen.dart';
import 'package:ccna_command_hub/screens/home_screen.dart';
import 'package:ccna_command_hub/screens/login_screen.dart';
import 'package:flutter/material.dart';
import 'package:ccna_command_hub/themes/app_theme.dart';

class SplashScreen extends StatefulWidget
{
  const SplashScreen({super.key});

  @override
  _SplashScreenState createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
{

  @override
  void initState(){
    super.initState();

    // after 3 second navigate to homescreen
    Timer(const Duration(seconds: 3), () {
      // navigation to home screen

      Navigator.pushReplacement(context, MaterialPageRoute(
        builder: (context) => DashboardScreen()
      ));

      debugPrint("Navigating to Home...");
    });

  }
  @override
  Widget build(BuildContext context) {
    // dark mode check 
    bool isDarkMode = Theme.of(context).brightness == Brightness.dark;
    return Scaffold(
      backgroundColor: isDarkMode ? const Color(0xFF121212) : AppTheme.primaryBlue,

      body: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            // app logo
            Container(
              padding: const EdgeInsets.all(20),
              decoration: BoxDecoration(
                color: Colors.white.withOpacity(0.1),
                shape: BoxShape.circle
              ),

              // child: const Icon(
              //   Icons.terminal_rounded,
              //   size: 80,
              //   color: Colors.white,
              // ),
              child: Image.asset(
                'assets/images/app_icon.png', // আপনার আইকন ফাইলের পাথ
                width: 80,                  // আইকনের সাইজ অনুযায়ী এডজাস্ট করুন
                height: 80,
                fit: BoxFit.contain,
              ),
            ),
            const SizedBox(height: 20,),
            const Text(
              "CCNA Command Hub",
              style: TextStyle(
                color: Colors.white,
                fontSize: 28,
                fontWeight: FontWeight.bold,
                letterSpacing: 1.2,
              ),
            ),
            const SizedBox(height: 10,),
            const Text(
              "Master The Network Configuration",
              style: TextStyle(
                color: Colors.white70,
                fontSize: 14,
                fontStyle: FontStyle.italic,
              ),
            ),


            const SizedBox(height: 50,),

            const CircularProgressIndicator(
              valueColor: AlwaysStoppedAnimation<Color>(Colors.white),
            )

          ],
        ),
      ),
      
      
      
    );
  }
}