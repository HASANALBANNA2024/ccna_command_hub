import 'dart:convert';
import 'package:ccna_command_hub/screens/flashcard_game_screen.dart';
import 'package:ccna_command_hub/screens/sub_module_screen.dart';
import 'package:ccna_command_hub/screens/subnet_calculator_screen.dart';
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

  // ✅ আপডেট: সরাসরি UnlockService থেকে ডাইনামিক প্রিফিক্স নেওয়া হচ্ছে
  String get _userPrefix => UnlockService.userPrefix;

  @override
  void initState() {
    super.initState();
    _initializeDashboard();
  }

  // স্ক্রিনে ফিরে আসলে বা কোনো পরিবর্তন হলে অটো-রিফ্রেশ করার জন্য
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _refreshStats();
  }

  Future<void> _initializeDashboard() async {
    await loadDashboardData(); // JSON থেকে মডিউল লিস্ট লোড
    await _refreshStats();
    debugPrint("Dashboard Initialized for User: $_userPrefix");
  }

  Future<void> _refreshStats() async {
    await updateOverallProgress();
    await updateBookmarkCount();
    await loadLastRead();
  }

  Future<void> loadLastRead() async {
    final prefs = await SharedPreferences.getInstance();
    if (mounted) {
      setState(() {
        // ✅ আপডেট: UnlockService এর কী ফরম্যাট অনুযায়ী আন্ডারস্কোর ফিক্স করা হয়েছে
        lastReadId = prefs.getString('${_userPrefix}last_mod_id') ?? "m1";
        lastReadName = prefs.getString('${_userPrefix}last_mod_name') ?? "Introduction to CCNA";
        lastTopicIndex = prefs.getInt('${_userPrefix}last_topic_index') ?? -1;

        String? subJson = prefs.getString('${_userPrefix}last_sub_modules');
        if (subJson != null) {
          lastSubModules = json.decode(subJson);
        } else {
          lastSubModules = [];
        }
      });
    }
  }

  void navigateToLastRead() async {
    // যদি লাস্ট পড়া মডিউলের ডেটা না থাকে, তবে ডিফল্ট m1 লোড করবে
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
    ).then((_) => _refreshStats()); // ফিরে আসলে রিফ্রেশ হবে
  }

  Future<void> updateOverallProgress() async {
    try {
      int passed = await UnlockService.getPassedModulesCount();
      if (mounted) {
        setState(() {
          passedModulesCount = passed;
          progressPercentage = (passed / 32) * 100;
        });
      }
    } catch (e) {
      debugPrint("Progress Update Error: $e");
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

  Future<void> loadDashboardData() async {
    try {
      final String response = await rootBundle.loadString("assets/data/modules.json");
      final List<dynamic> data = json.decode(response);
      if (mounted) {
        setState(() {
          allModulesList = data.map((m) => ModuleModel.fromJson(m)).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Data Loading Error: $e");
      setState(() => isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return AnnotatedRegion<SystemUiOverlayStyle>(
      value: SystemUiOverlayStyle(
        statusBarIconBrightness: isDark ? Brightness.light : Brightness.dark,
        statusBarColor: Colors.transparent,
      ),
      child: Scaffold(
        drawer: const MainDrawer(),
        endDrawer: const MainDrawer(),
        backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
        body: SafeArea(
          child: isLoading
              ? const Center(child: CircularProgressIndicator())
              : RefreshIndicator(
            onRefresh: _refreshStats,
            child: SingleChildScrollView(
              physics: const AlwaysScrollableScrollPhysics(),
              padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 12),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  const SizedBox(height: 20),
                  _buildHeader(isDark),
                  const SizedBox(height: 15),
                  _buildSearchBar(isDark),
                  const SizedBox(height: 20),
                  _buildOverallProgress(progressPercentage, passedModulesCount, isDark),
                  const SizedBox(height: 20),
                  Row(
                    children: [
                      _buildStatCard("Modules", allModulesList.length.toString(), Colors.blue, isDark),
                      const SizedBox(width: 12),
                      _buildStatCard("Bookmarks", bookmarkCount.toString(), Colors.orange, isDark),
                    ],
                  ),
                  const SizedBox(height: 20),
                  const Text("Learning Hub", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 15),
                  _buildLearningHubGrid(isDark),
                  const SizedBox(height: 25),
                  const Text("Continue Learning", style: TextStyle(fontSize: 16, fontWeight: FontWeight.bold)),
                  const SizedBox(height: 10),
                  GestureDetector(
                    onTap: navigateToLastRead,
                    child: _buildRecentItem(
                      lastReadName,
                      "Module ${lastReadId.replaceAll('m', '').padLeft(2, '0')}",
                      isDark,
                    ),
                  ),
                  const SizedBox(height: 20),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  // --- UI Helper Widgets ---

  Widget _buildHeader(bool isDark) {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        Expanded(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                "Hello, Network Engineer!",
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: isDark ? Colors.white : Colors.blueGrey.shade900,
                ),
              ),
              const Text(
                "Track your CCNA journey offline",
                style: TextStyle(fontSize: 12, color: Colors.grey),
              ),
            ],
          ),
        ),
        Builder(
          builder: (context) => GestureDetector(
            onTap: () => Scaffold.of(context).openEndDrawer(),
            child: Container(
              padding: const EdgeInsets.all(2),
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                border: Border.all(color: Colors.blueAccent.withOpacity(0.5), width: 1.5),
              ),
             child: CircleAvatar(
                radius: 18,
                backgroundColor: Colors.blueAccent,
                child: ClipOval(
                  child: Image.asset(
                    'assets/icon/app_icon.png',
                    width: 30, // সার্কেলের রেডিয়াস অনুযায়ী অ্যাডজাস্ট করুন
                    height: 30,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                    const Icon(Icons.terminal_rounded, size: 18, color: Colors.white),
                    // যদি ইমেজ না পায় তবে আগের আইকনটি দেখাবে
                  ),
                ),
              ),
            ),
          ),
        )
      ],
    );
  }

  Widget _buildSearchBar(bool isDark) {
    return InkWell(
      onTap: () => showSearch(context: context, delegate: GlobalSearchDelegate(allModulesList)),
      child: Container(
        height: 50,
        padding: const EdgeInsets.symmetric(horizontal: 14),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(12),
          boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
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
    );
  }

  Widget _buildOverallProgress(double percentage, int passedCount, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(15),
        boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)],
      ),
      child: Row(
        children: [
          Stack(
            alignment: Alignment.center,
            children: [
              SizedBox(
                width: 55,
                height: 55,
                child: CircularProgressIndicator(
                  value: percentage / 100,
                  strokeWidth: 6,
                  backgroundColor: Colors.grey.withOpacity(0.1),
                  valueColor: const AlwaysStoppedAnimation<Color>(Colors.blueAccent),
                ),
              ),
              Text("${percentage.toInt()}%", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
            ],
          ),
          const SizedBox(width: 18),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text("Overall Progress", style: TextStyle(fontSize: 15, fontWeight: FontWeight.bold)),
                const SizedBox(height: 4),
                Text("$passedCount / 32 modules completed", style: const TextStyle(fontSize: 12, color: Colors.grey)),
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
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 15),
        decoration: BoxDecoration(
          color: color.withOpacity(0.12),
          borderRadius: BorderRadius.circular(12),
        ),
        child: Column(
          children: [
            Text(count, style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold, color: color)),
            const SizedBox(height: 4),
            Text(title, style: TextStyle(fontSize: 12, color: isDark ? Colors.white70 : Colors.blueGrey)),
          ],
        ),
      ),
    );
  }

  Widget _buildLearningHubGrid(bool isDark) {
    return GridView.count(
      shrinkWrap: true,
      physics: const NeverScrollableScrollPhysics(),
      crossAxisCount: 2,
      crossAxisSpacing: 12,
      mainAxisSpacing: 12,
      childAspectRatio: 1.6,
      children: [
        _buildMenuCard(context, "Modules", Icons.menu_book, Colors.indigo, isDark, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const HomeScreen())).then((_) => _refreshStats());
        }),
        _buildMenuCard(context, "Bookmarks", Icons.bookmark, Colors.amber.shade800, isDark, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => BookmarkScreen(bookmarkedItems: myGlobalBookmarkList))).then((_) => _refreshStats());
        }),
        _buildMenuCard(context, "IP Master", Icons.construction, Colors.teal, isDark, () {
          Navigator.push(context, MaterialPageRoute(builder: (_)=> SubnetCalculatorScreen()));
        }),
        _buildMenuCard(context, "Flashcards", Icons.bolt, Colors.orange, isDark, () {
          Navigator.push(context, MaterialPageRoute(builder: (context) => const FlashcardGameScreen())).then((_) => _refreshStats());
        }),
      ],
    );
  }

  Widget _buildMenuCard(BuildContext context, String title, IconData icon, Color color, bool isDark, VoidCallback onTap) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(15),
      child: Container(
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          borderRadius: BorderRadius.circular(15),
          boxShadow: [if (!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 5)],
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Icon(icon, color: color, size: 28),
            const SizedBox(height: 8),
            Text(title, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 13)),
          ],
        ),
      ),
    );
  }

  Widget _buildRecentItem(String title, String subtitle, bool isDark) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF1E293B) : Colors.white,
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.blueAccent.withOpacity(0.1)),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(color: Colors.blueAccent.withOpacity(0.1), borderRadius: BorderRadius.circular(10)),
            child: const Icon(Icons.play_circle_fill, color: Colors.blueAccent, size: 24),
          ),
          const SizedBox(width: 15),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(title, maxLines: 1, overflow: TextOverflow.ellipsis, style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
                Text(subtitle, style: const TextStyle(fontSize: 12, color: Colors.grey)),
              ],
            ),
          ),
          const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
        ],
      ),
    );
  }
}