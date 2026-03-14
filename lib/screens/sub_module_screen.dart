import 'package:ccna_command_hub/screens/details_screen.dart';
import 'package:ccna_command_hub/screens/quiz_screen.dart';
import 'package:ccna_command_hub/services/unlock_service.dart';
import 'package:ccna_command_hub/widgets/overlay_widgets.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'dart:convert';
import 'package:shared_preferences/shared_preferences.dart';

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

  // ডাইনামিক ইউজার প্রিফিক্স
  String get _userPrefix => FirebaseAuth.instance.currentUser?.uid ?? "guest";

  @override
  void initState() {
    super.initState();

    // ১. Continue Learning লজিক: সরাসরি DetailsScreen-এ নিয়ে যাওয়া
    if (widget.initialIndex != null && widget.initialIndex! >= 0) {
      WidgetsBinding.instance.addPostFrameCallback((_) {
        if (widget.initialIndex! < widget.subModules.length) {
          final selectedSubModule = widget.subModules[widget.initialIndex!];

          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => DetailsScreen(
                moduleId: widget.moduleId,
                subId: selectedSubModule['id'],
                title: selectedSubModule['title'],
                initialIndex: widget.initialIndex,
              ),
            ),
          ).then((_) {
            // ফিরে আসার পর প্রগ্রেস সেভ করা
            _saveLastRead(widget.initialIndex!);
            refresh();
          });
        }
      });
    }
  }

  void refresh() => setState(() {});

  // ২. প্রগ্রেস সেভ করার মেথড (UID-সহ)
  Future<void> _saveLastRead(int currentIndex) async {
    final prefs = await SharedPreferences.getInstance();

    // ইউজার ভিত্তিক কী (Key) ব্যবহার করা হচ্ছে
    await prefs.setString('${_userPrefix}_last_mod_id', widget.moduleId);
    await prefs.setString('${_userPrefix}_last_mod_name', widget.moduleName);
    await prefs.setInt('${_userPrefix}_last_topic_index', currentIndex);

    String subModulesJson = json.encode(widget.subModules);
    await prefs.setString('${_userPrefix}_last_sub_modules', subModulesJson);

    debugPrint("Progress Saved: Module ${widget.moduleId}, Index $currentIndex for User: $_userPrefix");
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(widget.moduleName, style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 18)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.blueAccent,
      ),
      body: ListView.builder(
        padding: const EdgeInsets.symmetric(horizontal: 18, vertical: 20),
        itemCount: widget.subModules.length,
        itemBuilder: (context, index) {
          final sub = widget.subModules[index];

          return FutureBuilder<bool>(
            future: UnlockService.isSubUnlocked(sub['id']),
            builder: (context, snapshot) {
              bool isUnlocked = snapshot.data ?? false;

              return Container(
                margin: const EdgeInsets.only(bottom: 15),
                decoration: BoxDecoration(
                  borderRadius: BorderRadius.circular(18),
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                  boxShadow: [
                    if(!isDark) BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 10)
                  ],
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(12),
                  leading: Container(
                    height: 50, width: 50,
                    decoration: BoxDecoration(
                      color: isUnlocked ? Colors.blueAccent.withOpacity(0.15) : Colors.grey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isUnlocked ? Icons.auto_stories_rounded : Icons.lock_outline_rounded,
                      color: isUnlocked ? Colors.blueAccent : Colors.grey,
                    ),
                  ),
                  title: Text(
                    sub['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: isUnlocked ? (isDark ? Colors.white : Colors.black87) : Colors.grey,
                    ),
                  ),
                  trailing: isUnlocked
                      ? const Icon(Icons.arrow_forward_ios_rounded, size: 18, color: Colors.blueAccent)
                      : const Icon(Icons.lock, size: 16, color: Colors.grey),
                  onTap: () async {
                    // মডিউল লকড কিনা চেক
                    bool modUnlocked = await UnlockService.isModuleUnlocked(widget.moduleId);
                    if (!modUnlocked) {
                      _handleLockedModuleAction();
                      return;
                    }

                    // সিকোয়েনশিয়াল এক্সেস চেক
                    bool canAccess = true;
                    if (index > 0) {
                      canAccess = await UnlockService.isSubUnlocked(widget.subModules[index - 1]['id']);
                    }

                    if (canAccess) {
                      // ৩. পড়ার সময় প্রগ্রেস সেভ করা
                      await UnlockService.markSubAsRead(sub['id']);
                      await _saveLastRead(index);

                      if (!mounted) return;
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                            moduleId: widget.moduleId,
                            subId: sub['id'],
                            title: sub['title'],
                            initialIndex: index,
                          )
                      )).then((_) => refresh());
                    } else {
                      _showCustomLockedDialog(context, "আগে '${widget.subModules[index - 1]['title']}' পড়ে শেষ করো।");
                    }
                  },
                ),
              );
            },
          );
        },
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(16.0),
        child: ElevatedButton.icon(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.blueAccent,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
          ),
          onPressed: () async {
            bool modUnlocked = await UnlockService.isModuleUnlocked(widget.moduleId);
            if (!modUnlocked) {
              _handleLockedModuleAction();
              return;
            }

            bool allRead = await UnlockService.canTakeQuiz(widget.subModules);
            if (allRead) {
              Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(moduleId: widget.moduleId))).then((_) => refresh());
            } else {
              _showCustomLockedDialog(context, "সবগুলো সাব-মডিউল না পড়ে কুইজ দেওয়া যাবে না!");
            }
          },
          icon: const Icon(Icons.quiz_rounded, color: Colors.white),
          label: const Text("Start Final Quiz", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  void _handleLockedModuleAction() {
    OverlayWidgets.showLockActionCard(
      context: context,
      onQuiz: () async {
        Navigator.pop(context);
        String lastModuleToExam = await UnlockService.getLastUnlockedModuleId();
        if(!mounted) return;
        Navigator.push(context, MaterialPageRoute(builder: (context) => QuizScreen(moduleId: lastModuleToExam)));
      },
      onAd: () async {
        await UnlockService.unlockModule(widget.moduleId);
        Navigator.pop(context);
        refresh();
      },
    );
  }

  void _showCustomLockedDialog(BuildContext context, String message) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        content: Text(message, textAlign: TextAlign.center, style: const TextStyle(color: Colors.white)),
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("বুঝেছি", style: TextStyle(color: Colors.blueAccent)))],
      ),
    );
  }
}