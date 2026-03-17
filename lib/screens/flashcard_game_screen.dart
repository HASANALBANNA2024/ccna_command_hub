import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/flashcard_service.dart';
import '../services/unlock_service.dart';

class FlashcardGameScreen extends StatefulWidget {
  const FlashcardGameScreen({super.key});

  @override
  State<FlashcardGameScreen> createState() => _FlashcardGameScreenState();
}

class _FlashcardGameScreenState extends State<FlashcardGameScreen> with SingleTickerProviderStateMixin {
  List<Flashcard> _questions = [];
  int _currentIndex = 0;
  bool _isLoading = true;
  bool _isAnswered = false;
  String _currentLevelId = "";
  String _selectedOption = "";

  Timer? _timer;
  int _timeLeft = 15;

  late AnimationController _controller;
  late Animation<double> _animation;

  @override
  void initState() {
    super.initState();
    _setupGame();
    _controller = AnimationController(duration: const Duration(milliseconds: 600), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutSine)
    );
  }

  Future<void> _setupGame() async {
    try {
      int passedCount = await UnlockService.getPassedModulesCount();
      List<Flashcard> allFetchedQuestions = [];
      String targetLevelId = "";

      // লজিক ১: Grand Finale (১০০টি প্রশ্ন)
      if (passedCount >= 32) {
        targetLevelId = "Grand Finale";
        for (int i = 1; i <= 32; i++) {
          var moduleQuestions = await FlashcardService.getQuestionsByModule("m$i");
          allFetchedQuestions.addAll(moduleQuestions);
        }
        allFetchedQuestions.shuffle();
        if (allFetchedQuestions.length > 100) {
          allFetchedQuestions = allFetchedQuestions.sublist(0, 100);
        }
      }
      // লজিক ২: নির্দিষ্ট মডিউল (এখানে পরিবর্তন হবে)
      else {
        targetLevelId = "m${passedCount + 1}";
        allFetchedQuestions = await FlashcardService.getQuestionsByModule(targetLevelId);

        // --- এই নিচের অংশটুকু যোগ করুন ---
        allFetchedQuestions.shuffle(); // প্রশ্নগুলো ওলটপালট হবে
        if (allFetchedQuestions.length > 50) {
          allFetchedQuestions = allFetchedQuestions.sublist(0, 50); // ৫০টি প্রশ্ন নিবে
        }
        // -------------------------------

        int tempCount = passedCount;
        while (allFetchedQuestions.isEmpty && tempCount > 0) {
          targetLevelId = "m$tempCount";
          allFetchedQuestions = await FlashcardService.getQuestionsByModule(targetLevelId);

          // ব্যাকআপ মডিউলেও যেন ৫০টিই থাকে তার জন্য এখানেও চেক দিতে পারেন (অপশনাল)
          allFetchedQuestions.shuffle();
          if (allFetchedQuestions.length > 50) {
            allFetchedQuestions = allFetchedQuestions.sublist(0, 50);
          }
          tempCount--;
        }
      }

      if (mounted) {
        if (allFetchedQuestions.isEmpty) {
          _showErrorAndPop("কোনো প্রশ্ন পাওয়া যায়নি।");
          return;
        }
        setState(() {
          _currentLevelId = targetLevelId;
          _questions = allFetchedQuestions;
          _isLoading = false;
        });
        _startTimer();
      }
    } catch (e) {
      if (mounted) _showErrorAndPop("Error: $e");
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 15;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        if (mounted) setState(() => _timeLeft--);
      } else {
        _handleAnswer("");
      }
    });
  }

  void _handleAnswer(String selected) {
    if (_isAnswered) return;
    _timer?.cancel();
    setState(() {
      _isAnswered = true;
      _selectedOption = selected;
    });
    _controller.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      _controller.reverse().then((_) {
        if (!mounted) return;
        if (_currentIndex < _questions.length - 1) {
          setState(() {
            _currentIndex++;
            _isAnswered = false;
            _selectedOption = "";
          });
          _startTimer();
        } else {
          _showCompleteDialog();
        }
      });
    });
  }

  @override
  void dispose() {
    _timer?.cancel();
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final bool isDark = Theme.of(context).brightness == Brightness.dark;
    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));
    final card = _questions[_currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          _buildRealisticWaterBackground(isDark),
          SafeArea(
            child: Padding(
              padding: const EdgeInsets.symmetric(horizontal: 16),
              child: Column(
                children: [
                  _buildTopBar(isDark),
                  const SizedBox(height: 10),
                  _buildQuestionHeader(isDark),
                  const SizedBox(height: 15),
                  // স্ক্রিন ওভারফ্লো রোধ করতে Expanded + SingleChildScrollView ব্যবহার
                  Expanded(
                    child: SingleChildScrollView(
                      physics: const BouncingScrollPhysics(),
                      child: Column(
                        children: [
                          _buildFlipCard(card, isDark),
                          const SizedBox(height: 25),
                          _buildOptionsGrid(card, isDark),
                          const SizedBox(height: 30),
                        ],
                      ),
                    ),
                  ),
                ],
              ),
            ),
          ),
        ],
      ),
    );
  }

  // --- UI COMPONENTS (Updated to prevent overflow) ---

  Widget _buildTopBar(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(vertical: 8),
      child: Row(
        children: [
          IconButton(
            onPressed: () => Navigator.pop(context),
            icon: const Icon(Icons.close, size: 26),
            padding: EdgeInsets.zero,
            constraints: const BoxConstraints(),
          ),
          const SizedBox(width: 10),
          // Expanded ব্যবহার করা হয়েছে যাতে লেভেল নেম বড় হলেও টাইমারকে ধাক্কা না দেয়
          Expanded(
            child: Text(
              "LEVEL ${_currentLevelId.toUpperCase()}",
              textAlign: TextAlign.center,
              style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.0),
              overflow: TextOverflow.ellipsis,
            ),
          ),
          const SizedBox(width: 10),
          _timerWidget(isDark),
        ],
      ),
    );
  }

  Widget _timerWidget(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(10),
        border: Border.all(color: Colors.white30),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          const Icon(Icons.timer_outlined, size: 16, color: Colors.white),
          const SizedBox(width: 4),
          Text(
            "$_timeLeft s",
            style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14, color: Colors.white),
          ),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(bool isDark) {
    return Column(
      children: [
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: _questions.isEmpty ? 0 : (_currentIndex + 1) / _questions.length,
            minHeight: 8,
            backgroundColor: Colors.black12,
            valueColor: AlwaysStoppedAnimation<Color>(isDark ? Colors.blueAccent : Colors.white),
          ),
        ),
        const SizedBox(height: 8),
        Text(
          "Question ${_currentIndex + 1} of ${_questions.length}",
          style: const TextStyle(fontSize: 13, fontWeight: FontWeight.bold),
        ),
      ],
    );
  }

  Widget _buildFlipCard(Flashcard card, bool isDark) {
    return AnimatedBuilder(
      animation: _animation,
      builder: (context, child) {
        final angle = _animation.value * pi;
        return Transform(
          transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle),
          alignment: Alignment.center,
          child: angle < pi / 2
              ? _glassCard(card.question, "QUESTION", isDark, null)
              : Transform(
            transform: Matrix4.identity()..rotateY(pi),
            alignment: Alignment.center,
            child: _glassCard("${card.answer}\n\n${card.explanation}", "ANSWER", isDark, card),
          ),
        );
      },
    );
  }

