import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/crash_repository.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/domain/crash.dart';

void main() {
  late AppDatabase db;
  late CrashRepository repo;
  const info = CrashInfo(appVersion: '2.2.0+22', os: 'Android 14', device: 'X');
  final t0 = DateTime.utc(2026, 11, 20, 3);

  CrashEntry entry(String type, {int i = 0}) => CrashEntry(
    type: type,
    message: 'boom $i',
    stack: '#0 f (package:a/$type.dart:1:1)',
    screen: '/quiz/:topicId',
    at: t0.add(Duration(seconds: i)),
  );

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    repo = CrashRepository(db);
  });
  tearDown(() => db.close());

  test('the same error 500 times is one row with count 500 (AC-3)', () async {
    for (var i = 0; i < 500; i++) {
      await repo.record(entry('StateError', i: i), info, 7);
    }
    final rows = await repo.all();
    expect(rows, hasLength(1));
    expect(rows.single.count, 500);
    expect(rows.single.firstAt.toUtc(), t0);
    expect(rows.single.lastAt.toUtc(), t0.add(const Duration(seconds: 499)));
    expect(rows.single.bankVersion, 7);
  });

  test('40 different errors keep the newest 30 unsent rows (AC-3)', () async {
    for (var i = 0; i < 40; i++) {
      await repo.record(entry('E$i', i: i), info, 1);
    }
    final rows = await repo.all();
    expect(rows, hasLength(crashMaxUnsent));
    expect(rows.map((r) => r.errorType), isNot(contains('E0')));
    expect(rows.map((r) => r.errorType), contains('E39'));
  });

  test('a sent row is not grouped into; purge drops it after 7 days', () async {
    await repo.record(entry('A'), info, 1);
    final sent = await repo.pending();
    await repo.markSent([sent.single.id], t0);
    await repo.record(entry('A', i: 1), info, 1);
    expect(await repo.all(), hasLength(2));
    expect(await repo.pending(), hasLength(1));
    await repo.purge(t0.add(const Duration(days: 6)));
    expect(await repo.all(), hasLength(2));
    await repo.purge(t0.add(const Duration(days: 8)));
    expect(await repo.all(), hasLength(1));
  });

  test('pending gives at most 10 rows', () async {
    for (var i = 0; i < 15; i++) {
      await repo.record(entry('E$i', i: i), info, 1);
    }
    expect(await repo.pending(), hasLength(crashSendBatch));
  });

  test('on by default; off deletes unsent rows (AC-5)', () async {
    expect(await repo.enabled(), isTrue);
    await repo.record(entry('A'), info, 1);
    await repo.setEnabled(false);
    expect(await repo.enabled(), isFalse);
    expect(await repo.all(), isEmpty);
  });

  test('the row and body hold no child, account or device id (AC-2)', () async {
    await repo.record(entry('A'), info, 1);
    final body = crashBody((await repo.all()).single);
    expect(body.keys.toSet(), {
      'signature',
      'app_version',
      'bank_version',
      'os',
      'device',
      'screen',
      'error_type',
      'message',
      'stack',
      'count',
      'first_at',
      'last_at',
    });
  });
}
