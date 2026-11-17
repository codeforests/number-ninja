import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/bank_store.dart';
import 'package:number_ninja/data/bank_updater.dart';

import 'bank_test_support.dart';

void main() {
  TestWidgetsFlutterBinding.ensureInitialized();
  late BankRig r;
  setUp(() => r = BankRig());
  tearDown(() => r.dispose());

  Future<void> download(int version) async {
    r.client.publishBank(await r.bankAs(version));
    expect(await r.updater.check(force: true), BankCheck.downloaded);
  }

  group('BankStore.loadActive (FEAT-15 AC-4, BNK-09)', () {
    test('a fresh install uses the bundled bank', () async {
      final a = await r.store.loadActive();
      expect(a.source, BankSource.bundled);
      expect(a.bank.version, 1);
    });

    test('the newest good download wins; older ones are deleted', () async {
      await download(2);
      await download(3);
      final a = await r.store.loadActive();
      expect((a.bank.version, a.source), (3, BankSource.downloaded));
      expect(await r.db.select(r.db.bankFiles).get(), hasLength(1));
      expect(r.banksDir.listSync().map((f) => f.uri.pathSegments.last), [
        'bank_v3.json',
      ]);
    });

    test('a missing file falls back to the bundled bank', () async {
      await download(2);
      File('${r.banksDir.path}/bank_v2.json').deleteSync();
      final a = await r.store.loadActive();
      expect((a.bank.version, a.source), (1, BankSource.bundled));
      expect(await r.db.select(r.db.bankFiles).get(), isEmpty);
    });

    test('a damaged file falls back and is removed', () async {
      await download(2);
      final f = File('${r.banksDir.path}/bank_v2.json');
      f.writeAsStringSync('{"version":2,', mode: FileMode.append);
      final a = await r.store.loadActive();
      expect(a.source, BankSource.bundled);
      expect(f.existsSync(), isFalse);
      expect(await r.db.select(r.db.bankFiles).get(), isEmpty);
    });

    test('a bundled bank newer than the download wins', () async {
      await download(2);
      // As if an app update shipped bank 2 or later: same or older download.
      final rows = await r.db.select(r.db.bankFiles).get();
      expect(rows.single.version, 2);
      final bundled = await r.store.bundled();
      expect(bundled.version, lessThan(2));
      // Re-point the row at version 1 (not newer than the bundled bank).
      await r.db.customStatement('UPDATE bank_files SET version = 1');
      final a = await r.store.loadActive();
      expect(a.source, BankSource.bundled);
      expect(await r.db.select(r.db.bankFiles).get(), isEmpty);
    });
  });
}
