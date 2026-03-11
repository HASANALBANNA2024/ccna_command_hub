import 'package:ccna_command_hub/screens/details_screen.dart';
import 'package:flutter/material.dart';

class SubModuleScreen extends StatelessWidget {
  final String moduleId;
  final String moduleName;
  final List<dynamic> subModules;

  const SubModuleScreen({
    super.key,
    required this.moduleId,
    required this.moduleName,
    required this.subModules,
  });

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      // ব্যাকগ্রাউন্ড হোম স্ক্রিন থেকে একটু বেশি ডার্ক (Charcoal Black)
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF1F5F9),

      appBar: AppBar(
        title: Text(moduleName, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent, // AppBar ট্রান্সপারেন্ট করে দিলাম
        flexibleSpace: Container(
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [const Color(0xFF1E293B), const Color(0xFF020617)]
                  : [Colors.blueAccent, Colors.blue],
              begin: Alignment.topCenter,
              end: Alignment.bottomCenter,
            ),
          ),
        ),
      ),

      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        itemCount: subModules.length,
        itemBuilder: (context, index) {
          final sub = subModules[index];
          bool isUnlocked = sub['isUnlocked'] ?? false;

          return Container(
            margin: const EdgeInsets.only(bottom: 15),
            decoration: BoxDecoration(
              // কার্ডের বর্ডার ইফেক্ট
              borderRadius: BorderRadius.circular(18),
              gradient: isUnlocked && isDark
                  ? LinearGradient(colors: [Colors.blueAccent.withOpacity(0.1), Colors.transparent])
                  : null,
              border: Border.all(
                color: isUnlocked
                    ? Colors.blueAccent.withOpacity(0.4)
                    : Colors.white.withOpacity(0.05),
                width: 1,
              ),
              color: isDark ? const Color(0xFF0F172A) : Colors.white,
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(18),
              child: ListTile(
                contentPadding: const EdgeInsets.all(15),

                // ১. স্টাইলিশ আইকন বক্স
                leading: Container(
                  height: 50,
                  width: 50,
                  decoration: BoxDecoration(
                    color: isUnlocked
                        ? Colors.blueAccent.withOpacity(0.15)
                        : Colors.blueGrey.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Icon(
                    isUnlocked ? Icons.auto_stories_rounded : Icons.lock_person_rounded,
                    color: isUnlocked ? Colors.blueAccent : Colors.blueGrey.shade700,
                  ),
                ),

                // ২. টেকস্ট সেকশন
                title: Text(
                  sub['title'],
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                    color: isUnlocked
                        ? (isDark ? Colors.white : Colors.black87)
                        : Colors.blueGrey.shade600,
                  ),
                ),
                subtitle: Padding(
                  padding: const EdgeInsets.only(top: 5),
                  child: Text(
                    sub['desc'] ?? "",
                    style: TextStyle(
                      fontSize: 12,
                      color: isDark ? Colors.blueGrey.shade400 : Colors.grey.shade600,
                    ),
                  ),
                ),

                // ৩. আনলক প্রোগ্রেস ইন্ডিকেটর (অপশনাল ডিজাইন)
                trailing: isUnlocked
                    ? const Icon(Icons.arrow_circle_right_rounded, color: Colors.blueAccent, size: 28)
                    : Icon(Icons.lock_clock_outlined, color: Colors.blueGrey.shade800, size: 20),

                // onTap: () {
                //   if (isUnlocked) {
                //     debugPrint("Level Entry: ${sub['title']}");
                //     // Navigator.push... ৩য় স্ক্রিনের জন্য
                //   } else {
                //     _showLockedDialog(context, sub['title']);
                //   }
                // },

                // call to details screen
                onTap: (){
                  if(isUnlocked)
                    {
                      Navigator.push(context,
                          MaterialPageRoute(
                              builder: (context) => DetailsScreen(
                                  moduleId: sub['id'].toString().substring(0,2),
                                  subId: sub['id'],
                                  title: sub['title']
                              )
                          ));
                    }
                  else
                    {
                      _showLockedDialog(context, sub['title']);
                    }
                },
              ),
            ),
          );
        },
      ),
    );
  }

  void _showLockedDialog(BuildContext context, String title) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Icon(Icons.lock_outline, color: Colors.orangeAccent, size: 50),
        content: Text(
          "ওহ! '$title' এখনো লক করা। এটি আনলক করতে আগের কুইজটি সফলভাবে শেষ করো।",
          textAlign: TextAlign.center,
          style: const TextStyle(color: Colors.white),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("বুঝেছি", style: TextStyle(color: Colors.blueAccent)),
          )
        ],
      ),
    );
  }
}