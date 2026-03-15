import 'dart:convert';
import 'package:ccna_command_hub/screens/flashcard_game_screen.dart';
import 'package:ccna_command_hub/screens/sub_module_screen.dart';
import 'package:ccna_command_hub/widgets/main_drawer.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ccna_command_hub/screens/home_screen.dart';
import 'package:ccna_command_hub/screens/bookmark_screen.dart';
import 'package:ccna_command_hub/widgets/search_Delegate.dart';
import 'package:ccna_command_hub/models/module_model.dart';
import 'package:ccna_command_hub/services/bookmark_service.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ccna_command_hub/services/unlock_service.dart';
// import 'package:firebase_auth/firebase_auth.dart'; // আর দরকার নেই
// import 'package:ccna_command_hub/services/cloud_sync_service.dart'; // আর দরকার নেই

class DashboardScreen extends StatefulWidget {
  const DashboardScreen({super.key});

  @override
  State<DashboardScreen> createState() => _DashboardScreenState();
}

class _DashboardScreenState extends State<DashboardScreen> {
  List<ModuleModel> allModulesList = [];
  List<ModuleModel> myGlobalBookmarkList = [];
  bool isLoading = true;

  int bookmarkCount = 0;
  int totalModules = 32;
  int passedModulesCount = 0;
  double progressPercentage = 0.0;

  String lastReadId = "m1";
  String lastReadName = "Introduction to CCNA";
  int lastTopicIndex = -1;
  List<dynamic> lastSubModules = [];

  // অফলাইন প্রিফিক্স (Firebase এর বদলে ফিক্সড আইডি)
  String get _userPrefix => "guest_user_";

  Future<void> loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        lastReadId = prefs.getString('${_userPrefix}_last_mod_id') ?? "m1";
        lastReadName = prefs.getString('${_userPrefix}_last_mod_name') ?? "Introduction to CCNA";
        lastTopicIndex = prefs.getInt('${_userPrefix}_last_topic_index') ?? -1;

