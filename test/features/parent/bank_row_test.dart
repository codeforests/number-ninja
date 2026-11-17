import 'dart:convert';
import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/providers.dart';

import '../../data/fake_server_client.dart';
import '../../ui/layout_checks.dart';
import 'parent_harness.dart';

String? textOf(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data;

/// FEAT-15 AC-5 (BNK-12): the "Question bank" row on SCR-11.
void main() {
  final real = QuestionBank.fromJson(
    jsonDecode(File('assets/questions/bank.json').readAsStringSync())
        as Map<String, dynamic>,
  );
  late ParentHarness h;
  late FakeServerClient client;
  late Directory tmp;

  setUp(() async {
    h = ParentHarness(bank: real);
    tmp = Directory.systemTemp.createTempSync('nn-banks');
    h.banksDir = Directory('${tmp.path}/banks');
    await h.setUp();
  });
  tearDown(() async {
    await h.db.close();
    tmp.deleteSync(recursive: true);
  });

  Future<void> open(WidgetTester tester, ServerConfig config) async {
    client = FakeServerClient(config);
    h.more = [...h.more, serverClientProvider.overrideWithValue(client)];
    await h.openParent(tester, Routes.parent);
    await tester.scrollUntilVisible(
      find.byKey(const Key('bank-tile')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  testWidgets('no server: built-in version, not checked, no button', (
    tester,
  ) async {
    await open(tester, ServerConfig.none);
    expect(
      textOf(tester, 'bank-status'),
      'Version 1 (built in) · not checked yet',
    );
    expect(find.byKey(const Key('bank-check-now')), findsNothing);
    expect(client.bankLog, isEmpty);
  });

  testWidgets('Check now downloads a newer bank and shows it', (tester) async {
    await open(tester, ServerConfig.parse('https://api.example.test'));
    // The launch check found nothing newer.
    expect(
      textOf(tester, 'bank-status'),
      'Version 1 (built in) · checked today, 9:00 am · up to date',
    );
    client.publishBank(QuestionBank(version: 2, questions: real.questions));
    await tester.tap(find.byKey(const Key('bank-check-now')));
    for (var i = 0; i < 100; i++) {
      await tester.runAsync(
        () => Future<void>.delayed(const Duration(milliseconds: 20)),
      );
      await tester.pump();
      if (textOf(tester, 'bank-status')!.contains('(downloaded)')) break;
    }
    expect(
      textOf(tester, 'bank-status'),
      'Version 2 (downloaded) · checked today, 9:00 am · downloaded version 2',
    );
    expect(client.bankLog, [
      'latestBank:$bankFormatSupported',
      'latestBank:$bankFormatSupported',
      'downloadBank:2',
    ]);
  });

  testWidgets('layout at text scale $scaledText', (tester) async {
    setTextScale(tester, scaledText);
    tester.view.physicalSize = physical(scaledSize);
    tester.view.devicePixelRatio = 2;
    await open(tester, ServerConfig.parse('https://api.example.test'));
    expect(tester.takeException(), isNull);
    expectNoOverlap(tester, ['bank-status', 'bank-check-now']);
  });
}
