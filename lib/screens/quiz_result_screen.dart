import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ccna_command_hub/models/quiz_model.dart';
import 'package:ccna_command_hub/services/unlock_service.dart';
import 'package:ccna_command_hub/widgets/overlay_widgets.dart';
import 'package:ccna_command_hub/screens/quiz_screen.dart';
import 'package:ccna_command_hub/widgets/overlay_widgets.dart';
import 'package:ccna_command_hub/screens/sub_module_screen.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:firebase_auth/firebase_auth.dart';

class QuizResultScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final String moduleId;

  const QuizResultScreen({super.key, required this.questions, required this.moduleId});

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  bool _isOverlayShown = false; // ওভারলে বারবার আসা বন্ধ করার জন্য ফ্ল্যাগ

  @override
  void initState() {
    super.initState();

    // স্ক্রিন লোড হওয়ার পর একবার ওভারলে দেখানোর লজিক
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_isOverlayShown) {
        await _handleResultAndOverlay();
        if (mounted) {
          setState(() {
            _isOverlayShown = true;
          });
        }
      }
    });
  }

  // রেজাল্ট সেভ এবং ওভারলে দেখানোর লজিক
  Future<void> _handleResultAndOverlay() async {
    int score = widget.questions.where((q) => q.selectedAnswer == q.answer).length;
    bool passed = score >= 18; // আপনার পাসিং মার্ক অনুযায়ী

    if (passed) {
      final prefs = await SharedPreferences.getInstance();
      final String uid = FirebaseAuth.instance.currentUser?.uid ?? "guest";

      // ✅ এখানে UID সহ Key ব্যবহার করতে হবে যাতে Dashboard এটি খুঁজে পায়
      await prefs.setBool('${uid}_quiz_passed_${widget.moduleId}', true);

      // মডিউল আনলক করার জন্য সার্ভিস কল করুন (এটি অলরেডি UID হ্যান্ডেল করছে)
      int currentNum = int.parse(widget.moduleId.replaceAll('m', ''));
      String nextModuleId = "m${currentNum + 1}";
      await UnlockService.unlockModule(nextModuleId);
    }

    // ওভারলে দেখানোর লজিক
    if (!mounted) return;
    OverlayWidgets.showResultOverlay(
      context: context,
      passed: passed,
      onPrimary: () {
        if (passed) {
          // যদি পাস করে, তবেই পরের মডিউলে (m + 1) যাবে
          int currentNum = int.parse(widget.moduleId.replaceAll('m', ''));
          String nextModuleId = "m${currentNum + 1}";

          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(moduleId: nextModuleId),
            ),
          );
        } else {
          // যদি ফেল করে (Try Again), তবে বর্তমান মডিউলেই (Same moduleId) আবার পরীক্ষা নেবে
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(
              builder: (context) => QuizScreen(moduleId: widget.moduleId),
            ),
          );
        }
      },
      onSecondary: () {
        // Skip বা View Details দিলে ড্যাশবোর্ডে ফিরে যাবে
        Navigator.pop(context);
      },
    );


  }




  Future<void> _navigateToNextModule(BuildContext context) async {
    try {
      final String response = await rootBundle.loadString('assets/data/modules.json');
      final List<dynamic> data = json.decode(response);

      int currentNum = int.parse(widget.moduleId.replaceAll('m', ''));
      String nextModId = "m${currentNum + 1}";

      var nextModuleData = data.firstWhere(
            (m) => m['id'] == nextModId,
        orElse: () => null,
      );

      if (nextModuleData != null) {
        if (!context.mounted) return;
        Navigator.pushReplacement(
          context,
          MaterialPageRoute(
            builder: (context) => SubModuleScreen(
              moduleId: nextModuleData['id'],
              moduleName: nextModuleData['name'],
              subModules: nextModuleData['subModules'],
            ),
          ),
        );
      } else {
        Navigator.popUntil(context, (route) => route.isFirst);
      }
    } catch (e) {
      debugPrint("Error navigating to next module: $e");
      Navigator.popUntil(context, (route) => route.isFirst);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    int score = widget.questions.where((q) => q.selectedAnswer == q.answer).length;
    bool passed = score >= 18;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Analysis & Result"),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.blueAccent,
        automaticallyImplyLeading: false,
      ),
      body: Column(
        children: [
          Container(
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25),
            width: double.infinity,
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: passed
                    ? [Colors.green.shade800, Colors.green.shade500]
                    : [Colors.red.shade900, Colors.red.shade600],
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
              ),
              borderRadius: const BorderRadius.only(
                  bottomLeft: Radius.circular(35),
                  bottomRight: Radius.circular(35)
              ),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.2),
                  blurRadius: 10,
                  offset: const Offset(0, 5),
                )
              ],
            ),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(10),
                  decoration: BoxDecoration(
                    color: Colors.white.withOpacity(0.2),
                    shape: BoxShape.circle,
                  ),
                  child: Icon(
                      passed ? Icons.emoji_events_rounded : Icons.gpp_bad_rounded,
                      color: Colors.white,
                      size: 35
                  ),
                ),
                const SizedBox(width: 20),
                Column(
                  mainAxisSize: MainAxisSize.min,
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        passed ? "EXAM PASSED!" : "EXAM FAILED!",
                        style: const TextStyle(
                            color: Colors.white,
                            fontSize: 18,
                            fontWeight: FontWeight.w900,
                            letterSpacing: 1.2
                        )
                    ),
                    const SizedBox(height: 4),
                    Container(
                      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 2),
                      decoration: BoxDecoration(
                        color: Colors.black.withOpacity(0.15),
                        borderRadius: BorderRadius.circular(20),
                      ),
                      child: Text(
                          "Score: $score / 25",
                          style: const TextStyle(
                              color: Colors.white,
                              fontSize: 14,
                              fontWeight: FontWeight.w600
                          )
                      ),
                    ),
                  ],
                ),
              ],
            ),
          ),
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 10),
              itemCount: widget.questions.length,
              itemBuilder: (context, index) {
                final q = widget.questions[index];
                bool isCorrect = q.selectedAnswer == q.answer;

                return Card(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: Icon(isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: isCorrect ? Colors.green : Colors.red),
                    title: Text(q.question,
                        style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: isDark ? Colors.white : Colors.black87)),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow("Your Answer", q.selectedAnswer ?? "Not Answered", isCorrect ? Colors.green : Colors.red),
                            const SizedBox(height: 5),
                            _buildInfoRow("Correct Answer", q.answer, Colors.green),
                            const Divider(height: 25, color: Colors.white10),
                            const Text("Explanation:", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
                            const SizedBox(height: 5),
                            Text(q.explanation,
                                style: TextStyle(color: isDark ? Colors.white60 : Colors.black54, height: 1.4)),
                          ],
                        ),
                      )
                    ],
                  ),
                );
              },
            ),
          ),
        ],
      ),
      bottomNavigationBar: Padding(
        padding: const EdgeInsets.all(15),
        child: TextButton(
          onPressed: () => Navigator.pop(context),
          child: Text(
            // "Return to Module ${widget.moduleId.replaceAll('m', '').padLeft(2, '0')} List",
            "Exit Result Screen",
            style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Row(
      children: [
        Text("$label: ", style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w500)),
        Expanded(child: Text(value, style: TextStyle(fontSize: 13, fontWeight: FontWeight.bold, color: color))),
      ],
    );
  }
}