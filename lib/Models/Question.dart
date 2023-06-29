class Question {
  final String text;
  final List<String> options;
  final String answer;

  Question({
    required this.text,
    required this.options,
    required this.answer,
  });

  factory Question.fromJson(Map<String, dynamic> json) {
    return Question(
      text: json['text'],
      options: json['options'],
      answer: json['answer'],
    );
  }

  Map<String, dynamic> toJson() => {
        'text': text,
        'options': options,
        'answer': answer,
      };
}

class QuestionResponse {
  final String? user;
  final Question question;
  final String answer;

  QuestionResponse({
    required this.user,
    required this.question,
    required this.answer,
  });

  factory QuestionResponse.fromJson(Map<String, dynamic> json) {
    return QuestionResponse(
      user: json['user'],
      question: json['question'],
      answer: json['answer'],
    );
  }

  Map<String, dynamic> toJson() => {
        'user': user,
        'question': question,
        'answer': answer,
      };
}