        String? subJson = prefs.getString('${_userPrefix}_last_sub_modules');
        if (subJson != null) {
          lastSubModules = json.decode(subJson);
        } else {
          lastSubModules = [];
        }
      });
    }
  }

  void navigateToLastRead() async {
    if (lastSubModules.isEmpty) {
      try {
        final String response = await rootBundle.loadString('assets/data/modules.json');
        final List<dynamic> data = json.decode(response);
        var firstMod = data.firstWhere((m) => m['id'] == "m1");
        lastSubModules = firstMod['subModules'];
        lastReadName = firstMod['name'];
        lastReadId = "m1";
      } catch (e) {
        debugPrint("Error loading default module: $e");
      }
    }

    if (!mounted) return;

    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubModuleScreen(
          moduleId: lastReadId,
          moduleName: lastReadName,
          subModules: lastSubModules,
          initialIndex: lastTopicIndex,
        ),
      ),
    ).then((_) {
      loadLastRead();
      updateOverallProgress();
    });
  }

  Future<void> updateOverallProgress() async {
    try {
      // অফলাইন সার্ভিস থেকে প্রগ্রেস আনা
      int passed = await UnlockService.getPassedModulesCount();

      if (mounted) {
        setState(() {
          passedModulesCount = passed;
          double calcProgress = (passed.toDouble() / 32);
          progressPercentage = calcProgress * 100;
        });
        debugPrint("Offline Progress Updated | Passed: $passed");
      }
    } catch (e) {
      debugPrint("Error updating overall progress: $e");
    }
  }

  Future<void> updateBookmarkCount() async {
    final List<Map<String, dynamic>> bookmarks = await BookmarkService.getAllBookmarks();
    if (mounted) {
      setState(() {
        bookmarkCount = bookmarks.length;
      });
    }
  }

  @override
  void initState() {
    super.initState();
    // ক্লাউড সিঙ্ক বাদ দিয়ে সরাসরি অফলাইন লোড
    _initializeOfflineDashboard();
  }

  Future<void> _initializeOfflineDashboard() async {
    await loadDashboardData();
    await updateBookmarkCount();
    await updateOverallProgress();
    await loadLastRead();
    print("Offline Dashboard Ready!");
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    updateOverallProgress();
    updateBookmarkCount();
    loadLastRead();
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

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarBrightness: isDark ? Brightness.dark : Brightness.light,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        drawer: const MainDrawer(),
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        endDrawer: const MainDrawer(),
        body: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : SingleChildScrollView(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const SizedBox(height: 20),
                Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          FittedBox(
                            fit: BoxFit.scaleDown,
                            alignment: Alignment.centerLeft,
                            child: Text(
                              "Hello, Network Engineer!",
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.blueGrey.shade900,
                              ),
                            ),
                          ),
                          const Text(
                            "Track your CCNA journey offline",
                            style: TextStyle(fontSize: 11.5, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () => Scaffold.of(context).openEndDrawer(), // ডান পাশের ড্রয়ার
                        child: Container(
                          decoration: BoxDecoration(
                            shape: BoxShape.circle,
                            border: Border.all(
                              color: Colors.blueAccent.withOpacity(0.5),
                              width: 1.5,
                            ),
                          ),
                          child: CircleAvatar(
                            radius: 20,
                            backgroundColor: Colors.blueAccent,
                            child: const Icon(
                              Icons.terminal_rounded,
                              size: 20,
                              color: Colors.white,
                            ),
                          ),
                        ),
                      ),
                    )
                  ],
                ),
                const SizedBox(height: 15),
                InkWell(
                  onTap: () {
                    if (allModulesList.isNotEmpty) {
                      showSearch(
                        context: context,
                        delegate: GlobalSearchDelegate(allModulesList),
                      );
                    }
                  },
                  child: Container(
                    height: 50,
                    padding: const EdgeInsets.symmetric(horizontal: 14),
                    decoration: BoxDecoration(
                      color: isDark ? const Color(0xFF1E293B) : Colors.white,
                      borderRadius: BorderRadius.circular(11),
                    ),
                    child: Row(
                      children: [
                        const Icon(Icons.search, color: Colors.blueAccent, size: 20),
                        const SizedBox(width: 10),
                        Text(
                          "Search commands...",
                          style: TextStyle(fontSize: 14, color: isDark ? Colors.grey.shade400 : Colors.grey.shade600),
                        ),
                      ],
                    ),
                  ),
                ),
                const SizedBox(height: 20),
                _buildOverallProgress(progressPercentage, passedModulesCount, isDark),
                const SizedBox(height: 20),
                Row(
                    children: [
                      _buildStatCard("Modules", allModulesList.length.toString(), Colors.blue, isDark),
                      const SizedBox(width: 12),
                      _buildStatCard("Bookmarks", bookmarkCount.toString(), Colors.orange, isDark),
                    ]
                ),
                const SizedBox(height: 20),
                const Text("Learning Hub", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 15),
                GridView.count(
                  shrinkWrap: true,
                  physics: const NeverScrollableScrollPhysics(),
                  crossAxisCount: 2,
                  crossAxisSpacing: 12,
                  mainAxisSpacing: 12,
                  childAspectRatio: 1.5,
                  children: [
                    _buildMenuCard(context, "Modules", Icons.menu_book, Colors.indigo, isDark, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen())).then((_) {
                        updateBookmarkCount();
                        updateOverallProgress();
                      });
                    }),
                    _buildMenuCard(context, "Bookmarks", Icons.bookmark, Colors.amber.shade700, isDark, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => BookmarkScreen(bookmarkedItems: myGlobalBookmarkList))).then((value) {
                        updateBookmarkCount();
                        updateOverallProgress();
                      });
                    }),
                    _buildMenuCard(context, "Cheat Sheet", Icons.terminal, Colors.teal, isDark, () {}),
                    _buildMenuCard(context, "Flashcard Game", Icons.bolt, Colors.orange, isDark, () {
                      Navigator.push(
                        context,
                        MaterialPageRoute(builder: (context) => const FlashcardGameScreen()),
                      ).then((_) {
                        updateOverallProgress();
                      });
                    }),
                  ],
                ),
                const SizedBox(height: 20),
                const Text("Continue Learning", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 10),
                GestureDetector(
                  onTap: navigateToLastRead,
                  child: _buildRecentItem(
                    lastReadName,
                    "Module ${lastReadId.replaceAll('m', '').padLeft(2, '0')}",
                    isDark,
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  // UI Helpers (অপরিবর্তিত)
  Widget _buildOverallProgress(double percentage, int passedCount, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
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
                width: 52,
                height: 52,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 5.5,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              ),
              Text("${percentage.toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Overall Progress", style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold)),
                Text("$passedCount / 32 modules completed", style: const TextStyle(fontSize: 11, color: Colors.grey)),
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
            Text(count, style: TextStyle(fontSize: 17, fontWeight: FontWeight.bold, color: color)),
            Text(title, style: const TextStyle(fontSize: 11)),
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
            Icon(icon, color: color, size: 24),
            const SizedBox(height: 6),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
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
        visualDensity: const VisualDensity(vertical: -2),
        leading: const Icon(Icons.history, color: Colors.blueAccent, size: 20),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
        subtitle: Text(subtitle, style: const TextStyle(fontSize: 11)),
        trailing: const Icon(Icons.arrow_forward_ios, size: 11),
      ),
    );
  }
}