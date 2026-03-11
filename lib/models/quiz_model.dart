
class QuizQuestion {
  final int id;
  final String question;
  final List<String> options;
  final String answer;
  final String explanation;
  String? selectedAnswer;

  QuizQuestion({
    required this.id,
    required this.question,
    required this.options,
    required this.answer,
    required this.explanation,
    this.selectedAnswer,
});
  // call to json
factory QuizQuestion.fromJson(Map<String, dynamic> json)
{
  return QuizQuestion(
      id: json['id'] ?? 0,
      question: json['question']?? "",
      options: List<String>.from(json['options'] ?? []),
      answer: json['answer']?? "",
      explanation: json['explanation'] ?? "No explanation available.",
  );

}
}
