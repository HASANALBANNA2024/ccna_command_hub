import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:ccna_command_hub/screens/details_screen.dart';
import 'package:ccna_command_hub/screens/quiz_screen.dart';
import 'package:ccna_command_hub/services/unlock_service.dart';

class SubModuleScreen extends StatefulWidget {
  final String moduleId;
  final String moduleName;
  final List<dynamic> subModules;
  final int? initialIndex;

  const SubModuleScreen({
    super.key,
    required this.moduleId,
    required this.moduleName,
    required this.subModules,
    this.initialIndex,
  });

  @override
  State<SubModuleScreen> createState() => _SubModuleScreenState();
}

class _SubModuleScreenState extends State<SubModuleScreen> {
  // ১. ডাইনামিক ইউজার প্রিফিক্স নেওয়া হচ্ছে
  String get _userPrefix => UnlockService.userPrefix;

  @override
  void initState() {
    super.initState();
    // Continue Learning লজিক: যদি ইনডেক্স দেওয়া থাকে তবে সরাসরি সেখানে নিয়ে যাবে
    if (widget.initialIndex != null && widget.initialIndex! >= 0) {
      _navigateToInitialDetail();
    }
  }

  void _navigateToInitialDetail() {
    WidgetsBinding.instance.addPostFrameCallback((_) {
      if (widget.initialIndex! < widget.subModules.length) {
        final selectedSubModule = widget.subModules[widget.initialIndex!];
        _openDetails(
            selectedSubModule['id'].toString(),
            selectedSubModule['title'],
            widget.initialIndex!
        );
      }
    });
  }

  void refresh() {
    if (mounted) setState(() {});
  }

  // Details স্ক্রিনে যাওয়ার কমন ফাংশন
  void _openDetails(String subId, String title, int index) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) => DetailsScreen(
          moduleId: widget.moduleId,
          subId: subId,
          title: title,
          initialIndex: index,
        ),
      ),
    ).then((_) {
      _saveLastRead(index);
      refresh(); // ফিরে আসার পর আইকন (Lock/Check) আপডেট হবে
    });
  }

  // ড্যাশবোর্ডের "Continue Learning" এর জন্য ডেটা সেভ
  Future<void> _saveLastRead(int currentIndex) async {
    try {
      final prefs = await SharedPreferences.getInstance();
      // UnlockService এর কী ফরম্যাট অনুযায়ী সেভ করা হচ্ছে
      await prefs.setString('${_userPrefix}last_mod_id', widget.moduleId);
      await prefs.setString('${_userPrefix}last_mod_name', widget.moduleName);
      await prefs.setInt('${_userPrefix}last_topic_index', currentIndex);
      await prefs.setString('${_userPrefix}last_sub_modules', json.encode(widget.subModules));
    } catch (e) {
      debugPrint("Error saving progress: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
            widget.moduleName,
            style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.blueAccent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        itemCount: widget.subModules.length,
        itemBuilder: (context, index) {
          final sub = widget.subModules[index];
          String subId = sub['id'].toString();

          return FutureBuilder<bool>(
            future: UnlockService.isSubUnlocked(subId),
            builder: (context, snapshot) {
              bool isUnlocked = snapshot.data ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  boxShadow: [
                    if (!isDark)
                      BoxShadow(
                          color: Colors.black.withOpacity(0.05),
                          blurRadius: 10,
                          offset: const Offset(0, 4)
                      )
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
                  leading: CircleAvatar(
                    backgroundColor: isUnlocked
                        ? Colors.green.withOpacity(0.1)
                        : Colors.grey.withOpacity(0.1),
                    child: Icon(
                      isUnlocked ? Icons.check_circle_rounded : Icons.lock_outline_rounded,
                      color: isUnlocked ? Colors.green : Colors.grey,
                      size: 26,
                    ),
                  ),
                  title: Text(
                    sub['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 15,
                      color: isUnlocked
                          ? (isDark ? Colors.white : Colors.black87)
                          : Colors.grey,
                    ),
                  ),
                  trailing: const Icon(Icons.arrow_forward_ios, size: 14, color: Colors.grey),
                  onTap: () async {
                    // ১. মেইন মডিউল লকড কিনা চেক
                    bool modUnlocked = await UnlockService.isModuleUnlocked(widget.moduleId);
                    if (!modUnlocked) {
                      _showCustomLockedDialog(
                          context,
                          "এই মডিউলটি এখনো লক করা আছে!\nআগের মডিউলের ফাইনাল কুইজে পাস করুন।"
                      );
                      return;
                    }

                    // ২. সাব-মডিউল সিকোয়েন্স চেক (আগেরটি পড়া হয়েছে কি না)
                    bool canAccess = true;
                    if (index > 0) {
                      String prevSubId = widget.subModules[index - 1]['id'].toString();
                      canAccess = await UnlockService.isSubUnlocked(prevSubId);
                    }

                    if (canAccess) {
                      // পড়া শুরু করার সাথে সাথে আনলক মার্ক করে দেওয়া হচ্ছে
                      await UnlockService.markSubAsRead(subId);
                      _openDetails(subId, sub['title'], index);
                    } else {
                      _showCustomLockedDialog(
                          context,
                          "ক্রমানুসারে শিখুন!\nআগে '${widget.subModules[index - 1]['title']}' পড়ে শেষ করুন।"
                      );
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: _buildQuizButton(isDark),
    );
  }

  Widget _buildQuizButton(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      ),
      child: ElevatedButton.icon(
        style: ElevatedButton.styleFrom(
          backgroundColor: Colors.blueAccent,
          foregroundColor: Colors.white,
          minimumSize: const Size(double.infinity, 55),
          elevation: 0,
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
        ),
        onPressed: () async {
          // কুইজ দেওয়ার যোগ্যতা চেক
          bool canQuiz = await UnlockService.canTakeQuiz(widget.moduleId, widget.subModules);
          if (canQuiz) {
            Navigator.push(
                context,
                MaterialPageRoute(builder: (context) => QuizScreen(moduleId: widget.moduleId))
            ).then((_) => refresh());
          } else {
            _showCustomLockedDialog(
                context,
                "প্রস্তুতি শেষ হয়নি!\nসবগুলো সাব-মডিউল না পড়ে ফাইনাল কুইজ দেওয়া যাবে না।"
            );
          }
        },
        icon: const Icon(Icons.quiz_rounded),
        label: const Text(
            "START FINAL QUIZ",
            style: TextStyle(fontWeight: FontWeight.bold, letterSpacing: 1.1)
        ),
      ),
    );
  }

  void _showCustomLockedDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.lock_person_rounded, color: Colors.amber, size: 50),
            const SizedBox(height: 15),
            Text(
                message,
                textAlign: TextAlign.center,
                style: const TextStyle(color: Colors.white, height: 1.5)
            ),
          ],
        ),
        actionsAlignment: MainAxisAlignment.center,
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(context),
              child: const Text("বুঝেছি", style: TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold))
          )
        ],
      ),
    );
  }
}