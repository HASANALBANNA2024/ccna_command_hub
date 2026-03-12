import 'package:ccna_command_hub/screens/details_screen.dart';
import 'package:ccna_command_hub/screens/quiz_screen.dart';
import 'package:ccna_command_hub/services/unlock_service.dart';
import 'package:ccna_command_hub/widgets/overlay_widgets.dart';
import 'package:flutter/material.dart';

class SubModuleScreen extends StatefulWidget {
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
  State<SubModuleScreen> createState() => _SubModuleScreenState();
}

class _SubModuleScreenState extends State<SubModuleScreen> {

  // Refresh korar jonno setState lagbe
  void refresh() => setState(() {});

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF020617) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(widget.moduleName, style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1)),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
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
                  border: Border.all(
                    color: isUnlocked ? Colors.blueAccent.withOpacity(0.4) : Colors.white.withOpacity(0.05),
                    width: 1,
                  ),
                  color: isDark ? const Color(0xFF0F172A) : Colors.white,
                ),
                child: ListTile(
                  contentPadding: const EdgeInsets.all(15),
                  leading: Container(
                    height: 50, width: 50,
                    decoration: BoxDecoration(
                      color: isUnlocked ? Colors.blueAccent.withOpacity(0.15) : Colors.blueGrey.withOpacity(0.1),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Icon(
                      isUnlocked ? Icons.auto_stories_rounded : Icons.lock_person_rounded,
                      color: isUnlocked ? Colors.blueAccent : Colors.blueGrey.shade700,
                    ),
                  ),
                  title: Text(
                    sub['title'],
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      fontSize: 16,
                      color: isUnlocked ? (isDark ? Colors.white : Colors.black87) : Colors.blueGrey.shade600,
                    ),
                  ),
                  subtitle: Text(sub['desc'] ?? "", style: TextStyle(fontSize: 12, color: isDark ? Colors.blueGrey.shade400 : Colors.grey.shade600)),
                  trailing: isUnlocked
                      ? const Icon(Icons.arrow_circle_right_rounded, color: Colors.blueAccent, size: 28)
                      : Icon(Icons.lock_clock_outlined, color: Colors.blueGrey.shade800, size: 20),
                  onTap: () async {
                    // Check if current module is unlocked
                    bool modUnlocked = await UnlockService.isModuleUnlocked(widget.moduleId);

                    if (!modUnlocked) {
                      _handleLockedModuleAction();
                      return;
                    }

                    // Check Sequential Sub-module Access
                    bool canAccess = true;
                    if (index > 0) {
                      canAccess = await UnlockService.isSubUnlocked(widget.subModules[index - 1]['id']);
                    }

                    if (canAccess) {
                      await UnlockService.markSubAsRead(sub['id']);
                      Navigator.push(context, MaterialPageRoute(
                          builder: (context) => DetailsScreen(
                              moduleId: sub['id'].toString().substring(0, 2),
                              subId: sub['id'],
                              title: sub['title']
                          )
                      )).then((_) => refresh());
                    } else {
                      _showCustomLockedDialog(context, "আগে '${widget.subModules[index - 1]['title']}' পড়ে শেষ করুন।");
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
              Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => QuizScreen(moduleId: widget.moduleId)));
            } else {
              _showCustomLockedDialog(context, "সবগুলো সাব-মডিউল না পড়ে ফাইনাল কুইজ দেওয়া যাবে না!");
            }
          },
          icon: const Icon(Icons.psychology_alt_rounded, color: Colors.white),
          label: Text("Start Module ${widget.moduleId.replaceAll('m', '').padLeft(2, '0')} Final Quiz",
              style: const TextStyle(color: Colors.white, fontSize: 16, fontWeight: FontWeight.bold)),
        ),
      ),
    );
  }

  // Logic to find the last pending quiz and open it
  void _handleLockedModuleAction() {
    OverlayWidgets.showLockActionCard(
      context: context,
      onQuiz: () async {
        Navigator.pop(context);
        // Find the actual module that needs exam
        String lastModuleToExam = "m1";
        for (int i = 1; i <= 20; i++) { // Assuming total 20 modules
          String mId = "m$i";
          if (!(await UnlockService.isModuleUnlocked(mId))) {
            lastModuleToExam = "m${i - 1}";
            break;
          }
        }
        Navigator.pushReplacement(context, MaterialPageRoute(builder: (context) => QuizScreen(moduleId: lastModuleToExam)));
      },
      onAd: () async {
        // Unlock current module directly via Ad
        await UnlockService.unlockModule(widget.moduleId);
        Navigator.pop(context);
        refresh();
        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(content: Text("Module Unlocked via Ad!")));
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
        actions: [TextButton(onPressed: () => Navigator.pop(context), child: const Text("বুঝেছি"))],
      ),
    );
  }
}