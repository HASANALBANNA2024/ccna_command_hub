import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ccna_command_hub/screens/home_screen.dart';
import 'package:ccna_command_hub/screens/bookmark_screen.dart';
import 'package:ccna_command_hub/widgets/search_Delegate.dart';
import 'package:ccna_command_hub/models/module_model.dart';
import 'package:ccna_command_hub/services/bookmark_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ccna_command_hub/services/unlock_service.dart';

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ModuleModel> allModulesList = [];
  List<ModuleModel> myGlobalBookmarkList = [];
  bool isLoading = true;

  // update bookmark count
  int bookmarkCount = 0;

  // overall progress bar
  int totalModules = 32;
  int passedModulesCount = 0;
  double progressPercentage = 0.0;


  Future<void> updateOverallProgress() async {
    // সার্ভিস থেকে পাস করা মডিউলের সংখ্যা আনা
    int passed = await UnlockService.getPassedQuizCount();

    if (mounted) {
      setState(() {
        passedModulesCount = passed;
        // ক্যালকুলেশন: (পাস করা মডিউল / ৩২) * ১০০
        progressPercentage = (passedModulesCount / totalModules) * 100;
      });
    }
  }

  Future<void> updateBookmarkCount() async {
    final List<Map<String, dynamic>> bookmarks = await BookmarkService.getAllBookmarks();

    // কনসোলে চেক করুন সংখ্যাটি কত দেখাচ্ছে
    debugPrint("Current Bookmarks in DB: ${bookmarks.length}");

    if (mounted) {
      setState(() {
        bookmarkCount = bookmarks.length;
        // যদি মডেল কনভার্ট করতে রেড লাইন দেয়, তবে এই লাইনটি আপাতত কমেন্ট করে রাখুন
        // myGlobalBookmarkList = bookmarks.map((item) => ModuleModel.fromJson(item)).toList();
      });
    }
  }

  @override
  void initState() {
    super.initState();
    loadDashboardData();
    updateBookmarkCount();
    updateOverallProgress();
  }

  Future<void> loadDashboardData() async {
    try {
      final String response = await rootBundle.loadString("assets/data/modules.json");
      final List<dynamic> data = json.decode(response);

      setState(() {
        allModulesList = data.map((m) => ModuleModel.fromJson(m)).toList();
        isLoading = false;
      });
    } catch (e) {
      debugPrint("Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      body: SafeArea(
        child: isLoading
            ? const Center(child: CircularProgressIndicator())
            : SingleChildScrollView(
          padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12), // সামান্য বাড়ানো হয়েছে
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // --- ১. হেডার (Slightly Scaled Up) ---
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        "Hello, Engineer!",
                        style: TextStyle(
                          fontSize: 19, // ১৮ থেকে ১৯ করা হয়েছে
                          fontWeight: FontWeight.bold,
                          color: isDark ? Colors.white : Colors.blueGrey.shade900,
                        ),
                      ),
                      const Text("Track your CCNA journey", style: TextStyle(fontSize: 11.5, color: Colors.grey)),
                    ],
                  ),
                  const CircleAvatar(
                    radius: 19, // ১৮ থেকে ১৯ করা হয়েছে
                    backgroundColor: Colors.blueAccent,
                    child: Icon(Icons.person, color: Colors.white, size: 19),
                  ),
                ],
              ),

              const SizedBox(height: 14),

              // --- ২. ফাংশনাল সার্চ বার ---
              InkWell(
                onTap: () {
                  if (allModulesList.isNotEmpty) {
                    showSearch(
                      context: context,
                      delegate: GlobalSearchDelegate(allModulesList),
                    );
                  } else {
                    ScaffoldMessenger.of(context).showSnackBar(
                      const SnackBar(content: Text("Data is still loading...")),
                    );
                  }
                },
                child: Container(
                  height: 48, // ৪৫ থেকে ৪৮ করা হয়েছে
                  padding: const EdgeInsets.symmetric(horizontal: 14),
                  decoration: BoxDecoration(
                    color: isDark ? const Color(0xFF1E293B) : Colors.white,
                    borderRadius: BorderRadius.circular(11),
                  ),
                  child: Row(
                    children: [
                      const Icon(Icons.search, color: Colors.blueAccent, size: 20), // ১৮ থেকে ২০
                      const SizedBox(width: 10),
                      Text(
                        "Search commands...",
                        style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600), // ১৩ থেকে ১৪
                      ),
                    ],
                  ),
                ),
              ),

              const SizedBox(height: 14),

              // --- Overall progress---
              _buildOverallProgress(progressPercentage, passedModulesCount, isDark),

              const SizedBox(height: 14),

              // --- ৪. স্ট্যাটস কার্ড ---
              Row(
                children: [
                  // ১. মডিউল মেনু কার্ড (বাম পাশে)
                  _buildStatCard("Modules", allModulesList.length.toString(), Colors.blue, isDark),

                  const SizedBox(width: 12),

                  // ২. বুকমার্ক স্ট্যাট কার্ড (ডান পাশে)

                  _buildStatCard("Bookmarks", bookmarkCount.toString(), Colors.orange, isDark),
                 ]
              ),

              const SizedBox(height: 15),

              // --- ৫. লার্নিং হাব ---
              const Text("Learning Hub", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)), // ১৪ থেকে ১৫
              const SizedBox(height: 10),

              GridView.count(
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                crossAxisCount: 2,
                crossAxisSpacing: 12,
                mainAxisSpacing: 12,
                childAspectRatio: 1.5,
                children: [

                  _buildMenuCard(context,"Modules",Icons.menu_book,Colors.indigo,isDark,
                        () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const HomeScreen()),
                      ).then((_) {

                        loadDashboardData();
                        updateBookmarkCount();
                        updateOverallProgress();
                      });
                    },
                  ),

                  // _buildMenuCard(context, "Bookmarks", Icons.bookmark, Colors.amber.shade700, isDark,
                  //         () => Navigator.push(context, MaterialPageRoute(builder: (context) => const BookmarkScreen()))),
                  
                  // _buildMenuCard(context, "Bookmarks", Icons.bookmark, Colors.amber.shade700, isDark, (){
                  //   Navigator.push(context, MaterialPageRoute(builder: (context)=> const BookmarkScreen(bookmarkedItems: [])));
                  // }),

                  _buildMenuCard(context, "Bookmarks", Icons.bookmark, Colors.amber.shade700, isDark, () {
                    Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => BookmarkScreen(bookmarkedItems: myGlobalBookmarkList))
                    ).then((value) {

                      // স্ক্রিন থেকে ফিরে আসার পর UI রিফ্রেশ করার জন্য
                      setState(() {});
                    });
                  }),

                  _buildMenuCard(context, "Cheat Sheet", Icons.terminal, Colors.teal, isDark, () {}),



                  _buildMenuCard(context, "Quiz", Icons.quiz, Colors.purple, isDark, () {


                  }),


                ],
              ),

              const SizedBox(height: 20),

              // --- ৬. রিসেন্ট অ্যাক্টিভিটি ---
              const Text("Continue Learning", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              _buildRecentItem("OSI Model", "Module 1", isDark),
              _buildRecentItem("VLAN Config", "Module 3", isDark),
            ],
          ),
        ),
      ),
    );
  }

  // --- হেল্পার উইজেটস (Size Adjusted) ---
  Widget _buildOverallProgress(double percentage, int passedCount, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12), // ১০ থেকে ১২
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(13),
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 52, // ৫০ থেকে ৫২
                height: 52,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 5.5, // ৫ থেকে ৫.৫
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              ),
              Text("${percentage.toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), // ১২ থেকে ১৩
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Overall Progress", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text("${(percentage/100 * 32).toInt()} / 32 modules completed", style: const TextStyle(fontSize: 11, color: Colors.grey)),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildStatCard(String title, String count, Color color, bool isDark) {
    return Expanded(
      child: Container(
        padding: const EdgeInsets.symmetric(vertical: 12, horizontal: 14),
        decoration: BoxDecoration(
          color: color.withOpacity(0.1),
          borderRadius: BorderRadius.circular(11),
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)), // ১৬ থেকে ১৭
            Text(title, style: const TextStyle(fontSize: 11)), // ১০ থেকে ১১
          ],
        ),
      ),
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(13),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(13),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 24), // ২২ থেকে ২৪
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), // ১২ থেকে ১৩
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItem(String title, String subtitle, bool isDark) {
    return Card(
      margin: const EdgeInsets.only(bottom: 8),
      color: isDark ? const Color(0xFF1E293B) : Colors.white,
      elevation: 0,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(9)),
      child: ListTile(
        dense: true,
        visualDensity: const VisualDensity(vertical: -2), // -৩ থেকে -২ যাতে একটু বড় দেখায়
        leading: const Icon(Icons.history, color: Colors.blueAccent, size: 20), // ১৮ থেকে ২০
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)), // ১২ থেকে ১৩
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)), // ১০ থেকে ১১
        trailing: const Icon(Icons.arrow_forward_ios, size: 11), // ১০ থেকে ১১
      ),
    );
  }
}