import 'dart:convert';
import 'package:ccna_command_hub/main.dart';
import 'package:ccna_command_hub/screens/login_screen.dart';
import 'package:ccna_command_hub/screens/profile_setup_screen.dart';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:ccna_command_hub/services/database_service.dart';
import 'package:ccna_command_hub/services/auth_service.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    // Current Theme check
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Column(
        children: [
          // Database থেকে রিয়েল-টাইম ডাটা আনার জন্য StreamBuilder
          StreamBuilder<DocumentSnapshot>(
            stream: DatabaseService().getPersonalData,
            builder: (context, snapshot) {
              String name = "Guest User";
              String email = "Not logged in";
              String? imageBase64;

              if (snapshot.hasData && snapshot.data!.exists) {
                var userData = snapshot.data!.data() as Map<String, dynamic>;
                name = userData['name'] ?? "No Name";
                email = userData['email'] ?? "No Email";
                imageBase64 = userData['image'];
              }

              return UserAccountsDrawerHeader(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: isDark
                        ? [Colors.blueGrey.shade900, Colors.black87]
                        : [Colors.blueAccent, Colors.blue.shade800],
                    begin: Alignment.topLeft,
                    end: Alignment.bottomRight,
                  ),
                ),
                currentAccountPicture: Container(
                  decoration: BoxDecoration(
                    shape: BoxShape.circle,
                    border: Border.all(color: Colors.white, width: 2),
                  ),
                  child: CircleAvatar(
                    backgroundColor: isDark ? Colors.grey[800] : Colors.white,
                    backgroundImage: (imageBase64 != null && imageBase64.isNotEmpty)
                        ? MemoryImage(base64Decode(imageBase64.split(',').last))
                        : null,
                    child: (imageBase64 == null || imageBase64.isEmpty)
                        ? Icon(Icons.person, size: 40, color: Colors.blueAccent)
                        : null,
                  ),
                ),
                accountName: Text(
                  name,
                  style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
                ),
                accountEmail: Text(
                  email,
                  style: TextStyle(color: isDark ? Colors.white70 : Colors.white.withOpacity(0.85)),
                ),
              );
            },
          ),

          // Drawer items
          _buildDrawerItem(
            icon: Icons.person_outline,
            title: "Profile Settings",
            onTap: () {
              Navigator.pop(context);
              Navigator.push(context, MaterialPageRoute(builder: (context) => ProfileSetupScreen()));
            },
          ),

          _buildDrawerItem(
            icon: Icons.settings_outlined,
            title: "Settings",
            onTap: () {
              Navigator.pop(context);
            },
          ),

          const Divider(),

          // Theme Switcher
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              bool currentIsDark = mode == ThemeMode.dark;
              return SwitchListTile(
                secondary: Icon(currentIsDark ? Icons.dark_mode : Icons.light_mode,
                    color: currentIsDark ? Colors.amber : Colors.blueAccent),
                title: const Text("Dark Mode"),
                value: currentIsDark,
                onChanged: (bool value) {
                  themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                },
              );
            },
          ),

          const Spacer(),

          // Logout Button
          _buildDrawerItem(
            icon: Icons.logout,
            title: "Logout",
            color: Colors.redAccent,
            onTap: () async {
              // ১. একটি কনফার্মেশন ডায়ালগ দেখানো ভালো (অপশনাল কিন্তু প্রফেশনাল)
              showDialog(
                context: context,
                builder: (context) => AlertDialog(
                  title: const Text("Logout"),
                  content: const Text("Are you sure you want to logout?"),
                  actions: [
                    TextButton(
                      onPressed: () => Navigator.pop(context), // ক্যানসেল
                      child: const Text("No"),
                    ),
                    TextButton(
                      onPressed: () async {
                        // ২. ফায়ারবেস থেকে সাইন আউট
                        await AuthService().signOut();

                        if (!context.mounted) return;

                        // ৩. সব স্ক্রিন রিমুভ করে লগইন স্ক্রিনে পাঠিয়ে দেওয়া
                        Navigator.pushAndRemoveUntil(
                          context,
                          MaterialPageRoute(builder: (context) => LoginScreen()),
                              (route) => false,
                        );
                      },
                      child: const Text("Yes", style: TextStyle(color: Colors.red)),
                    ),
                  ],
                ),
              );
            },
          ),

          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Version 1.0.0", style: TextStyle(color: Colors.grey, fontSize: 12)),
          ),
        ],
      ),
    );
  }

  // ড্রয়ার আইটেমের জন্য একটি ক্লিন উইজেট ফাংশন
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    Color? color,
  }) {
    return ListTile(
      leading: Icon(icon, color: color ?? Colors.blueAccent),
      title: Text(title, style: TextStyle(color: color, fontWeight: FontWeight.w500)),
      onTap: onTap,
    );
  }
}