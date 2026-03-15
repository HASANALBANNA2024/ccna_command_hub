import 'package:ccna_command_hub/main.dart';
import 'package:flutter/material.dart';

class MainDrawer extends StatefulWidget {
  const MainDrawer({super.key});

  @override
  _MainDrawerState createState() => _MainDrawerState();
}

class _MainDrawerState extends State<MainDrawer> {
  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      // ড্রয়ারের ব্যাকগ্রাউন্ড কালার থিম অনুযায়ী সেট করা
      backgroundColor: isDark ? const Color(0xFF1A1A1A) : Colors.white,
      child: Column(
        children: [
          // প্রফেশনাল গ্রেডিয়েন্ট হেডার
          _buildHeader(isDark),

          Expanded(
            child: ListView(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              children: [
                _sectionTitle("General"),
                _buildDrawerItem(
                  icon: Icons.info_outline_rounded,
                  title: "About App",
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    showAboutDialog(
                      context: context,
                      applicationName: "CCNA Command Hub",
                      applicationVersion: "1.0.0",
                      applicationIcon: const Icon(Icons.terminal_rounded, color: Colors.blueAccent),
                      children: [
                        const Text("Comprehensive offline guide for CCNA commands."),
                      ],
                    );
                  },
                ),
                _buildDrawerItem(
                  icon: Icons.share_rounded,
                  title: "Share with Friends",
                  isDark: isDark,
                  onTap: () {
                    Navigator.pop(context);
                    // Share logic here
                  },
                ),

                const Padding(
                  padding: EdgeInsets.symmetric(vertical: 8.0),
                  child: Divider(thickness: 0.8),
                ),

                _sectionTitle("Preferences"),
                // থিম সুইচ লিস্ট টাইলকে একটু কাস্টম লুক দেওয়া
                Container(
                  decoration: BoxDecoration(
                    borderRadius: BorderRadius.circular(12),
                    color: isDark ? Colors.white10 : Colors.blue.withOpacity(0.05),
                  ),
                  child: ValueListenableBuilder<ThemeMode>(
                    valueListenable: themeNotifier,
                    builder: (context, mode, _) {
                      bool currentIsDark = mode == ThemeMode.dark;
                      return SwitchListTile(
                        activeColor: Colors.amber,
                        secondary: Icon(
                          currentIsDark ? Icons.dark_mode_rounded : Icons.light_mode_rounded,
                          color: currentIsDark ? Colors.amber : Colors.blueAccent,
                        ),
                        title: Text(
                          "Dark Mode",
                          style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.w500,
                            color: isDark ? Colors.white : Colors.black87,
                          ),
                        ),
                        value: currentIsDark,
                        onChanged: (bool value) {
                          themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                        },
                      );
                    },
                  ),
                ),
              ],
            ),
          ),

          // ফুটার সেকশন
          _buildFooter(isDark),
        ],
      ),
    );
  }

  // কাস্টম হেডার উইজেট
  Widget _buildHeader(bool isDark) {
    return Container(
      width: double.infinity,
      padding: const EdgeInsets.only(top: 60, bottom: 30, left: 20, right: 20),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: isDark
              ? [const Color(0xFF2C3E50), const Color(0xFF000000)]
              : [Colors.blueAccent.shade400, Colors.blue.shade800],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Container(
            padding: const EdgeInsets.all(10), // ইমেজের চারপাশে গ্যাপ রাখার জন্য
            decoration: const BoxDecoration(
              color: Colors.white,
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: Colors.black26,
                  blurRadius: 10,
                  offset: Offset(0, 4),
                )
              ],
            ),
            child: ClipOval(
              child: Image.asset(
                'assets/icon/app_icon.png', // আপনার ইমেজের পাথ
                width: 40,  // আইকনের সাইজ অনুযায়ী ৪০ রাখা হয়েছে
                height: 40,
                fit: BoxFit.contain, // ইমেজটি যেন কন্টেইনারের ভেতরে সুন্দরভাবে বসে
                errorBuilder: (context, error, stackTrace) =>
                const Icon(Icons.terminal_rounded, size: 40, color: Colors.blueAccent),
                // যদি কোনো কারণে ইমেজ লোড না হয় তবে ব্যাকআপ হিসেবে আইকন দেখাবে
              ),
            ),
          ),
          const SizedBox(height: 15),
          const Text(
            "CCNA Command Hub",
            style: TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold),
          ),
          Text(
            "Version 1.0.0 • Offline Guide",
            style: TextStyle(color: Colors.white.withOpacity(0.8), fontSize: 12),
          ),
        ],
      ),
    );
  }

  // সেকশন টাইটেল উইজেট
  Widget _sectionTitle(String title) {
    return Padding(
      padding: const EdgeInsets.only(left: 8, bottom: 8, top: 8),
      child: Text(
        title.toUpperCase(),
        style: const TextStyle(fontSize: 11, fontWeight: FontWeight.bold, color: Colors.grey, letterSpacing: 1.2),
      ),
    );
  }

  // মডার্ন ড্রয়ার আইটেম উইজেট
  Widget _buildDrawerItem({
    required IconData icon,
    required String title,
    required VoidCallback onTap,
    required bool isDark,
  }) {
    return Container(
      margin: const EdgeInsets.symmetric(vertical: 4),
      child: ListTile(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
        // আইটেম ক্লিক করলে স্লাইট ব্যাকগ্রাউন্ড কালার হবে
        tileColor: Colors.transparent,
        leading: Icon(icon, color: Colors.blueAccent, size: 22),
        title: Text(
          title,
          style: TextStyle(
            fontSize: 14,
            fontWeight: FontWeight.w500,
            color: isDark ? Colors.white70 : Colors.black87,
          ),
        ),
        onTap: onTap,
        dense: true,
      ),
    );
  }

  // ফুটার উইজেট
  Widget _buildFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      child: Column(
        children: [
          Divider(color: isDark ? Colors.white10 : Colors.black12),
          const SizedBox(height: 10),
          Text(
            "Developed with ❤️ for Students",
            style: TextStyle(color: Colors.grey.shade500, fontSize: 10),
          ),
        ],
      ),
    );
  }
}