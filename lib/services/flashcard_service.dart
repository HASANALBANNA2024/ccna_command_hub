import 'dart:convert';
import 'package:flutter/services.dart';

class Flashcard {
  final String question;
  final String answer;
  final List<String> options;
  final String explanation;

  Flashcard({required this.question, required this.answer, required this.options, required this.explanation});

  factory Flashcard.fromJson(Map<String, dynamic> json) {
    return Flashcard(
      question: json['question'] ?? '',
      answer: json['answer'] ?? '',
      options: List<String>.from(json['options'] ?? []),
      explanation: json['explanation'] ?? '',
    );
  }
}

class FlashcardService {
  static Future<List<Flashcard>> getQuestionsByModule(String moduleId) async {
    try {
      final String response = await rootBundle.loadString('assets/data/quiz.json');
      final data = await json.decode(response);

      // আপনার JSON এর Key ফরম্যাট অনুযায়ী (m1_quiz, m2_quiz...)
      String key = "${moduleId}_quiz";
      List<dynamic> list = data[key] ?? [];

      return list.map((item) => Flashcard.fromJson(item)).toList()..shuffle();
    } catch (e) {
      return [];
    }
  }
}