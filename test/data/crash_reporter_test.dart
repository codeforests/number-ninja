import 'dart:async';

import 'package:drift/native.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/crash_reporter.dart';
import 'package:number_ninja/data/crash_repository.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/domain/crash.dart';

import 'fake_server_client.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();

  late AppDatabase db;
  late CrashRepository repo;
  late CrashReporter reporter;
  var now = DateTime.utc(2026, 11, 20, 3);
  const info = CrashInfo(appVersion: '2.2.0+22', os: 'Android 14', device: 'X');
  var context = const CrashContext(
    names: ['Mia'],
    email: 'ken@example.com',
    bankVersion: 5,
  );

  setUp(() {
    now = DateTime.utc(2026, 11, 20, 3);
    context = const CrashContext(
      names: ['Mia'],
      email: 'ken@example.com',
      bankVersion: 5,
    );
    db = AppDatabase(NativeDatabase.memory());
    repo = CrashRepository(db);
    reporter = CrashReporter(clock: () => now, info: info);
  });
  tearDown(() => db.close());

  Future<void> attach() =>
      reporter.attach(repo: repo, context: () async => context);

  group('capture (CRS-01, CRS-02)', () {
    test(
      'unawaited future error reaches PlatformDispatcher.onError (AC-1)',
      () async {
        await attach();
        reporter.screen = '/quiz/:topicId';
        final restore = reporter.install();
        try {
          // As in the root zone: an uncaught async error goes to onError.
          runZonedGuarded(
            () => unawaited(Future<void>(() => throw StateError('async'))),
            (e, s) =>
                expect(PlatformDispatcher.instance.onError!(e, s), isTrue),
          );
          await Future<void>.delayed(Duration.zero);
          await reporter.settled;
        } finally {
          restore();
        }
        final row = (await repo.all()).single;
        expect(row.errorType, 'StateError');
        expect(row.message, contains('async'));
        expect(row.stack, isNotEmpty);
        expect(row.screen, '/quiz/:topicId');
        expect([row.appVersion, row.bankVersion], ['2.2.0+22', 5]);
      },
    );

    test('the handler that was there still runs (AC-1)', () async {
      await attach();
      final shown = <FlutterErrorDetails>[];
      final before = FlutterError.onError;
      FlutterError.onError = shown.add;
      final restore = reporter.install();
      try {
        FlutterError.reportError(
          FlutterErrorDetails(exception: StateError('x')),
        );
      } finally {
        restore();
        FlutterError.onError = before;
      }
      await reporter.settled;
      expect(shown, hasLength(1));
      expect(await repo.all(), hasLength(1));
    });

    test(
      'an error inside the reporter is dropped, not looped (AC-1)',
      () async {
        var calls = 0;
        await reporter.attach(
          repo: repo,
          context: () async {
            calls++;
            // The reporter's own failure must not be captured again.
            reporter.capture(StateError('inner'), StackTrace.current);
            throw StateError('context broke');
          },
        );
        reporter.capture(StateError('outer'), StackTrace.current);
        await reporter.settled;
        await reporter.settled;
        expect(calls, 1);
        expect(await repo.all(), isEmpty);
      },
    );

    test('names and email are scrubbed, message capped (AC-2)', () async {
      await attach();
      reporter.capture(
        ArgumentError('MIA typed ${'z' * 2000} ken@EXAMPLE.com'),
        StackTrace.fromString('#0 f (mia.dart:1:1)'),
      );
      await reporter.settled;
      final row = (await repo.all()).single;
      expect(row.message, startsWith('Invalid argument(s): <name> typed'));
      expect(row.message.length, crashMessageMax);
      expect(row.message.toLowerCase(), isNot(contains('mia')));
      expect(row.stack, '#0 f (<name>.dart:1:1)');
      reporter.capture(StateError('mail ken@example.com'), null);
      await reporter.settled;
      final rows = await repo.all();
      expect(rows.last.message, 'Bad state: mail <email>');
    });

    test('errors before attach wait in a 20-item buffer (AD-11)', () async {
      for (var i = 0; i < 25; i++) {
        reporter.capture(StateError('e$i'), StackTrace.fromString('#0 f$i'));
      }
      await attach();
      expect(await repo.all(), hasLength(crashBufferMax));
    });

    test('switch off: nothing is recorded (AC-5)', () async {
      await repo.setEnabled(false);
      await attach();
      reporter.capture(StateError('x'), null);
      await reporter.settled;
      expect(await repo.all(), isEmpty);
    });
  });

  group('send (CRS-04)', () {
    late FakeServerClient server;
    setUp(() {
      server = FakeServerClient(ServerConfig.parse('https://api.example.com'));
    });

    Future<void> seed(int n) async {
      await attach();
      for (var i = 0; i < n; i++) {
        reporter.capture(StateError('e$i'), StackTrace.fromString('#0 f$i'));
      }
      await reporter.settled;
    }

    test('sends at most 10 per send, marks them sent, purges after 7 days '
        '(AC-4)', () async {
      await seed(12);
      await reporter.sendPending(server);
      expect(server.crashReports, hasLength(crashSendBatch));
      expect(await repo.pending(), hasLength(2));
      await reporter.sendPending(server);
      expect(server.crashReports, hasLength(12));
      expect(await repo.pending(), isEmpty);
      expect(await repo.all(), hasLength(12));
      now = now.add(const Duration(days: 8));
      await reporter.sendPending(server);
      expect(await repo.all(), isEmpty);
    });

    test('the body has no child, account, device id or email (AC-2)', () async {
      await seed(1);
      await reporter.sendPending(server);
      final body = server.crashReports.single;
      for (final k in [
        'child',
        'child_id',
        'account',
        'user',
        'device_id',
        'email',
      ]) {
        expect(body.containsKey(k), isFalse, reason: k);
      }
      expect(body['count'], 1);
    });

    test('a failing server keeps rows for next time (AC-4)', () async {
      await seed(3);
      server.crashFail = const SyncException(SyncError.offline);
      await reporter.sendPending(server);
      expect(await repo.pending(), hasLength(3));
      server.crashFail = null;
      await reporter.sendPending(server);
      expect(server.crashReports, hasLength(3));
    });

    test('no server configured: nothing sent (AC-4)', () async {
      await seed(2);
      final none = FakeServerClient(ServerConfig.none);
      await reporter.sendPending(none);
      expect(none.crashReports, isEmpty);
      expect(await repo.pending(), hasLength(2));
    });

    test('switch off: nothing sent (AC-5)', () async {
      await seed(2);
      await repo.setEnabled(false);
      await reporter.sendPending(server);
      expect(server.crashReports, isEmpty);
    });
  });
}
