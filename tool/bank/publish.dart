// Checks for the "Publish bank" step (FEAT-15 D6, BNK-07, BNK-10). Pure, so
// test/tool/publish_bank_test.dart covers them without a server.
import 'dart:convert';

import 'package:crypto/crypto.dart';
import 'package:number_ninja/domain/bank_validator.dart';
import 'package:number_ninja/domain/question.dart';

/// Lower-case hex sha256 of [bytes], as stored in `banks.sha256`.
String sha256Hex(List<int> bytes) => sha256.convert(bytes).toString();

/// Why [next] may not be published, or null. [latestVersion] is the highest
/// published version (null if none); [previous] are banks whose every id
/// [next] must keep: the latest published one and the newest release's
/// bundled one.
String? publishProblem(
  QuestionBank next, {
  int? latestVersion,
  List<QuestionBank> previous = const [],
}) {
  final problems = validateBank(next);
  if (problems.isNotEmpty) {
    return 'validator: ${problems.length} problems, first: ${problems.first}';
  }
  if (next.format > bankFormatSupported) {
    return 'format ${next.format} is newer than this app reads '
        '($bankFormatSupported)';
  }
  if (latestVersion != null && next.version <= latestVersion) {
    return 'version ${next.version} is not higher than the published '
        '$latestVersion: bump bankVersion in tool/bank/bank.dart';
  }
  final missing = <String>{
    for (final p in previous) ...missingIds(p, next),
  }.toList()..sort();
  if (missing.isNotEmpty) {
    return '${missing.length} question ids would disappear (retire them in '
        'tool/bank/retired.dart instead): ${missing.take(20).join(', ')}';
  }
  return null;
}

/// Why the committed bank differs from what the generator writes, or null.
String? committedProblem(String generated, String committed) =>
    generated == committed
    ? null
    : 'assets/questions/bank.json is not what the generator writes: run '
          'dart run tool/generate_bank.dart and commit it';

QuestionBank parseBank(List<int> bytes) => QuestionBank.fromJson(
  jsonDecode(utf8.decode(bytes)) as Map<String, dynamic>,
);
