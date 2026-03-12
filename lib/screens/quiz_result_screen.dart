import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ccna_command_hub/models/quiz_model.dart';
import 'package:ccna_command_hub/services/unlock_service.dart';
import 'package:ccna_command_hub/widgets/overlay_widgets.dart';
import 'package:ccna_command_hub/screens/quiz_screen.dart';
import 'package:ccna_command_hub/screens/sub_module_screen.dart';

class QuizResultScreen extends StatelessWidget {
  final List<QuizQuestion> questions;
  final String moduleId;
  const QuizResultScreen({super.key, required this.questions, required this.moduleId});

  // সরাসরি পরবর্তী মডিউলের ডাটা লোড করে সেখানে যাওয়ার ফাংশন
  Future<void> _navigateToNextModule(BuildContext context) async {
    try {
      // ১. JSON ফাইলটি লোড করা
      final String response = await rootBundle.loadString('assets/data/modules.json');
      final List<dynamic> data = json.decode(response);

      // ২. পরবর্তী মডিউল আইডি বের করা
      int currentNum = int.parse(moduleId.replaceAll('m', ''));
      String nextModId = "m${currentNum + 1}";

      // ৩. লিস্ট থেকে পরবর্তী মডিউলের অবজেক্টটি খুঁজে বের করা
      var nextModuleData = data.firstWhere(
            (m) => m['id'] == nextModId,
        orElse: () => null,
      );

      if (nextModuleData != null) {
        // ৪. সরাসরি পরবর্তী মডিউলের সাব-মডিউল স্ক্রিনে পাঠিয়ে দেওয়া
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
        // যদি আর কোন মডিউল না থাকে তবে হোমে পাঠিয়ে দেওয়া
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
    int score = questions.where((q) => q.selectedAnswer == q.answer).length;
    bool passed = score >= 18;

    // পপআপ ওভারলে দেখানোর লজিক
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (passed) {
        int currentNum = int.parse(moduleId.replaceAll('m', ''));
        String nextModuleId = "m${currentNum + 1}";
        await UnlockService.unlockModule(nextModuleId);
      }

      OverlayWidgets.showResultOverlay(
        context: context,
        passed: passed,
        onPrimary: () {
          Navigator.of(context, rootNavigator: true).pop();
          if (passed) {
            // all update before next module
            Navigator.of(context).popUntil((route) => route.isFirst);
            // সরাসরি নেক্সট মডিউলে যাবে
            _navigateToNextModule(context);
          } else {
            // ট্রাই এগেইন: কুইজ স্ক্রিন আবার চালু হবে
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(builder: (context) => QuizScreen(moduleId: moduleId)),
            );
          }
        },
        onSecondary: () {
          // শুধু পপআপ বন্ধ হবে, ইউজার রেজাল্ট এনালাইসিস দেখবে
          // নিশ্চিত করুন যে শুধুমাত্র পপআপ ডায়ালগটি বন্ধ হচ্ছে
          if (Navigator.canPop(context)) {
            Navigator.of(context, rootNavigator: true).pop();
          }
        },
      );
    });

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
            padding: const EdgeInsets.symmetric(vertical: 20, horizontal: 25), // প্যাডিং কমিয়ে হাইট কন্ট্রোল করা হয়েছে
            width: double.infinity,
            decoration: BoxDecoration(
              // সলিড কালারের বদলে ডিজাইনফুল গ্রেডিয়েন্ট ব্যবহার করা হয়েছে
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
            child: Row( // কলামের বদলে রো (Row) ব্যবহার করে হাইট কমানো হয়েছে
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                // বাম পাশে আইকন
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

                // মাঝখানে টেক্সট এবং স্কোর
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
                    // ছোট করে স্কোর বক্স ডিজাইন
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
              itemCount: questions.length,
              itemBuilder: (context, index) {
                final q = questions[index];
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
            "Return to Module ${moduleId.replaceAll('m', '').padLeft(2, '0')} List",
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