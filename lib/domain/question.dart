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
    this.retired = false,
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
      retired: j['retired'] == true,
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

  /// Kept so old results stay readable, never served (BNK-10).
  final bool retired;

  /// This question, marked retired (FEAT-15).
  Question asRetired() => Question(
    id: id,
    topic: topic,
    level: level,
    format: format,
    prompt: prompt,
    answer: answer,
    explanation: explanation,
    visual: visual,
    options: options,
    drag: drag,
    check: check,
    retired: true,
  );

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
    if (retired) 'retired': true,
  };
}

/// The newest bank file format this app reads (BNK-11, FEAT-15 D4). Bump it,
/// with the bank's `format`, when a bank uses something older apps can't show.
const bankFormatSupported = 1;

class QuestionBank {
  QuestionBank({
    required this.version,
    required this.questions,
    this.format = bankFormatSupported,
  }) : byTopic = _group(questions.where((q) => !q.retired)),
       byId = {for (final q in questions) q.id: q};

  factory QuestionBank.fromJson(Map<String, dynamic> j) => QuestionBank(
    version: j['version'] as int,
    format: j['format'] as int? ?? 1,
    questions: [
      for (final q in j['questions'] as List)
        Question.fromJson((q as Map).cast<String, dynamic>()),
    ],
  );

  final int version;
  final int format;

  /// Every question, retired ones too.
  final List<Question> questions;

  /// Active (not retired) questions per topic: what rounds are built from.
  final Map<String, List<Question>> byTopic;

  /// Every question by id, retired ones too (old results).
  final Map<String, Question> byId;

  Map<String, dynamic> toJson() => {
    'version': version,
    'format': format,
    'questions': [for (final q in questions) q.toJson()],
  };

  static Map<String, List<Question>> _group(Iterable<Question> qs) {
    final m = <String, List<Question>>{};
    for (final q in qs) {
      (m[q.topic] ??= []).add(q);
    }
    return m;
  }
}
