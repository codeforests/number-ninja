import 'package:drift/native.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/pin_repository.dart';
import 'package:number_ninja/data/profile_repository.dart';
import 'package:number_ninja/data/setup_repository.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/data/sync/sync_service.dart';
import 'package:number_ninja/data/child_repository.dart';
import 'package:number_ninja/data/usage_repository.dart';
import 'package:number_ninja/domain/pin.dart';
import 'package:number_ninja/domain/profile.dart';
import 'package:number_ninja/domain/setup.dart';
import 'package:number_ninja/providers.dart';

import '../../data/fake_server_client.dart';
import '../../data/sync/fake_sync_timers.dart';
import '../quiz/quiz_harness.dart';

final setupServer = ServerConfig.parse('https://api.example.test');

/// The app on a fresh install's database, started as main() does: the
/// setup step and PIN come from the database (FEAT-26).
class SetupHarness extends QuizHarness {
  SetupHarness() {
    more = [pinRepositoryProvider.overrideWithValue(pins())];
  }

  PinRepository pins() =>
      PinRepository(db, clock: clock, hasher: PinHasher(iterations: 10));

  SetupRepository get setup => SetupRepository(db);

  late FakeServerClient client;

  /// Signs nobody in, on a server with an account (AC-3).
  void useServer(FakeSyncServer server) {
    client = FakeServerClient(setupServer, server: server);
    more = [
      ...more,
      serverConfigProvider.overrideWithValue(setupServer),
      serverClientProvider.overrideWithValue(client),
      syncTimersProvider.overrideWithValue(FakeSyncTimers()),
    ];
  }

  /// Opens (or, after a "kill", reopens) the app from the database.
  Future<void> start(
    WidgetTester tester, {
    Size size = const Size(2560, 1600),
    bool unlocked = false,
  }) async {
    await tester.pumpWidget(const SizedBox());
    session = AppSession(
      setupStep: await setup.step(),
      pinSet: await pins().hasPin() && !unlocked,
      clock: clock,
    );
    await pumpApp(tester, size: size);
  }

  Future<void> enter(WidgetTester tester, String pin) async {
    for (final d in pin.split('')) {
      await tester.tap(find.byKey(Key('pin-$d')));
      await tester.pump();
    }
    await tester.pumpAndSettle();
  }

  Future<void> tapKey(WidgetTester tester, String key) async {
    await tester.ensureVisible(find.byKey(Key(key)));
    await tester.pumpAndSettle();
    await tester.tap(find.byKey(Key(key)));
    await tester.pumpAndSettle();
  }

  /// Adds a child on the open Children form.
  Future<void> addChild(
    WidgetTester tester,
    String nickname, {
    int year = 2,
    String avatar = 'owl',
  }) async {
    await tester.enterText(find.byKey(const Key('profile-nickname')), nickname);
    await tester.pump();
    await tapKey(tester, 'year-$year');
    await tapKey(tester, 'avatar-$avatar');
    await tapKey(tester, 'setup-save-child');
  }

  /// Child rows with a name.
  Future<List<ChildRow>> named() async => [
    for (final c in await db.select(db.children).get())
      if (c.nickname.isNotEmpty) c,
  ];

  /// A setup already past the PIN, at [step].
  Future<void> pastPin(SetupStep step) async {
    await pins().setPin('2468');
    await setup.advance(step);
  }
}

/// Another tablet of the family that already synced [names] to [server];
/// the last child's limit is [lastLimit] (AC-3).
Future<void> familyOnServer(
  FakeSyncServer server,
  List<String> names, {
  int lastLimit = 45,
}) async {
  final db = AppDatabase(NativeDatabase.memory());
  DateTime clock() => DateTime(2027, 1, 4, 9);
  final kids = ChildRepository(db, clock: clock);
  var id = 1;
  for (final (i, n) in names.indexed) {
    final p = ChildProfile(nickname: n, schoolYear: 2, avatar: 'fox');
    if (i == 0) {
      await ProfileRepository(db, clock: clock).save(p);
    } else {
      id = await kids.add(p);
    }
  }
  await UsageRepository(db, clock: clock, childId: id).setDailyLimit(lastLimit);
  await SyncService(
    db: db,
    client: FakeServerClient(
      setupServer,
      stored: const Account(id: 'u1', email: 'parent@example.test'),
      server: server,
    ),
    clock: clock,
    forgetSession: () {},
  ).run();
  await db.close();
}
