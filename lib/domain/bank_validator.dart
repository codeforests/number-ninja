import 'dart:convert';

import 'expr.dart';
import 'question.dart';
import 'topics.dart';

/// Checks the bank against the rules in FEAT-02's design (BNK-02..06).
/// Returns one line per problem; empty means valid.
List<String> validateBank(
  QuestionBank bank, {
  List<Topic> topicList = topics,
  int minPerTopic = 40,
}) {
  final problems = <String>[];
  final known = {for (final t in topicList) t.id};
  final ids = <String>{};
  final seen = <String>{};
  final idPattern = RegExp(r'^([a-z0-9]+\.[a-z0-9]+)\.([a-z0-9-]+)\.(\d{3})$');

  for (final q in bank.questions) {
    void bad(String why) => problems.add('${q.id}: $why');

    if (!ids.add(q.id)) bad('duplicate id');
    final m = idPattern.firstMatch(q.id);
    if (m == null) {
      bad('id does not match <topic>.<template>.<nnn>');
    } else if (m.group(1) != q.topic) {
      bad('id topic ${m.group(1)} differs from topic ${q.topic}');
    }
    if (!known.contains(q.topic)) bad('unknown topic ${q.topic}');
    if (q.level < 1 || q.level > 3) bad('level ${q.level} not 1–3');
    if (q.prompt.trim().isEmpty) bad('empty prompt');
    if (q.explanation.trim().isEmpty) bad('empty explanation');

    final key = '${q.topic}|${q.prompt}|${jsonEncode(q.visual)}';
    if (!seen.add(key)) bad('duplicate prompt and visual in ${q.topic}');

    switch (q.format) {
      case QuestionFormat.mcq:
        final opts = q.options ?? const [];
        if (opts.length < 3 || opts.length > 4) bad('mcq needs 3–4 options');
        if (opts.toSet().length != opts.length) bad('mcq options repeat');
        final right = opts.where((o) => o == q.answer).length;
        if (right != 1) bad('mcq has $right correct options');
      case QuestionFormat.number:
        if (q.answer is! String || num.tryParse(q.answer as String) == null) {
          bad('number answer "${q.answer}" is not a number');
        }
        if (q.options != null) bad('number question has options');
      case QuestionFormat.drag:
        final d = q.drag;
        final ans = q.answer;
        if (d == null) {
          bad('drag question has no drag spec');
        } else if (ans is! List<String>) {
          bad('drag answer is not a list');
        } else {
          if (ans.length != d.slots) bad('drag answer length != slots');
          final pool = [...d.items];
          for (final a in ans) {
            if (!pool.remove(a)) bad('drag answer item "$a" not in items');
          }
        }
    }

    if (q.check != null) {
      try {
        final v = evaluate(q.check!);
        final a = q.answer is String ? num.tryParse(q.answer as String) : null;
        if (a == null || (v - a).abs() > 1e-9) {
          bad('check ${q.check} = $v but answer is ${q.answer}');
        }
      } on FormatException catch (e) {
        bad('check "${q.check}" does not parse: ${e.message}');
      }
    }
  }

  for (final t in topicList) {
    final qs = bank.byTopic[t.id] ?? const [];
    if (qs.length < minPerTopic) {
      problems.add('${t.id}: ${qs.length} questions, needs $minPerTopic');
    }
    for (final level in [1, 2, 3]) {
      if (!qs.any((q) => q.level == level)) {
        problems.add('${t.id}: no level $level questions');
      }
    }
  }
  return problems;
}
