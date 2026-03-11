import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:ccna_command_hub/models/quiz_model.dart';
import 'quiz_result_screen.dart';

class QuizScreen extends StatefulWidget {
  final String moduleId;
  const QuizScreen({super.key, required this.moduleId});

  @override
  _QuizScreenState createState() => _QuizScreenState();
}

class _QuizScreenState extends State<QuizScreen> {
  List<QuizQuestion> questions = [];
  bool isLoading = true;

  @override
  void initState() {
    super.initState();
    loadQuizData();
  }

  Future<void> loadQuizData() async {
    try {
      final String response = await rootBundle.loadString('assets/data/quiz.json');
      final Map<String, dynamic> data = json.decode(response);
      final String quizKey = "${widget.moduleId}_quiz";

      if (data.containsKey(quizKey)) {
        List<QuizQuestion> allQuestions = (data[quizKey] as List)
            .map((q) => QuizQuestion.fromJson(q))
            .toList();

        allQuestions.shuffle();
        setState(() {
          questions = allQuestions.take(25).toList();
          isLoading = false;
        });
      }
    } catch (e) {
      debugPrint("Error: $e");
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      backgroundColor: isDark ? const Color(0xFF0F172A) : const Color(0xFFF1F5F9),
      appBar: AppBar(
        title: Text(
          "Module ${widget.moduleId.replaceAll('m', '').padLeft(2, '0')} Quiz",
          style: const TextStyle(fontWeight: FontWeight.w900, letterSpacing: 1.1),
        ),
        centerTitle: true,
        backgroundColor: isDark ? const Color(0xFF1E293B) : Colors.blueAccent,
        elevation: 0,
      ),
      body: isLoading
          ? const Center(child: CircularProgressIndicator())
          : ListView.builder(
        padding: const EdgeInsets.all(16),
        itemCount: questions.length,
        itemBuilder: (context, index) {
          final q = questions[index];
          return Container(
            margin: const EdgeInsets.only(bottom: 20),
            decoration: BoxDecoration(
              color: isDark ? const Color(0xFF1E293B) : Colors.white,
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: isDark ? Colors.white10 : Colors.black12),
            ),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  decoration: BoxDecoration(
                    color: Colors.blueAccent.withOpacity(0.1),
                    borderRadius: const BorderRadius.only(topLeft: Radius.circular(15), topRight: Radius.circular(15)),
                  ),
                  child: Text("Question ${index + 1}/25",
                      style: const TextStyle(color: Colors.blueAccent, fontWeight: FontWeight.bold, fontSize: 12)),
                ),
                Padding(
                  padding: const EdgeInsets.all(16),
                  child: Text(q.question,
                      style: TextStyle(fontSize: 16, fontWeight: FontWeight.w600, color: isDark ? Colors.white : Colors.black87)),
                ),
                ...q.options.map((option) => Theme(
                  data: Theme.of(context).copyWith(unselectedWidgetColor: isDark ? Colors.white70 : Colors.black54),
                  child: RadioListTile<String>(
                    title: Text(option, style: TextStyle(color: isDark ? Colors.white70 : Colors.black87, fontSize: 15)),
                    value: option,
                    activeColor: Colors.blueAccent,
                    groupValue: q.selectedAnswer,
                    onChanged: (value) {
                      setState(() { q.selectedAnswer = value; });
                    },
                  ),
                )),
              ],
            ),
          );
        },
      ),
      // Final Quiz NavigationBar call
      bottomNavigationBar: Container(
        padding: const EdgeInsets.all(20),
        decoration: BoxDecoration(
          color: isDark ? const Color(0xFF1E293B) : Colors.white,
          boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 10)],
        ),
        child: ElevatedButton(
          style: ElevatedButton.styleFrom(
            backgroundColor: Colors.green.shade600,
            minimumSize: const Size(double.infinity, 55),
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
          ),
          onPressed: () {
            Navigator.pushReplacement(
              context,
              MaterialPageRoute(
                  builder: (context) => QuizResultScreen(
                    questions: questions,
                    moduleId: widget.moduleId, // moduleId পাস করতে হবে
                  )
              ),
            );
          },
          child: Text(
            "Submit Module ${widget.moduleId.replaceAll('m', '').padLeft(2, '0')} Final Answers",
            style: const TextStyle(color: Colors.white, fontSize: 18, fontWeight: FontWeight.bold),
          ),
        ),
      ),
    );
  }
}