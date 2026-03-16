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
      String targetLevelId = passedCount > 0 ? "m${min(passedCount + 1, 32)}" : "m1";
      _currentLevelId = targetLevelId;
      _questions = await FlashcardService.getQuestionsByModule(_currentLevelId);

      if (mounted) {
        setState(() => _isLoading = false);
        if (_questions.isNotEmpty) _startTimer();
      }
    } catch (e) {
      if (mounted) _showErrorAndPop("Error loading game.");
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
            child: SingleChildScrollView(
              physics: const BouncingScrollPhysics(),
              child: Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Column(
                  children: [
                    _buildTopBar(isDark),
                    _buildQuestionHeader(isDark),
                    const SizedBox(height: 10),
                    _buildFlipCard(card, isDark),
                    const SizedBox(height: 20),
                    _buildOptionsGrid(card, isDark),
                    const SizedBox(height: 30),
                  ],
                ),
              ),
            ),
          ),
        ],
      ),
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
              : [const Color(0xFFB2EBF2), const Color(0xFF80DEEA), const Color(0xFF26C6DA)], // পানির উজ্জ্বল নীল রঙ বাড়ানো হয়েছে
        ),
      ),
      child: Stack(
        children: [
          _movingBubble(300, 0.15, -50, -50),
          _movingBubble(250, 0.1, 400, 200),
          _movingBubble(180, 0.08, 700, -20),
          _movingBubble(120, 0.12, 150, 300),
          _movingBubble(200, 0.07, 550, 100),
          _movingBubble(90, 0.15, 800, 280),
          _movingBubble(350, 0.05, 200, -100),
          // পানির ফিল দেওয়ার জন্য হালকা রিফ্লেকশন
          BackdropFilter(
            filter: ImageFilter.blur(sigmaX: 15, sigmaY: 15), // ব্লার কমানো হয়েছে যাতে পানি স্বচ্ছ মনে হয়
            child: Container(color: Colors.white.withOpacity(0.02)),
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
          gradient: RadialGradient(
            colors: [Colors.white.withOpacity(opacity), Colors.transparent],
          ),
        ),
      ),
    );
  }

  Widget _buildTopBar(bool isDark) {
    return Padding(
      padding: const EdgeInsets.only(top: 5),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: const Icon(Icons.close, size: 24)),
          Text("LEVEL ${_currentLevelId.toUpperCase()}", style: const TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 1.2)),
          _timerWidget(isDark),
        ],
      ),
    );
  }

  Widget _timerWidget(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: Colors.white.withOpacity(0.2),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: Colors.white30),
      ),
      child: Text("$_timeLeft s", style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 14)),
    );
  }

  Widget _buildQuestionHeader(bool isDark) {
    return Column(
      children: [
        const SizedBox(height: 8),
        ClipRRect(
          borderRadius: BorderRadius.circular(10),
          child: LinearProgressIndicator(
            value: (_currentIndex + 1) / _questions.length,
            minHeight: 6,
            backgroundColor: Colors.white12,
            color: Colors.white,
          ),
        ),
        const SizedBox(height: 6),
        Text("Question ${_currentIndex + 1}/${_questions.length}", style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w500)),
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

  Widget _glassCard(String text, String label, bool isDark, Flashcard? card) {
    return Stack(
      clipBehavior: Clip.none,
      children: [
        Container(
          constraints: const BoxConstraints(minHeight: 220),
          width: double.infinity,
          padding: const EdgeInsets.all(25),
          decoration: BoxDecoration(
            color: Colors.white.withOpacity(isDark ? 0.1 : 0.4),
            borderRadius: BorderRadius.circular(30),
            border: Border.all(color: Colors.white.withOpacity(0.4)),
            boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 25)],
          ),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(label, style: const TextStyle(letterSpacing: 3, fontWeight: FontWeight.w900, fontSize: 10, color: Colors.blueAccent)),
              const SizedBox(height: 15),
              Text(
                text,
                textAlign: TextAlign.center,
                style: const TextStyle(fontSize: 19, fontWeight: FontWeight.bold, height: 1.4),
              ),
            ],
          ),
        ),
        // ব্যাজ পজিশন এখন বাম দিকে (Left: 20)
        if (card != null)
          Positioned(
            top: 20,
            left: 20,
            child: _buildResultBadge(card),
          ),
      ],
    );
  }

  Widget _buildResultBadge(Flashcard card) {
    bool isCorrect = _selectedOption == card.answer;
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: isCorrect ? Colors.green.withOpacity(0.9) : Colors.red.withOpacity(0.9),
        borderRadius: BorderRadius.circular(12),
        boxShadow: [BoxShadow(color: Colors.black26, blurRadius: 5)],
      ),
      child: Text(
        isCorrect ? "CORRECT" : "WRONG",
        style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 10),
      ),
    );
  }

  Widget _buildOptionsGrid(Flashcard card, bool isDark) {
    return Column(
      children: card.options.map((option) {
        bool isCorrect = option == card.answer;
        bool isSelected = option == _selectedOption;

        Color borderCol = Colors.white24;
        if (_isAnswered) {
          if (isCorrect) borderCol = Colors.greenAccent;
          else if (isSelected) borderCol = Colors.redAccent;
        }

        return GestureDetector(
          onTap: () => _handleAnswer(option),
          child: AnimatedContainer(
            duration: const Duration(milliseconds: 300),
            margin: const EdgeInsets.only(bottom: 10),
            padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
            decoration: BoxDecoration(
              color: Colors.white.withOpacity(isDark ? 0.08 : 0.3),
              borderRadius: BorderRadius.circular(18),
              border: Border.all(color: borderCol, width: 2),
            ),
            child: Row(
              children: [
                Expanded(child: Text(option, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600))),
                if (_isAnswered && isCorrect) const Icon(Icons.check_circle_rounded, color: Colors.greenAccent, size: 20),
                if (_isAnswered && isSelected && !isCorrect) const Icon(Icons.cancel_rounded, color: Colors.redAccent, size: 20),
              ],
            ),
          ),
        );
      }).toList(),
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
      builder: (c) => BackdropFilter(
        filter: ImageFilter.blur(sigmaX: 10, sigmaY: 10),
        child: AlertDialog(
          backgroundColor: Colors.white.withOpacity(0.95),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(25)),
          title: const Text("Completed!", style: TextStyle(fontWeight: FontWeight.bold)),
          content: const Text("You have finished this level successfully."),
          actions: [
            TextButton(
              onPressed: () {
                UnlockService.unlockModule(_currentLevelId);
                Navigator.pop(context);
                Navigator.pop(context);
              },
              child: const Text("Finish", style: TextStyle(fontWeight: FontWeight.bold, color: Colors.blueAccent)),
            )
          ],
        ),
      ),
    );
  }
}