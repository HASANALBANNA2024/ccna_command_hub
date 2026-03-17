import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ccna_command_hub/models/quiz_model.dart';
import 'package:ccna_command_hub/services/unlock_service.dart';
import 'package:ccna_command_hub/widgets/overlay_widgets.dart';
import 'package:ccna_command_hub/screens/quiz_screen.dart';
import 'package:ccna_command_hub/screens/sub_module_screen.dart';

class QuizResultScreen extends StatefulWidget {
  final List<QuizQuestion> questions;
  final String moduleId;
  final int score;

  const QuizResultScreen({
    super.key,
    required this.questions,
    required this.moduleId,
    required this.score
  });

  @override
  State<QuizResultScreen> createState() => _QuizResultScreenState();
}

class _QuizResultScreenState extends State<QuizResultScreen> {
  bool _isOverlayShown = false;

  @override
  void initState() {
    super.initState();
    // স্ক্রিন লোড হওয়ার পর রেজাল্ট প্রসেস করা হবে
    WidgetsBinding.instance.addPostFrameCallback((_) async {
      if (!_isOverlayShown) {
        await _handleResultAndOverlay();
      }
    });
  }

  Future<void> _handleResultAndOverlay() async {
    // সঠিকভাবে স্কোর গণনা করা হচ্ছে
    int finalScore = widget.questions.where((q) => q.selectedAnswer == q.answer).length;
    bool passed = finalScore >= 0; // ১৮ মানে ৭২% (পাসিং মার্ক)

    if (passed) {
      // ✅ সার্ভিস কল করে ডাটা সেভ এবং পরবর্তী মডিউল আনলক করা হচ্ছে
      await UnlockService.markQuizAsPassed(widget.moduleId);
    }

    if (!mounted) return;

    setState(() => _isOverlayShown = true);

    // ওভারলে দেখানো হচ্ছে
    OverlayWidgets.showResultOverlay(
      context: context,
      passed: passed,
      onPrimary: () async {
        if (passed) {
          Navigator.pop(context);
          // পাস করলে পরের মডিউলে নিয়ে যাবে
          await _navigateToNextModule(context);
        } else {
          // ফেল করলে কুইজ পুনরায় শুরু করবে
          Navigator.pushReplacement(
            context,
            MaterialPageRoute(builder: (context) => QuizScreen(moduleId: widget.moduleId)),
          );
        }
      },
      onSecondary: () {
        // সেকেন্ডারি বাটন চাপলে রেজাল্ট লিস্ট দেখতে পাবে
        Navigator.pop(context);
      },
    );
  }

