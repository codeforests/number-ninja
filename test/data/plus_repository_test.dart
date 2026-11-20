import 'package:drift/native.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/plus_repository.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/providers.dart';

import 'fake_server_client.dart';

final _config = ServerConfig.parse('https://api.example.test');
final _now = DateTime(2026, 11, 20, 9);

Entitlement _gift() => Entitlement(
  plus: true,
  until: DateTime.utc(2099, 12, 31, 23, 59, 59),
  source: 'complimentary',
  status: 'active',
  checkedAt: _now.toUtc(),
);

void main() {
  late AppDatabase db;
  late FakeServerClient fake;
  late PlusRepository repo;

  setUp(() {
    db = AppDatabase(NativeDatabase.memory());
    fake = FakeServerClient(_config);
    repo = PlusRepository(db, client: fake, clock: () => _now);
  });
  tearDown(() => db.close());

  group('PlusRepository (AC-2)', () {
    test('refresh stores the entitlement', () async {
      fake.plus = _gift();
      expect(await repo.refresh('u1'), PlusRefresh.updated);
      final c = (await repo.cached())!;
      expect(c.plus, isTrue);
      expect(c.source, 'complimentary');
      expect(c.forever, isTrue);
      expect(c.accountId, 'u1');
      expect(c.deviceCheckedAt, _now);
    });

    test('an offline refresh keeps the old cache', () async {
      fake.plus = _gift();
      await repo.refresh('u1');
      fake.entitlementFail = const SyncException(SyncError.offline);
      expect(await repo.refresh('u1'), PlusRefresh.kept);
      expect((await repo.cached())!.plus, isTrue);
    });

    test('a 401 clears it', () async {
      fake.plus = _gift();
      await repo.refresh('u1');
      fake.entitlementFail = const SyncException(
        SyncError.expired,
        status: 401,
      );
      expect(await repo.refresh('u1'), PlusRefresh.cleared);
      expect(await repo.cached(), isNull);
    });

    test('another account replaces it, even offline', () async {
      fake.plus = _gift();
      await repo.refresh('u1');
      fake.entitlementFail = const SyncException(SyncError.offline);
      await repo.refresh('u2');
      expect(await repo.cached(), isNull);
      fake.entitlementFail = null;
      fake.plus = Entitlement(plus: false, checkedAt: _now.toUtc());
      await repo.refresh('u2');
      final c = (await repo.cached())!;
      expect(c.accountId, 'u2');
      expect(c.plus, isFalse);
    });
  });

  group('PlusController (AC-2)', () {
    late ProviderContainer container;

    setUp(() {
      container = ProviderContainer(
        overrides: [
          databaseProvider.overrideWithValue(db),
          serverClientProvider.overrideWithValue(fake),
          clockProvider.overrideWithValue(() => _now),
        ],
      );
    });
    tearDown(() => container.dispose());

    Future<void> settle() async {
      await container.read(accountProvider.notifier).ready;
      await container.read(plusControllerProvider.notifier).idle;
    }

    Future<bool> plus() async {
      await settle();
      await container.read(plusCacheProvider.future);
      return container.read(plusProvider);
    }

    test('launch signed in refreshes; sign-out clears', () async {
      fake.stored = const Account(id: 'u1', email: 'p@x.co');
      fake.plus = _gift();
      container.listen(plusControllerProvider, (_, _) {});
      expect(await plus(), isTrue);
      await container.read(accountProvider.notifier).signOut();
      expect(await plus(), isFalse);
      expect(await repo.cached(), isNull);
    });

    test('sign-in refreshes; account delete clears', () async {
      fake.plus = _gift();
      container.listen(plusControllerProvider, (_, _) {});
      expect(await plus(), isFalse);
      expect(fake.entitlementCalls, 0);
      await container.read(accountProvider.notifier).signIn('p@x.co', 'pw');
      expect(await plus(), isTrue);
      await container.read(accountProvider.notifier).deleteAccount();
      expect(await plus(), isFalse);
      expect(await repo.cached(), isNull);
    });

    test('check again refreshes', () async {
      fake.stored = const Account(id: 'u1', email: 'p@x.co');
      container.listen(plusControllerProvider, (_, _) {});
      expect(await plus(), isFalse);
      fake.plus = _gift();
      await container.read(plusControllerProvider.notifier).check();
      expect(await plus(), isTrue);
    });
  });
}
