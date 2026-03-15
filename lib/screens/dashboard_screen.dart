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
import 'package:firebase_auth/firebase_auth.dart';
import 'package:ccna_command_hub/services/cloud_sync_service.dart';

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

  // --- নতুন মেথড: বর্তমান ইউজারের ইউনিক প্রিফিক্স তৈরি করা ---
  String get _userPrefix => FirebaseAuth.instance.currentUser?.uid ?? "guest";

  Future<void> loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        // প্রতিটি Key-এর সাথে ইউজারের UID prefix যোগ করা হয়েছে
        lastReadId = prefs.getString('${_userPrefix}_last_mod_id') ?? "m1";
        lastReadName = prefs.getString('${_userPrefix}_last_mod_name') ?? "Introduction to CCNA";
        lastTopicIndex = prefs.getInt('${_userPrefix}_last_topic_index') ?? -1;

        String? subJson = prefs.getString('${_userPrefix}_last_sub_modules');
        if (subJson != null) {
          lastSubModules = json.decode(subJson);
        } else {
          lastSubModules = []; // নতুন ইউজারের জন্য খালি রাখা
        }
      });
    }
  }

  void navigateToLastRead() async {
    // যদি সাব-মডিউল লিস্ট খালি থাকে তবে ডিফল্ট লোড করা (আপনার আগের লজিক)
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

    // নেভিগেশনে 'initialIndex' যুক্ত করা হয়েছে
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => SubModuleScreen(
          moduleId: lastReadId,
          moduleName: lastReadName,
          subModules: lastSubModules,
          initialIndex: lastTopicIndex, // এটি ইউজারকে সঠিক টপিকে নিয়ে যাবে
        ),
      ),
    ).then((_)
    {
      loadLastRead();
      updateOverallProgress();
    });
  }


  Future<void> updateOverallProgress() async {
    try {
      // ১. বর্তমানে কোন ইউজার লগইন আছে তার UID নেওয়া
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? "guest";

      // ২. UnlockService থেকে পাস করা কুইজের সংখ্যা নিয়ে আসা
      // নিশ্চিত করুন UnlockService.getPassedQuizCount() মেথডটি UID ব্যবহার করে ডাটা আনছে
      int passed = await UnlockService.getPassedQuizCount();

      if (mounted) {
        setState(() {
          passedModulesCount = passed;

          // ৩. প্রগ্রেস ক্যালকুলেশন (পাস করা মডিউল / মোট ৩২টি মডিউল)
          // আমরা double এ কনভার্ট করে নিচ্ছি যাতে নিখুঁত রেজাল্ট আসে
          double calcProgress = (passed.toDouble() / 32);

          // ৪. পারসেন্টেজ বের করা (যেমন: ০.৫ * ১০০ = ৫০%)
          progressPercentage = calcProgress * 100;

          // ৫. যদি আপনার UI-তে Linear/Circular Progress Indicator থাকে,
          // তবে সেটিতে overallProgress = calcProgress (০.০ থেকে ১.০) ব্যবহার করবেন।
        });

        debugPrint("Progress Updated for User: $uid | Passed: $passed | Percentage: ${progressPercentage.toStringAsFixed(2)}%");
      }
    } catch (e) {
      debugPrint("Error updating progress: $e");
    }
  }

  Future<void> updateBookmarkCount() async {
    // BookmarkService অলরেডি UID ভিত্তিক আপডেট করা হয়েছে
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

    // ১. প্রথমে ফোনের লোকাল ডাটা দিয়ে ড্যাশবোর্ড লোড হবে
    loadDashboardData();
    updateBookmarkCount();
    updateOverallProgress();
    loadLastRead();

    // ২. ১ সেকেন্ড পর ব্যাকগ্রাউন্ডে ক্লাউড থেকে লেটেস্ট ডাটা চেক করবে
    Future.delayed(Duration(seconds: 1), () async {
      print("Checking for cloud updates...");

      await CloudSyncService().syncCloudToLocal();

      // ৩. ক্লাউড থেকে নতুন ডাটা আসলে ড্যাশবোর্ডের ক্যালকুলেশনগুলো আবার আপডেট করতে হবে
      if (mounted) {
        setState(() {
          loadDashboardData();
          updateOverallProgress();
          loadLastRead();
        });
        print("Dashboard refreshed with cloud data!");
      }
    });
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
      child:Scaffold(

        drawer: MainDrawer(),
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
                const SizedBox(height: 20,),
                // ডাটাবেস ছাড়া সরাসরি অফলাইন হেডার উইজেট
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
                              "Hello, Network Engineer!", // নির্দিষ্ট নামের বদলে প্রফেশনাল টাইটেল
                              style: TextStyle(
                                fontSize: 19,
                                fontWeight: FontWeight.bold,
                                color: isDark ? Colors.white : Colors.blueGrey.shade900,
                              ),
                            ),
                          ),
                          const Text(
                            "Track your CCNA journey offline", // অফলাইন মেসেজ
                            style: TextStyle(fontSize: 11.5, color: Colors.grey),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 10),
                    // প্রোফাইল আইকন: যা ক্লিক করলে ড্রয়ার ওপেন হবে
                    Builder(
                      builder: (context) => GestureDetector(
                        onTap: () => Scaffold.of(context).openDrawer(), // ওপেন ড্রয়ার
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
                            // ড্রয়ার ওপেন করার জন্য IconButton
                            child: IconButton(
                              onPressed: () {
                                // এই কোডটি বাম পাশের ড্রয়ার ওপেন করবে
                                Scaffold.of(context).openEndDrawer();                              },
                              icon: const Icon(
                                Icons.terminal_rounded, // আপনার পছন্দমতো টার্মিনাল আইকন
                                size: 20,
                                color: Colors.white,
                              ),
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
                    _buildMenuCard(context,"Modules",Icons.menu_book,Colors.indigo,isDark, () {
                      Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen())).then((_) {
                        updateBookmarkCount();
                        updateOverallProgress();
                      });
                    },
                    ),
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
              );
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
      ) ,
    );
  }

  // --- UI Helper মেথডগুলো অপরিবর্তিত রাখা হয়েছে ---
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