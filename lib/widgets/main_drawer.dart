import 'package:ccna_command_hub/main.dart';
import 'package:ccna_command_hub/screens/bookmark_screen.dart';
import 'package:flutter/material.dart';


class MainDrawer extends StatefulWidget
{
  const MainDrawer({super.key});
  @override
  _MainDrawerState createState() => _MainDrawerState();
}


class _MainDrawerState extends State<MainDrawer>
{
  bool _isDark = false;

  @override
  Widget build(BuildContext context) {

    // dark mode check
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Drawer(
      child: Column(
        children: [
          UserAccountsDrawerHeader(
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: isDark
                    ? [Colors.blueGrey.shade900, Colors.black]
                    : [const Color(0xFF6A11CB), const Color(0xFF2575FC)],
              ),
            ),
            currentAccountPicture: CircleAvatar(
              backgroundColor: isDark ? Colors.blueGrey.shade800 : Colors.white,
              child: Icon(Icons.router, color: isDark ? Colors.blue :const Color(0xFF2575FC) , size: 40,),
            ),

            // in future user control for database get information
            accountName: const Text("CCNA Command Hub", style: TextStyle(fontWeight: FontWeight.bold)),
            accountEmail: const Text("Master Networking Step by Step"),
          ),

          ListTile(
            leading: const Icon(Icons.menu_rounded),
            title: const Text("Home"),
            onTap: (){
              Navigator.pop(context);
            },
          ),
          ListTile(
            leading: const Icon(Icons.bookmark),
            title: Text("Bookmark"),
            onTap: (){
              Navigator.pop(context);

              Navigator.pushReplacement(context, MaterialPageRoute(builder: (_)=> BookmarkScreen()));
            },
          ),
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text("Settings"),
            onTap: () {},
          ),
          // থিম পরিবর্তন করার সুইচ
          ValueListenableBuilder<ThemeMode>(
            valueListenable: themeNotifier,
            builder: (context, mode, _) {
              bool isDark = mode == ThemeMode.dark;
              return SwitchListTile(
                title: const Text("Dark Mode"),
                secondary: Icon(isDark ? Icons.dark_mode : Icons.light_mode),
                value: isDark,
                onChanged: (bool value) {
                  // এখানে ভ্যালু পরিবর্তন করলেই পুরো অ্যাপের থিম বদলে যাবে
                  themeNotifier.value = value ? ThemeMode.dark : ThemeMode.light;
                },
              );
            },
          ),
          const Spacer(),
          const Padding(
            padding: EdgeInsets.all(16.0),
            child: Text("Version 1.0.0", style: TextStyle(color: Colors.grey)),
          ),
        ],
      ),
    );
    
  }
}