  Future<void> _navigateToNextModule(BuildContext context) async {
    try {
      final String response = await rootBundle.loadString('assets/data/modules.json');
      final List<dynamic> data = json.decode(response);

      // বর্তমান আইডি থেকে পরবর্তী আইডি বের করা (m1 -> m2)
      int currentNum = int.parse(widget.moduleId.replaceAll('m', ''));
      String nextModId = "m${currentNum + 1}";

      var nextModuleData = data.firstWhere(
            (m) => m['id'] == nextModId,
        orElse: () => null,
      );

      if (nextModuleData != null) {
        if (!context.mounted) return;

        // সরাসরি পরবর্তী মডিউলের সাব-মডিউল স্ক্রিনে নেভিগেশন
        Navigator.pushAndRemoveUntil(
          context,
          MaterialPageRoute(
            builder: (context) => SubModuleScreen(
              moduleId: nextModuleData['id'],
              moduleName: nextModuleData['name'],
              subModules: nextModuleData['subModules'],
            ),
          ),
              (route) => route.isFirst, // এটি মাঝখানের সব অপ্রয়োজনীয় স্ক্রিন মুছে দিবে
        );
      } else {
        // যদি আর কোনো মডিউল না থাকে (কোর্স সমাপ্ত)
        if (context.mounted) {
          Navigator.popUntil(context, (route) => route.isFirst);
        }
      }
    } catch (e) {
      debugPrint("Navigation Error: $e");
      if (context.mounted) Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;
    int currentScore = widget.questions.where((q) => q.selectedAnswer == q.answer).length;
    bool isPassed = currentScore >= 18;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: const Text("Analysis & Result", style: TextStyle(fontWeight: FontWeight.bold)),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.blueAccent,
        elevation: 0,
        automaticallyImplyLeading: false,
        actions: [
          IconButton(
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              icon: const Icon(Icons.home_rounded)
          )
        ],
      ),
      body: Column(
        children: [
          // স্কোর কার্ড সেকশন
          _buildScoreHeader(isPassed, currentScore),

          // রিভিউ লিস্ট
          Expanded(
            child: ListView.builder(
              padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 12),
              itemCount: widget.questions.length,
              itemBuilder: (context, index) {
                final q = widget.questions[index];
                bool isCorrect = q.selectedAnswer == q.answer;

                return Card(
                  color: isDark ? const Color(0xFF1E293B) : Colors.white,
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                  elevation: isDark ? 0 : 2,
                  margin: const EdgeInsets.only(bottom: 12),
                  child: ExpansionTile(
                    leading: CircleAvatar(
                      backgroundColor: isCorrect ? Colors.green.withOpacity(0.1) : Colors.red.withOpacity(0.1),
                      child: Icon(
                        isCorrect ? Icons.check_circle_rounded : Icons.cancel_rounded,
                        color: isCorrect ? Colors.green : Colors.red,
                        size: 24,
                      ),
                    ),
                    title: Text(
                        q.question,
                        style: TextStyle(
                            fontSize: 14,
                            fontWeight: FontWeight.bold,
                            color: isDark ? Colors.white : Colors.black87
                        )
                    ),
                    children: [
                      Padding(
                        padding: const EdgeInsets.all(16),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            _buildInfoRow("Your Answer", q.selectedAnswer ?? "Not Answered", isCorrect ? Colors.green : Colors.red),
                            const SizedBox(height: 8),
                            _buildInfoRow("Correct Answer", q.answer, Colors.green),
                            const Padding(
                              padding: EdgeInsets.symmetric(vertical: 10),
                              child: Divider(color: Colors.white10),
                            ),
                            const Text(
                                "Explanation:",
                                style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)
                            ),
                            const SizedBox(height: 6),
                            Text(
                                q.explanation,
                                style: TextStyle(
                                    color: isDark ? Colors.white70 : Colors.black54,
                                    height: 1.5,
                                    fontSize: 13
                                )
                            ),
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
      bottomNavigationBar: _buildBottomBar(isDark),
    );
  }

  Widget _buildScoreHeader(bool passed, int score) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 25, horizontal: 25),
      width: double.infinity,
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: passed
              ? [const Color(0xFF15803D), const Color(0xFF22C55E)]
              : [const Color(0xFFB91C1C), const Color(0xFFEF4444)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: const BorderRadius.only(
            bottomLeft: Radius.circular(30),
            bottomRight: Radius.circular(30)
        ),
      ),
      child: Row(
        children: [
          Icon(
              passed ? Icons.stars_rounded : Icons.report_problem_rounded,
              color: Colors.white,
              size: 50
          ),
          const SizedBox(width: 20),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                  passed ? "CONGRATULATIONS!" : "KEEP PRACTICING!",
                  style: const TextStyle(
                      color: Colors.white,
                      fontSize: 18,
                      fontWeight: FontWeight.w900,
                      letterSpacing: 1.1
                  )
              ),
              const SizedBox(height: 5),
              Text(
                  "You scored $score out of 25",
                  style: const TextStyle(color: Colors.white70, fontSize: 14)
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildBottomBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: isDark ? const Color(0xFF0F172A) : Colors.white,
        border: Border(top: BorderSide(color: isDark ? Colors.white10 : Colors.black12)),
      ),
      child: Row(
        children: [
          Expanded(
            child: ElevatedButton(
              style: ElevatedButton.styleFrom(
                backgroundColor: Colors.blueAccent,
                padding: const EdgeInsets.symmetric(vertical: 15),
                shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
              ),
              onPressed: () => Navigator.popUntil(context, (route) => route.isFirst),
              child: const Text("BACK TO HOME", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold)),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildInfoRow(String label, String value, Color color) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(label, style: const TextStyle(fontSize: 12, color: Colors.grey)),
        const SizedBox(height: 2),
        Text(value, style: TextStyle(fontSize: 14, fontWeight: FontWeight.bold, color: color)),
      ],
    );
  }
}