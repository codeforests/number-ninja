import 'package:drift/drift.dart' show Value;
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/crash_reporter.dart';
import 'package:number_ninja/data/crash_repository.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/domain/crash.dart';
import 'package:number_ninja/features/quiz/quiz_screen.dart';
import 'package:number_ninja/providers.dart';

import '../../data/fake_server_client.dart';
import '../../data/sync/fake_sync_timers.dart';
import '../quiz/quiz_harness.dart';

/// FEAT-24 in the real app: route pattern, scrubbed names from the
/// database, send at launch and resume (AC-1, AC-2, AC-4).
void main() {
  late QuizHarness h;
  late CrashReporter reporter;
  late FakeServerClient server;

  setUp(() {
    h = QuizHarness();
    reporter = CrashReporter(
      clock: h.clock,
      info: const CrashInfo(appVersion: '2.2.0+22', os: 'test', device: 'X'),
    );
    server = FakeServerClient(ServerConfig.parse('https://api.example.com'));
    h.more = [
      crashReporterProvider.overrideWithValue(reporter),
      serverConfigProvider.overrideWithValue(server.config),
      serverClientProvider.overrideWithValue(server),
      syncTimersProvider.overrideWithValue(FakeSyncTimers()),
    ];
  });
  tearDown(() => h.db.close());

  Future<void> setNickname(String name) =>
      (h.db.update(h.db.children)..where((c) => c.id.equals(1))).write(
        ChildrenCompanion(nickname: Value(name)),
      );

  testWidgets('a build error on SCR-04 is saved with the route pattern and '
      'no name (AC-1, AC-2)', (tester) async {
    await setNickname('Mia');
    h.more = [crashReporterProvider.overrideWithValue(reporter)];
    await h.pumpApp(tester, location: Routes.quiz(numberTopic));
    expect(find.byType(QuizScreen), findsOneWidget);
    final restore = reporter.install();
    try {
      Navigator.of(tester.element(find.byType(QuizScreen))).push(
        MaterialPageRoute<void>(
          builder: (_) => throw StateError('no stars for Mia'),
        ),
      );
      await tester.pump();
      await tester.pump();
      expect(tester.takeException(), isA<StateError>());
    } finally {
      restore();
    }
    // Let the covered quiz screen finish its own writes first.
    await tester.pump(const Duration(seconds: 1));
    await reporter.settled;
    final row = (await CrashRepository(h.db).all()).first;
    expect(row.errorType, 'StateError');
    expect(row.message, 'Bad state: no stars for <name>');
    expect(row.screen, '/quiz/:topicId');
    expect(row.screen, isNot(contains(numberTopic)));
    expect(row.appVersion, '2.2.0+22');
    expect(row.bankVersion, h.bank.version);
  });

  testWidgets('pending reports go at launch and on resume (AC-4)', (
    tester,
  ) async {
    final repo = CrashRepository(h.db);
    final entry = CrashEntry(
      type: 'StateError',
      message: 'old',
      stack: '#0 f',
      screen: '/',
      at: h.now,
    );
    await repo.record(entry, reporter.info, h.bank.version);
    await h.pumpApp(tester);
    expect(server.crashReports, hasLength(1));
    expect(server.crashReports.single['message'], 'old');

    await repo.record(
      CrashEntry(
        type: 'TypeError',
        message: 'new',
        stack: '#0 g',
        screen: '/',
        at: h.now,
      ),
      reporter.info,
      h.bank.version,
    );
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.hidden);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.inactive);
    tester.binding.handleAppLifecycleStateChanged(AppLifecycleState.resumed);
    await tester.pumpAndSettle();
    expect(server.crashReports.map((b) => b['message']), ['old', 'new']);
  });
}
