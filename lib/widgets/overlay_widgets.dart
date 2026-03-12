import 'dart:async';
import 'package:flutter/material.dart';

class OverlayWidgets {
  // কাজ ২: রেজাল্ট ওভারলে কার্ড
  static void showResultOverlay({
    required BuildContext context,
    required bool passed,
    required VoidCallback onPrimary, // Next Module / Try Again
    required VoidCallback onSecondary, // Skip / View Details
  }) {
    Timer? timer;
    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (context) {
        // ৫ সেকেন্ড পর অটোমেটিক View Details/Skip এ চলে যাবে
        timer = Timer(const Duration(seconds: 5), () => onSecondary());

        return AlertDialog(
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(20)),
          backgroundColor: const Color(0xFF1E293B),
          content: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(passed ? Icons.emoji_events : Icons.sentiment_very_dissatisfied,
                  size: 60, color: passed ? Colors.amber : Colors.redAccent),
              const SizedBox(height: 15),
              Text(passed ? "অভিনন্দন!" : "মন খারাপ করো না!",
                  style: const TextStyle(color: Colors.white, fontSize: 20, fontWeight: FontWeight.bold)),
              const SizedBox(height: 10),
              Text(passed ? "তুমি সফলভাবে মডিউলটি শেষ করেছ।" : "তুমি চাইলে আবার চেষ্টা করতে পারো।",
                  textAlign: TextAlign.center, style: const TextStyle(color: Colors.white70)),
              const SizedBox(height: 20),
              ElevatedButton(
                style: ElevatedButton.styleFrom(backgroundColor: Colors.blueAccent),
                onPressed: () { timer?.cancel(); onPrimary(); },
                child: Text(passed ? "Next Module" : "Try Again", style: const TextStyle(color: Colors.white)),
              ),
              TextButton(
                onPressed: () { timer?.cancel(); onSecondary(); },
                child: Text(passed ? "Skip" : "View Details", style: const TextStyle(color: Colors.blueAccent)),
              ),
            ],
          ),
        );
      },
    ).then((_) => timer?.cancel());
  }

  // কাজ ৩: লকড মডিউল অ্যাকশন কার্ড
  static void showLockActionCard({
    required BuildContext context,
    required VoidCallback onQuiz,
    required VoidCallback onAd,
  }) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        backgroundColor: const Color(0xFF1E293B),
        title: const Text("মডিউলটি লকড!", style: TextStyle(color: Colors.white)),
        content: const Text("লক খুলতে কুইজ দিন অথবা অ্যাড দেখুন।", style: TextStyle(color: Colors.white70)),
        actions: [
          ElevatedButton(onPressed: onQuiz, child: const Text("কুইজ দিন")),
          TextButton(onPressed: onAd, child: const Text("Watch Ad for Unlock")),
        ],
      ),
    );
  }
}