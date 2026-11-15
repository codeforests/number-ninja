/// A question from the shipped bank (design §3). Pure data.
enum QuestionFormat { mcq, number, drag }

class DragSpec {
  const DragSpec({required this.items, required this.slots});

  factory DragSpec.fromJson(Map<String, dynamic> j) => DragSpec(
    items: [for (final i in j['items'] as List) i as String],
    slots: j['slots'] as int,
  );

  /// Tiles she can drag (may include distractors).
  final List<String> items;

  /// Number of drop slots, filled in order.
  final int slots;

  Map<String, dynamic> toJson() => {'items': items, 'slots': slots};
}

class Question {
  const Question({
    required this.id,
    required this.topic,
    required this.level,
    required this.format,
    required this.prompt,
    required this.answer,
    required this.explanation,
    this.visual,
    this.options,
    this.drag,
    this.check,
  });

  factory Question.fromJson(Map<String, dynamic> j) {
    final format = QuestionFormat.values.byName(j['format'] as String);
    final rawAnswer = j['answer'];
    return Question(
      id: j['id'] as String,
      topic: j['topic'] as String,
      level: j['level'] as int,
      format: format,
      prompt: j['prompt'] as String,
      answer: rawAnswer is List
          ? [for (final a in rawAnswer) a as String]
          : rawAnswer as String,
      explanation: j['explanation'] as String,
      visual: (j['visual'] as Map?)?.cast<String, dynamic>(),
      options: (j['options'] as List?)?.cast<String>(),
      drag: j['drag'] == null
          ? null
          : DragSpec.fromJson((j['drag'] as Map).cast<String, dynamic>()),
      check: j['check'] as String?,
    );
  }

  final String id;
  final String topic;

  /// Difficulty 1–3.
  final int level;
  final QuestionFormat format;
  final String prompt;

  /// A String for mcq (the option text) and number questions; a `List<String>`
  /// (one item per slot, in order) for drag questions.
  final Object answer;
  final String explanation;
  final Map<String, dynamic>? visual;
  final List<String>? options;
  final DragSpec? drag;

  /// Optional arithmetic expression that must evaluate to [answer] (BNK-04).
  final String? check;

  Map<String, dynamic> toJson() => {
    'id': id,
    'topic': topic,
    'level': level,
    'format': format.name,
    'prompt': prompt,
    if (visual != null) 'visual': visual,
    if (options != null) 'options': options,
    if (drag != null) 'drag': drag!.toJson(),
    'answer': answer,
    if (check != null) 'check': check,
    'explanation': explanation,
  };
}

class QuestionBank {
  QuestionBank({required this.version, required this.questions})
    : byTopic = _group(questions);

  factory QuestionBank.fromJson(Map<String, dynamic> j) => QuestionBank(
    version: j['version'] as int,
    questions: [
      for (final q in j['questions'] as List)
        Question.fromJson((q as Map).cast<String, dynamic>()),
    ],
  );

  final int version;
  final List<Question> questions;
  final Map<String, List<Question>> byTopic;

  Map<String, dynamic> toJson() => {
    'version': version,
    'questions': [for (final q in questions) q.toJson()],
  };

  static Map<String, List<Question>> _group(List<Question> qs) {
    final m = <String, List<Question>>{};
    for (final q in qs) {
      (m[q.topic] ??= []).add(q);
    }
    return m;
  }
}
