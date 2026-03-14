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
    int passedCount = await UnlockService.getPassedModulesCount();
    int nextLevel = passedCount + 1;
    if (nextLevel > 32) nextLevel = 32;
    _currentLevelId = "m$nextLevel";
    _questions = await FlashcardService.getQuestionsByModule(_currentLevelId);

    if (mounted) {
      setState(() => _isLoading = false);
      _startTimer();
    }
  }

  void _startTimer() {
    _timer?.cancel();
    _timeLeft = 15;
    _timer = Timer.periodic(const Duration(seconds: 1), (timer) {
      if (_timeLeft > 0) setState(() => _timeLeft--);
      else _handleAnswer("");
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
    // লাইট মোডে টেক্সট আরও ডার্ক ও ক্লিয়ার করার জন্য Color পরিবর্তন
    final Color textColor = isDark ? Colors.white : Colors.blueGrey.shade900;
    final Color subTextColor = isDark ? Colors.white70 : Colors.blueGrey.shade700;

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
                _buildFlipCard(card, isDark, textColor, subTextColor),
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
              ? [const Color(0xFF020617), const Color(0xFF0F172A), const Color(0xFF1E293B)]
              : [const Color(0xFFF0F9FF), const Color(0xFFE0F2FE), const Color(0xFFF8FAFC)],
        ),
      ),
      child: Stack(
        children: [
          Positioned(
            top: -50, right: -50,
            child: _rippleCircle(250, isDark ? Colors.blue.withOpacity(0.05) : Colors.blue.withOpacity(0.1)),
          ),
          Positioned(
            bottom: 100, left: -30,
            child: _rippleCircle(180, isDark ? Colors.cyan.withOpacity(0.05) : Colors.cyan.withOpacity(0.08)),
          ),
        ],
      ),
    );
  }

  Widget _rippleCircle(double size, Color color) {
    return Container(
      width: size, height: size,
      decoration: BoxDecoration(shape: BoxShape.circle, color: color),
    );
  }

  Widget _buildTopBar(bool isDark, Color textColor) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 10),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          IconButton(onPressed: () => Navigator.pop(context), icon: Icon(Icons.arrow_back_ios_new, color: textColor, size: 20)),
          Text("LEVEL ${_currentLevelId.toUpperCase()}",
              style: TextStyle(color: textColor, fontWeight: FontWeight.w900, letterSpacing: 1.5)),
          _timerWidget(isDark),
        ],
      ),
    );
  }

  Widget _timerWidget(bool isDark) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
      decoration: BoxDecoration(
        color: _timeLeft < 5 ? Colors.red.withOpacity(0.1) : (isDark ? Colors.white10 : Colors.blue.withOpacity(0.05)),
        borderRadius: BorderRadius.circular(12),
        border: Border.all(color: _timeLeft < 5 ? Colors.redAccent : Colors.blueAccent.withOpacity(0.3)),
      ),
      child: Text("$_timeLeft s", style: TextStyle(color: _timeLeft < 5 ? Colors.redAccent : Colors.blueAccent, fontWeight: FontWeight.bold)),
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
              Icon(Icons.auto_awesome, color: Colors.blueAccent.withOpacity(0.4), size: 16),
            ],
          ),
          const SizedBox(height: 10),
          ClipRRect(
            borderRadius: BorderRadius.circular(10),
            child: LinearProgressIndicator(
              value: (_currentIndex + 1) / _questions.length,
              minHeight: 6,
              color: Colors.blueAccent,
              backgroundColor: isDark ? Colors.white10 : Colors.black.withOpacity(0.05),
            ),
          ),
        ],
      ),
    );
  }

  Widget _buildFlipCard(Flashcard card, bool isDark, Color textColor, Color subTextColor) {
    return AnimatedBuilder(
      animation: _controller,
      builder: (context, child) {
        final angle = _animation.value * pi;
        return Transform(
          transform: Matrix4.identity()..setEntry(3, 2, 0.001)..rotateY(angle)..scale(_scaleAnimation.value),
          alignment: Alignment.center,
          child: angle < pi / 2
              ? _glassCard(card.question, "QUESTION", Colors.blueAccent, isDark, textColor, subTextColor)
              : Stack(
            children: [
              Transform(
                transform: Matrix4.identity()..rotateY(pi),
                alignment: Alignment.center,
                child: _glassCard("${card.answer}\n\n${card.explanation}", "ANSWER", Colors.teal, isDark, textColor, subTextColor),
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
        borderRadius: BorderRadius.circular(10),
        boxShadow: [BoxShadow(color: Colors.black.withOpacity(0.1), blurRadius: 8)],
      ),
      child: Text(isCorrect ? "CORRECT" : "WRONG",
          style: const TextStyle(color: Colors.white, fontWeight: FontWeight.w900, fontSize: 11, letterSpacing: 1)),
    );
  }

  Widget _glassCard(String text, String label, Color accent, bool isDark, Color textColor, Color subTextColor) {
    return Container(
      margin: const EdgeInsets.symmetric(horizontal: 35),
      height: 300, width: double.infinity,
      decoration: BoxDecoration(
        // লাইট মোডে অপাসিটি কিছুটা বাড়ানো হয়েছে যেন টেক্সট ভেসে ওঠে
        color: isDark ? Colors.white.withOpacity(0.08) : Colors.white.withOpacity(0.75),
        borderRadius: BorderRadius.circular(35),
        border: Border.all(color: isDark ? Colors.white12 : Colors.white),
        boxShadow: [
          BoxShadow(color: accent.withOpacity(isDark ? 0.1 : 0.05), blurRadius: 25, spreadRadius: 2)
        ],
      ),
      child: ClipRRect(
        borderRadius: BorderRadius.circular(35),
        child: BackdropFilter(
          filter: ImageFilter.blur(sigmaX: 20, sigmaY: 20),
          child: Padding(
            padding: const EdgeInsets.all(25),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(label, style: TextStyle(color: accent, fontSize: 10, letterSpacing: 3, fontWeight: FontWeight.w900)),
                const SizedBox(height: 20),
                Text(text, textAlign: TextAlign.center,
                    style: TextStyle(fontSize: 19, color: textColor, fontWeight: FontWeight.bold, height: 1.4)),
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

          Color optionBg = isDark ? Colors.white.withOpacity(0.06) : Colors.white.withOpacity(0.85);
          Color borderCol = isDark ? Colors.white10 : Colors.blueGrey.withOpacity(0.1);

          if (_isAnswered) {
            if (isCorrect) borderCol = Colors.green.shade400;
            else if (isSelected) borderCol = Colors.red.shade400;
          }

          return GestureDetector(
            onTap: () => _handleAnswer(option),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 250),
              margin: const EdgeInsets.only(bottom: 12),
              padding: const EdgeInsets.symmetric(vertical: 16, horizontal: 20),
              decoration: BoxDecoration(
                  color: optionBg,
                  borderRadius: BorderRadius.circular(20),
                  border: Border.all(color: borderCol, width: 2),
                  boxShadow: [
                    if(!isDark) BoxShadow(color: Colors.black.withOpacity(0.03), blurRadius: 10, offset: const Offset(0, 4))
                  ]
              ),
              child: Row(
                children: [
                  Expanded(child: Text(option, style: TextStyle(color: textColor, fontWeight: FontWeight.w600, fontSize: 15))),
                  if (_isAnswered && isCorrect) Icon(Icons.check_circle_rounded, color: Colors.green.shade400, size: 22),
                  if (_isAnswered && isSelected && !isCorrect) Icon(Icons.cancel_rounded, color: Colors.red.shade400, size: 22),
                ],
              ),
            ),
          );
        }).toList(),
      ),
    );
  }

  void _showCompleteDialog() {
    showDialog(context: context, barrierDismissible: false, builder: (c) => BackdropFilter(
      filter: ImageFilter.blur(sigmaX: 12, sigmaY: 12),
      child: AlertDialog(
        backgroundColor: Theme.of(context).brightness == Brightness.dark ? const Color(0xFF1E293B) : Colors.white.withOpacity(0.9),
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(30)),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const Icon(Icons.emoji_events_rounded, color: Colors.amber, size: 70),
            const SizedBox(height: 15),
            Text("LEVEL COMPLETED", style: TextStyle(fontWeight: FontWeight.w900, fontSize: 18, color: Theme.of(context).brightness == Brightness.dark ? Colors.white : Colors.blueGrey.shade900)),
            const SizedBox(height: 8),
            const Text("You've mastered this module!", style: TextStyle(color: Colors.blueGrey)),
            const SizedBox(height: 25),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton(
                style: ElevatedButton.styleFrom(
                    backgroundColor: Colors.blueAccent,
                    elevation: 0,
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(15)),
                    padding: const EdgeInsets.symmetric(vertical: 15)
                ),
                onPressed: () => Navigator.pop(context),
                child: const Text("CONTINUE", style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold, letterSpacing: 1)),
              ),
            )
          ],
        ),
      ),
    ));
  }
}