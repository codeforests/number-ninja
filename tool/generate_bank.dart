// Writes assets/questions/bank.json from the templates in tool/bank/
// (FEAT-02). Validates first and writes nothing if there is a problem.
//
//   dart run tool/generate_bank.dart            all topics, write the file
//   dart run tool/generate_bank.dart p1         only p1.* topics, no file
import 'dart:io';

import 'package:number_ninja/domain/bank_validator.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/domain/topics.dart';

import 'bank/bank.dart';
import 'bank/generator.dart';

const outPath = 'assets/questions/bank.json';

void main(List<String> args) {
  final prefix = args.isEmpty ? '' : args.first;
  final bank = buildFor(prefix);
  final problems = validateBank(
    bank,
    topicList: [
      for (final t in topics)
        if (t.id.startsWith(prefix)) t,
    ],
  );

  for (final t in topics.where((t) => t.id.startsWith(prefix))) {
    final qs = bank.byTopic[t.id] ?? const <Question>[];
    final levels = [
      for (final l in [1, 2, 3]) qs.where((q) => q.level == l).length,
    ];
    stdout.writeln('${t.id.padRight(14)} ${qs.length}  levels $levels');
  }
  final n = bank.questions.length;
  final mix = [
    for (final f in QuestionFormat.values)
      '${f.name} ${(100 * bank.questions.where((q) => q.format == f).length / n).round()}%',
  ];
  stdout.writeln('total $n  ${mix.join('  ')}');

  if (problems.isNotEmpty) {
    stderr.writeln('${problems.length} problems:');
    problems.take(40).forEach(stderr.writeln);
    exitCode = 1;
    return;
  }
  if (prefix.isEmpty) {
    File(outPath)
      ..createSync(recursive: true)
      ..writeAsStringSync(encodeBank(bank));
    stdout.writeln('wrote $outPath');
  }
}
