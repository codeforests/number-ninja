import 'dart:convert';
import 'dart:math';

import 'package:number_ninja/domain/question.dart';

/// What a template (or a hand-written entry) produces; the generator adds the
/// id, topic and level.
class Draft {
  Draft.number(
    this.prompt,
    Object answer, {
    required this.explanation,
    this.check,
    this.visual,
  }) : format = QuestionFormat.number,
       answer = answer is num ? fmtNum(answer) : answer as String,
       options = null,
       drag = null;

  /// Multiple choice. Options are [answer] plus up to three [distractors]
  /// (repeats and the answer itself dropped), shuffled with [rng].
  Draft.mcq(
    Random rng,
    this.prompt,
    Object answer,
    List<Object> distractors, {
    required this.explanation,
    this.visual,
    this.check,
  }) : format = QuestionFormat.mcq,
       answer = '$answer',
       drag = null,
       options = _options(rng, '$answer', distractors);

  /// Drag items into slots in order; [answer] is the item for each slot.
  /// [distractors] are extra items that belong in no slot.
  Draft.drag(
    Random rng,
    this.prompt,
    List<Object> answer,
    List<Object> distractors, {
    required this.explanation,
    this.visual,
  }) : format = QuestionFormat.drag,
       answer = [for (final a in answer) '$a'],
       check = null,
       options = null,
       drag = DragSpec(
         items: _items(rng, answer, distractors),
         slots: answer.length,
       );

  final QuestionFormat format;
  final String prompt;
  final Object answer;
  final String explanation;
  final String? check;
  final Map<String, dynamic>? visual;
  final List<String>? options;
  final DragSpec? drag;

  Question toQuestion(String id, String topic, int level) => Question(
    id: id,
    topic: topic,
    level: level,
    format: format,
    prompt: _tidy(prompt),
    answer: answer,
    explanation: _tidy(explanation),
    visual: visual,
    options: options,
    drag: drag,
    check: check,
  );

  /// A sentence that ends in "p.m." gets one full stop, not two.
  static String _tidy(String s) => s.replaceAll('..', '.');

  /// Same prompt and visual means the same question (the validator's rule).
  String get key => '$prompt|${jsonEncode(visual)}';

  static List<String> _options(Random rng, String answer, List<Object> ds) {
    final picked = <String>[];
    for (final d in ds) {
      final s = '$d';
      if (s != answer && !picked.contains(s)) picked.add(s);
      if (picked.length == 3) break;
    }
    if (picked.length < 2) {
      throw ArgumentError('mcq "$answer" needs at least 2 distractors: $ds');
    }
    return [answer, ...picked]..shuffle(rng);
  }

  static List<String> _items(Random rng, List<Object> answer, List<Object> ds) {
    final ans = [for (final a in answer) '$a'];
    final extra = <String>[];
    for (final d in ds) {
      final s = '$d';
      if (!ans.contains(s) && !extra.contains(s)) extra.add(s);
    }
    final items = [...ans, ...extra]..shuffle(rng);
    // Never show the items already in the answer's order.
    var same = items.length > 1;
    for (var k = 0; same && k < ans.length; k++) {
      same = items[k] == ans[k];
    }
    return same ? [...items.skip(1), items.first] : items;
  }
}

/// Numbers as the bank writes them: no trailing ".0".
String fmtNum(num n) {
  if (n == n.roundToDouble()) return n.round().toString();
  return n.toString();
}

/// Thrown by a template to throw away a draw it can't use; the generator
/// counts it as one try and draws again.
class Retry implements Exception {
  const Retry();
}

Never retry() => throw const Retry();

typedef TemplateFn = Draft Function(Random rng, int level);

/// One question template. Its questions get ids `<topic>.<name>.<nnn>`.
/// A later bank may raise [count] (new questions append) but never lower it.
class Template {
  const Template(this.topic, this.name, this.count, this.make);

  final String topic;
  final String name;
  final int count;
  final TemplateFn make;

  String get key => '$topic.$name';
}

/// A hand-written question. Its id is `<topic>.hw.<nnn>` by its position among
/// the topic's hand-written entries, so new ones are only ever appended.
class Handwritten {
  const Handwritten(this.topic, this.level, this.draft);

  final String topic;
  final int level;

  /// Builds the draft; the [Random] only shuffles MCQ options and drag items.
  final Draft Function(Random rng) draft;
}

/// 32-bit FNV-1a over the code units: a seed that is the same on every run,
/// unlike `String.hashCode` (BNK-05).
int fnv1a(String s) {
  var h = 0x811c9dc5;
  for (final c in s.codeUnits) {
    h ^= c;
    h = (h * 0x01000193) & 0xffffffff;
  }
  return h;
}

String _id(String prefix, int n) => '$prefix.${n.toString().padLeft(3, '0')}';

/// Runs one template with its own seeded [Random]. Levels cycle 1, 2, 3, so
/// they are spread evenly. A draft that repeats an earlier one of the same
/// template is retried, up to 50 times.
List<Question> runTemplate(Template t) {
  final rng = Random(fnv1a(t.key));
  final seen = <String>{};
  final out = <Question>[];
  for (var k = 0; k < t.count; k++) {
    final level = k % 3 + 1;
    Draft? d;
    for (var attempt = 0; attempt < 50 && d == null; attempt++) {
      try {
        final cand = t.make(rng, level);
        if (seen.add(cand.key)) d = cand;
      } on Retry {
        continue;
      }
    }
    if (d == null) {
      throw StateError('${t.key}: no new question after 50 tries at #${k + 1}');
    }
    out.add(d.toQuestion(_id(t.key, k + 1), t.topic, level));
  }
  return out;
}

/// Each hand-written entry gets its own seeded [Random] (from its id), so
/// appending entries never changes earlier ones.
List<Question> runHandwritten(List<Handwritten> hs) {
  final counters = <String, int>{};
  final out = <Question>[];
  for (final h in hs) {
    final n = counters[h.topic] = (counters[h.topic] ?? 0) + 1;
    final id = _id('${h.topic}.hw', n);
    out.add(h.draft(Random(fnv1a(id))).toQuestion(id, h.topic, h.level));
  }
  return out;
}

/// Builds the bank, questions sorted by id.
QuestionBank buildBank(
  List<Template> templates, {
  List<Handwritten> handwritten = const [],
  int version = 1,
}) {
  final qs = [for (final t in templates) ...runTemplate(t)];
  qs.addAll(runHandwritten(handwritten));
  qs.sort((a, b) => a.id.compareTo(b.id));
  return QuestionBank(version: version, questions: qs);
}

/// One question per line, so a diff of the bank shows whole questions.
String encodeBank(QuestionBank bank) {
  final lines = [for (final q in bank.questions) jsonEncode(q.toJson())];
  return '{"version":${bank.version},"questions":[\n'
      '${lines.join(',\n')}\n]}\n';
}