// ১. কার্ডের ভেতর ব্যাজ এর পজিশন বামে সেট করা হয়েছে
  Widget _glassCard(String text, String label, bool isDark, Flashcard? card) {
    return Stack(
      clipBehavior: Clip.none, // যাতে ব্যাজটি বর্ডারের সাথে সুন্দর দেখায়
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 220),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 30, horizontal: 20),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isDark ? 0.1 : 0.4),
            borderRadius: BorderRadius.circular(25),
            border: Border.all(color: Colors.white.withOpacity(0.3)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.05), blurRadius: 15)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900, fontSize: 11, color: Colors.blueAccent)),
              const SizedBox(height: 20),
              // টেক্সট যেন ওভারফ্লো না করে তার জন্য Flexible বা ConstrainedBox ব্যবহার করা যেতে পারে
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold, height: 1.5),
              ),
            ],
          ),
        ),
        // রেজাল্ট ব্যাজ বাম পাশে পজিশন করা হলো
        if (card != null)
          Positioned(
            top: 25,
            left: 0, // বাম পাশে সেট করা হয়েছে
            child: _buildResultBadge(card),
          ),
      ],
    );
  }

  // ২. বাম পাশের জন্য ব্যাজ এর ডিজাইন আপডেট
  Widget _buildResultBadge(Flashcard card) {
    bool isCorrect = _selectedOption == card.answer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
          color: isCorrect ? Colors.green.shade600 : Colors.red.shade600,
          // বাম দিক সোজা রেখে ডান দিক গোল করা হয়েছে (Tag Style)
          borderRadius: const BorderRadius.only(
            topRight: Radius.circular(10),
            bottomRight: Radius.circular(10),
          ),
          boxShadow: [
            BoxShadow(color: Colors.black26, blurRadius: 4, offset: Offset(2, 2))
          ]
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(isCorrect ? Icons.check_circle : Icons.cancel, color: Colors.white, size: 14),
          const SizedBox(width: 5),
          Text(
            isCorrect ? "CORRECT" : "WRONG",
            style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11),
          ),
        ],
      ),
    );
  }

  // ৩. অপশন গ্রিড আপডেট (ওভারফ্লো প্রোটেকশন)
  Widget _buildOptionsGrid(Flashcard card, bool isDark) {
    return Column(
      children: card.options.map((option) {
        bool isCorrect = option == card.answer;
        bool isSelected = option == _selectedOption;
        Color borderCol = _isAnswered
            ? (isCorrect ? Colors.greenAccent : (isSelected ? Colors.redAccent : Colors.white12))
            : Colors.white24;

        return GestureDetector(
          onTap: () => _handleAnswer(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 14),
            decoration: BoxDecoration(
              color: isSelected ? Colors.blueAccent.withOpacity(0.2) : Colors.white.withOpacity(isDark ? 0.08 : 0.3),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(color: borderCol, width: 2),
            ),
            child: Row(
              children: [
                // Expanded ব্যবহার করা হয়েছে যাতে বড় টেক্সট হলেও আইকনকে ধাক্কা না দেয়
                Expanded(
                  child: Text(
                    option,
                    style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
                  ),
                ),
                if (_isAnswered && isCorrect) const Icon(Icons.check_circle, color: Colors.greenAccent, size: 20),
                if (_isAnswered && isSelected && !isCorrect) const Icon(Icons.cancel, color: Colors.redAccent, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
    );
  }

  Widget _buildRealisticWaterBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF001220), const Color(0xFF002540), const Color(0xFF004060)]
              : [const Color(0xFFB2EBF2), const Color(0xFF80DEEA), const Color(0xFF26C6DA)],
        ),
      ),
      child: Stack(
        children: [
          _movingBubble(300, 0.1, -50, -50),
          _movingBubble(200, 0.08, 500, 150),
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
            child: Container(color: Colors.white.withOpacity(0.01)),
          ),
        ],
      ),
    );
  }

  Widget _movingBubble(double size, double opacity, double top, double left) {
    return Positioned(
      top: top, left: left,
      child: Container(
        width: size, height: size,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: Colors.white.withOpacity(opacity),
        ),
      ),
    );
  }

  void _showErrorAndPop(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    Navigator.pop(context);
  }

  void _showCompleteDialog() {
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (c) => AlertDialog(
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
        title: const Text("Completed!"),
        content: const Text("Level finished successfully."),
        actions: [
          TextButton(
            onPressed: () {
              UnlockService.unlockModule(_currentLevelId);
              Navigator.pop(context);
              Navigator.pop(context);
            },
            child: const Text("Finish"),
          )
        ],
      ),
    );
  }
}