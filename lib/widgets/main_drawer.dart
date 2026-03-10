import 'package:flutter/material.dart';

class MainDrawer extends StatelessWidget
{
  const MainDrawer({super.key});
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
          const Divider(),
          ListTile(
            leading: const Icon(Icons.settings_outlined),
            title: const Text("Settings"),
            onTap: () {},
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