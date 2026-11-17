import 'dart:io';

import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/question_bank_loader.dart';
import 'package:number_ninja/domain/bank_validator.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/domain/topics.dart';

import '../../tool/bank/bank.dart';
import '../../tool/bank/generator.dart';

/// The shipped bank (FEAT-02 AC-1 to AC-5).
void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late QuestionBank bank;
  late String text;

  setUpAll(() async {
    text = File(bankAsset).readAsStringSync();
    bank = await loadBank(rootBundle);
  });

  test('is bundled at bankVersion; loadBank returns every question (AC-1)', () {
    expect(bank.version, bankVersion);
    final lines = text.split('\n').where((l) => l.startsWith('{"id"'));
    expect(bank.questions.length, lines.length);
    expect(bank.questions.length, greaterThan(23 * 40));
  });

  test('passes the validator with zero problems (AC-3)', () {
    expect(validateBank(bank), isEmpty);
  });

  test('every topic has 40+ questions at levels 1, 2 and 3 (AC-2)', () {
    for (final t in topics) {
      final qs = bank.byTopic[t.id] ?? const <Question>[];
      expect(qs.length, greaterThanOrEqualTo(40), reason: t.id);
      for (final level in [1, 2, 3]) {
        expect(qs.any((q) => q.level == level), isTrue, reason: t.id);
      }
    }
  });

  test('ids are <topic>.<template>.<nnn> (AC-4)', () {
    final pattern = RegExp(r'^([a-z0-9]+\.[a-z0-9]+)\.[a-z0-9-]+\.\d{3}$');
    for (final q in bank.questions) {
      expect(pattern.firstMatch(q.id)?.group(1), q.topic, reason: q.id);
    }
  });

  test('every question has an explanation (AC-5)', () {
    for (final q in bank.questions) {
      expect(q.explanation.trim(), isNotEmpty, reason: q.id);
    }
  });

  test('the committed file is what the generator writes (AC-3)', () {
    expect(text, encodeBank(buildFor('')));
  });

  test('loadBank reads from any AssetBundle', () async {
    final fake = _FakeBundle(
      '{"version":1,"questions":[{"id":"p1.place.x.001","topic":"p1.place",'
      '"level":1,"format":"number","prompt":"1 + 1?","answer":"2",'
      '"explanation":"Two."}]}',
    );
    final b = await loadBank(fake);
    expect(b.questions.single.answer, '2');
    expect(fake.asked, bankAsset);
  });
}

class _FakeBundle extends CachingAssetBundle {
  _FakeBundle(this.text);

  final String text;
  String? asked;

  @override
  Future<ByteData> load(String key) async {
    asked = key;
    return ByteData.sublistView(Uint8List.fromList(text.codeUnits));
  }
}
