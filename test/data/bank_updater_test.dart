import 'dart:async';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/bank_store.dart';
import 'package:number_ninja/data/bank_updater.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/domain/plus.dart';
import 'package:number_ninja/domain/question.dart';
import 'package:number_ninja/providers.dart';

import '../../tool/bank/bank.dart';
import 'bank_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  // Versions relative to the bundled bank, so a bankVersion bump keeps
  // these tests meaningful.
  const v = bankVersion;
  late BankRig r;
  setUp(() => r = BankRig());
  tearDown(() => r.dispose());

  Future<int> activeVersion() async =>
      (await r.store.loadActive()).bank.version;

  Future<String?> note() async => (await r.store.checkState()).note;

  group('BankUpdater (FEAT-15 AC-3, BNK-08, BNK-11)', () {
    test('downloads, checks and keeps a newer bank', () async {
      r.client.publishBank(await r.bankAs(v + 1));
      expect(await r.updater.check(), BankCheck.downloaded);
      expect(await activeVersion(), v + 1);
      expect(await note(), 'downloaded version ${v + 1}');
      expect((await r.store.checkState()).checkedAt, r.now);
      expect(r.client.bankLog, [
        'latestBank:$bankFormatSupported',
        'downloadBank:${v + 1}',
      ]);
    });

    test('nothing newer: up to date, no download', () async {
      r.client.publishBank(await r.bankAs(v));
      expect(await r.updater.check(), BankCheck.upToDate);
      expect(await note(), 'up to date');
      expect(r.client.bankLog, hasLength(1));
    });

    test('checks at most once a day unless forced', () async {
      expect(await r.updater.check(), BankCheck.upToDate);
      r.now = r.now.add(const Duration(hours: 23));
      expect(await r.updater.check(), BankCheck.skipped);
      expect(r.client.bankLog, hasLength(1));
      expect(await r.updater.check(force: true), BankCheck.upToDate);
      r.now = r.now.add(const Duration(hours: 24));
      expect(await r.updater.check(), BankCheck.upToDate);
      expect(r.client.bankLog, hasLength(3));
    });

    test(
      'free: no server call, the current bank stays (FEAT-30 AC-8)',
      () async {
        r.client.publishBank(await r.bankAs(v + 1));
        final free = BankUpdater(
          client: r.client,
          store: r.store,
          clock: () => r.now,
          plus: () => false,
        );
        expect(await free.check(force: true), BankCheck.noPlus);
        expect(r.client.bankLog, isEmpty);
        expect(await activeVersion(), v);
        // With Plus it checks as before.
        expect(await r.updater.check(force: true), BankCheck.downloaded);
      },
    );

    test('no server URL: no request', () async {
      final off = BankRig(configured: false);
      addTearDown(off.dispose);
      expect(await off.updater.check(force: true), BankCheck.skipped);
      expect(off.client.bankLog, isEmpty);
    });

    Future<void> expectRejected(String why) async {
      expect(await r.updater.check(), BankCheck.failed);
      expect(await activeVersion(), v);
      expect(await note(), why);
      expect((await r.store.checkState()).checkedAt, isNull);
      expect(await r.db.select(r.db.bankFiles).get(), isEmpty);
    }

    test('a checksum mismatch keeps the current bank', () async {
      r.client.publishBank(await r.bankAs(v + 1), sha256: '0' * 64);
      await expectRejected('rejected: checksum');
    });

    test('a file that does not parse keeps the current bank', () async {
      r.client.publishBank(await r.bankAs(v + 1), text: '{"version":2,');
      await expectRejected('rejected: does not parse');
    });

    test('a validator failure keeps the current bank', () async {
      final b = await r.bankAs(v + 1);
      final q = b.questions.first;
      final bad = Question.fromJson({...q.toJson(), 'level': 7});
      r.client.publishBank(
        await r.bankAs(v + 1, questions: [bad, ...b.questions.skip(1)]),
      );
      await expectRejected('rejected: 1 problems');
    });

    test('a bank that drops an id keeps the current bank (BNK-10)', () async {
      final b = await r.bankAs(v + 1);
      // Each topic has more than 40, so only the dropped id is wrong.
      r.client.publishBank(
        await r.bankAs(v + 1, questions: b.questions.skip(1).toList()),
      );
      await expectRejected('rejected: drops ids');
    });

    test('a newer format is never asked for (BNK-11)', () async {
      final b = await r.bankAs(v + 1);
      final newer = QuestionBank(
        version: v + 1,
        questions: b.questions,
        format: bankFormatSupported + 1,
      );
      r.client.publishBank(newer);
      expect(await r.updater.check(), BankCheck.upToDate);
      expect(await activeVersion(), v);
      // A record that claims an old format for a newer file is rejected.
      final r2 = BankRig();
      addTearDown(r2.dispose);
      r2.client.publishBank(newer);
      final (info, bytes) = r2.client.banks.single;
      r2.client.banks[0] = (
        BankInfo(
          version: info.version,
          format: bankFormatSupported,
          sha256: info.sha256,
          fileUrl: info.fileUrl,
        ),
        bytes,
      );
      expect(await r2.updater.check(), BankCheck.failed);
      expect((await r2.store.checkState()).note, 'rejected: version or format');
    });

    test('offline keeps the current bank and retries next time', () async {
      r.client.bankFail = const SyncException(SyncError.offline);
      expect(await r.updater.check(), BankCheck.failed);
      expect(await note(), 'offline');
      r.client.publishBank(await r.bankAs(v + 1));
      expect(await r.updater.check(), BankCheck.downloaded);
    });

    test('two calls at once make one check', () async {
      r.client.publishBank(await r.bankAs(v + 1));
      final both = await Future.wait([r.updater.check(), r.updater.check()]);
      expect(both, [BankCheck.downloaded, BankCheck.downloaded]);
      expect(r.client.bankLog, hasLength(2));
      expect((await r.store.loadActive()).source, BankSource.downloaded);
    });
  });

  // FEAT-36 AC-10 (IC-12): the launch check waits for the Plus cache.
  group('checkBank at launch', () {
    PlusCache cache() => PlusCache(
      plus: true,
      until: DateTime.utc(2099, 12, 31),
      source: 'complimentary',
      serverCheckedAt: r.now.toUtc(),
      deviceCheckedAt: r.now,
      accountId: 'u1',
    );

    ProviderContainer container(Completer<PlusCache?> loading) {
      final c = ProviderContainer(
        overrides: [
          serverClientProvider.overrideWithValue(r.client),
          bankStoreProvider.overrideWithValue(r.store),
          clockProvider.overrideWithValue(() => r.now),
          plusCacheProvider.overrideWith((ref) => loading.future),
        ],
      );
      addTearDown(c.dispose);
      return c;
    }

    test('Plus in the cache: a check started before it loads asks the '
        'server', () async {
      r.client.publishBank(await r.bankAs(v + 1));
      final loading = Completer<PlusCache?>();
      final c = container(loading);
      final check = c.read(bankCheckProvider)(force: true);
      await Future<void>.delayed(Duration.zero);
      loading.complete(cache());
      expect(await check, BankCheck.downloaded);
      expect(r.client.bankLog, isNotEmpty);
    });

    test('free: noPlus without a server call', () async {
      r.client.publishBank(await r.bankAs(v + 1));
      final loading = Completer<PlusCache?>();
      final c = container(loading);
      final check = c.read(bankCheckProvider)(force: true);
      loading.complete(null);
      expect(await check, BankCheck.noPlus);
      expect(r.client.bankLog, isEmpty);
    });
  });
}
