import 'dart:async';
import 'dart:math';
import 'dart:ui';
import 'package:flutter/material.dart';
import '../services/flashcard_service.dart';
import '../services/unlock_service.dart';
// import 'package:ccna_command_hub/services/cloud_sync_service.dart'; // এটি আর লাগবে না

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
  late Animation<double> _scaleAnimation;

  @override
  void initState() {
    super.initState();
    _setupGame();
    _controller = AnimationController(duration: const Duration(milliseconds: 1000), vsync: this);
    _animation = Tween<double>(begin: 0, end: 1).animate(
        CurvedAnimation(parent: _controller, curve: Curves.easeInOutBack)
    );
    _scaleAnimation = TweenSequence([
      TweenSequenceItem(tween: Tween<double>(begin: 1.0, end: 1.05), weight: 50),
      TweenSequenceItem(tween: Tween<double>(begin: 1.05, end: 1.0), weight: 50),
    ]).animate(_controller);
  }

  Future<void> _setupGame() async {
    try {
      // 1. User koita module pass koreche seta check kora
      int passedCount = await UnlockService.getPassedModulesCount();

      // 2. Default level m1 set kora
      String targetLevelId = "m1";

      if (passedCount > 0) {
        // Jodi user kono module pass kore thake, tobe tar porer level (last unlocked) load hobe
        int nextLevelNum = passedCount + 1;
        if (nextLevelNum > 32) nextLevelNum = 32;
        targetLevelId = "m$nextLevelNum";
      }

      _currentLevelId = targetLevelId;

      // 3. FlashcardService theke data ana
      _questions = await FlashcardService.getQuestionsByModule(_currentLevelId);

      // 4. Safety Check: Jodi target level-e question na thake, tobe m1 load hobe
      if (_questions.isEmpty && _currentLevelId != "m1") {
        _currentLevelId = "m1";
        _questions = await FlashcardService.getQuestionsByModule(_currentLevelId);
      }

      if (mounted) {
        if (_questions.isNotEmpty) {
          setState(() => _isLoading = false);
          _startTimer();
        } else {
          // Jodi ekdomi kono question na pawa jay (Data error)
          _showErrorAndPop("Questions are currently unavailable.");
        }
      }
    } catch (e) {
      debugPrint("Flashcard Setup Error: $e");
      if (mounted) _showErrorAndPop("An error occurred while loading the game.");
    }
  }

  void _showErrorAndPop(String msg) {
    ScaffoldMessenger.of(context).showSnackBar(SnackBar(content: Text(msg)));
    Navigator.pop(context);
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 15;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) {
        if (mounted) setState(() => _timeLeft--);
      } else {
        _handleAnswer(""); // সময় শেষ হলে অটো ভুল উত্তর সাবমিট
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

    // কার্ড ফ্লিপ হওয়ার পর ৩ সেকেন্ড অপেক্ষা করে পরবর্তী কোয়েশ্চেন
    Future.delayed(const Duration(seconds: 3), () {
      if (!mounted) return;
      if (_currentIndex < _questions.length - 1) {
        _controller.reverse();
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
    final Color textColor = isDark ? Colors.white : const Color(0xFF1E293B);

    if (_isLoading) return const Scaffold(body: Center(child: CircularProgressIndicator()));

    final card = _questions[_currentIndex];

    return Scaffold(
      body: Stack(
        children: [
          _buildWaterBackground(isDark),
          SafeArea(
            child: Column(
              children: [
                _buildTopBar(isDark, textColor),
                _buildQuestionHeader(isDark),
                const Spacer(),
                _buildFlipCard(card, isDark, textColor),
                const Spacer(),
                _buildOptionsGrid(card, isDark, textColor),
                const SizedBox(height: 20),
              ],
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildWaterBackground(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        gradient: LinearGradient(
          begin: Alignment.topCenter,
          end: Alignment.bottomCenter,
          colors: isDark
              ? [const Color(0xFF020617), const Color(0xFF0F172A)]
              : [const Color(0xFFF8FAFC), const Color(0xFFE2E8F0)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50, right: -50,
            child: _rippleCircle(250, isDark ? Colors.blue.withOpacity(0.05) : Colors.blueAccent.withOpacity(0.08)),
          ),
          Positioned(
            bottom: 100, left: -30,
            child: _rippleCircle(180, isDark ? Colors.cyan.withOpacity(0.05) : Colors.cyanAccent.withOpacity(0.05)),
          ),
        ],
      ),
    );
  }

  Widget _rippleCircle(double size, Color color) {
    return Container(width: size, height: size, decoration: BoxDecoration(shape: BoxShape.circle, color: color));
  }

  Widget _buildTopBar(bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20)),
          Text("LEVEL ${_currentLevelId.toUpperCase()}",
              style: TextStyle(color: textColor, fontWeight: FontWeight.w900, letterSpacing: 1.5, fontSize: 16)),
          _timerWidget(isDark),
        ],
      ),
    );
  }

  Widget _timerWidget(bool isDark) {
    bool isUrgent = _timeLeft < 5;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: isUrgent ? Colors.red.withOpacity(0.1) : (isDark ? Colors.white10 : Colors.blue.withOpacity(0.1)),
        borderRadius: BorderRadius.circular(15),
        border: Border.all(color: isUrgent ? Colors.redAccent : Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Row(
        children: [
          Icon(Icons.timer_outlined, size: 16, color: isUrgent ? Colors.redAccent : Colors.blueAccent),
          const SizedBox(width: 5),
          Text("$_timeLeft s", style: TextStyle(color: isUrgent ? Colors.redAccent : Colors.blueAccent, fontWeight: FontWeight.bold)),
        ],
      ),
    );
  }

  Widget _buildQuestionHeader(bool isDark) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 30),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text("Question ${_currentIndex + 1}/${_questions.length}",
                  style: TextStyle(color: isDark ? Colors.white60 : Colors.blueGrey, fontSize: 13, fontWeight: FontWeight.bold)),
              Icon(Icons.bolt_rounded, color: Colors.amber.withOpacity(0.7), size: 18),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              minHeight: 8,
              color: Colors.blueAccent,
              backgroundColor: isDark ? Colors.white10 : Colors.blueAccent.withOpacity(0.1),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlipCard(Flashcard card, bool isDark, Color textColor) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _animation.value * pi;
        return Transform(
          transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle)..scale(_scaleAnimation.value),
          alignment: Alignment.center,
          child: angle < pi / 2
              ? _glassCard(card.question, "QUESTION", Colors.blueAccent, isDark, textColor)
              : Stack(
            children: [
              Transform(
                transform: Matrix4.identity()..rotateY(pi),
                alignment: Alignment.center,
                child: _glassCard("${card.answer}\n\n${card.explanation}", "ANSWER", Colors.teal, isDark, textColor),
              ),
              Positioned(
                top: 25, right: 55,
                child: Transform(
                  transform: Matrix4.identity()..rotateY(pi),
                  alignment: Alignment.center,
                  child: _buildResultBadge(card),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildResultBadge(Flashcard card) {
    bool isCorrect = _selectedOption == card.answer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 6),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.shade600 : Colors.red.shade600,
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.2), blurRadius: 8)],
      ),
      child: Text(isCorrect ? "CORRECT" : "WRONG",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11)),
    );
  }

  Widget _glassCard(String text, String label, Color accent, bool isDark, Color textColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 30),
      height: 320, width: double.infinity,
      decoration: BoxDecoration(
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.85),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: isDark ? Colors.white12 : Colors.white),
        boxShadow: [
          BoxShadow(color: accent.withOpacity(0.1), blurRadius: 30, spreadRadius: 2)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15),
          child: Padding(
            padding: const EdgeInsets.all(30),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(color: accent, fontSize: 12, letterSpacing: 4, fontWeight: FontWeight.w900)),
                const SizedBox(height: 25),
                Text(text, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 20, color: textColor, fontWeight: FontWeight.bold, height: 1.5)),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildOptionsGrid(Flashcard card, bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: Column(
        children: card.options.map((option) {
          bool isCorrect = option == card.answer;
          bool isSelected = option == _selectedOption;

          Color borderCol = isDark ? Colors.white10 : Colors.blueAccent.withOpacity(0.1);
          if (_isAnswered) {
            if (isCorrect) borderCol = Colors.green.shade500;
            else if (isSelected) borderCol = Colors.red.shade500;
          }

          return GestureDetector(
            onTap: () => _handleAnswer(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 300),
              margin: const EdgeInsets.only(bottom: 14),
              padding: const EdgeInsets.symmetric(vertical: 18, horizontal: 22),
              decoration: BoxDecoration(
                  color: isDark ? Colors.white.withOpacity(0.05) : Colors.white,
                  borderRadius: BorderRadius.circular(22),
                  border: Border.all(color: borderCol, width: 2),
                  boxShadow: [
                    if(!isDark) BoxShadow(color: Colors.blueAccent.withOpacity(0.05), blurRadius: 15, offset: const Offset(0, 8))
                  ]
              ),
              child: Row(
                children: [
                  Expanded(child: Text(option, style: TextStyle(color: textColor, fontWeight: FontWeight.bold, fontSize: 16))),
                  if (_isAnswered && isCorrect) Icon(Icons.check_circle_rounded, color: Colors.green.shade500, size: 24),
                  if (_isAnswered && isSelected && !isCorrect) Icon(Icons.cancel_rounded, color: Colors.red.shade500, size: 24),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showCompleteDialog() {
    showDialog(
        context: context,
        barrierDismissible: false,
        builder: (c) => BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
          child: AlertDialog(
            backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white,
            shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
            content: Column(
              mainAxisSize: MainAxisSize.min,
              children: [
                const Icon(Icons.stars_rounded, color: Colors.amber, size: 80),
                const SizedBox(height: 15),
                const Text("MODULE COMPLETED!", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 20)),
                const SizedBox(height: 10),
                const Text("You've successfully mastered this level and earned your progress.", textAlign: TextAlign.center, style: TextStyle(color: Colors.blueGrey)),
                const SizedBox(height: 30),
                SizedBox(
                  width: double.infinity,
                  child: ElevatedButton(
                    style: ElevatedButton.styleFrom(
                        backgroundColor: Colors.blueAccent,
                        elevation: 10,
                        shadowColor: Colors.blueAccent.withOpacity(0.3),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
                        padding: const EdgeInsets.symmetric(vertical: 18)
                    ),
                    onPressed: () async {
                      // ১. লোকাল মেমরিতে প্রগ্রেস সেভ করা
                      await UnlockService.unlockModule(_currentLevelId);

                      // ২. CloudSyncService এর লাইনটি ডিলিট করা হয়েছে কারণ এখন এটি অফলাইন

                      if (!mounted) return;
                      Navigator.pop(context); // Dialog close
                      Navigator.pop(context); // Screen close
                    },
                    child: const Text("FINISH",
                        style: TextStyle(color: Colors.white, fontWeight: FontWeight.w900, letterSpacing: 2)),
                  ),
                )
              ],
            ),
          ),
        ));
  }
}