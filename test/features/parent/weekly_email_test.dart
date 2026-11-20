import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/features/parent/plus_screen.dart';
import 'package:number_ninja/providers.dart';

import '../../data/fake_server_client.dart';
import '../../data/sync/fake_sync_timers.dart';
import 'parent_harness.dart';

final configured = ServerConfig.parse('https://api.example.test');
const account = Account(id: 'u1', email: 'parent@example.test');

/// FEAT-31 AC-8 (WEM-01, WE-12..14): the SCR-13 weekly email switch.
void main() {
  late ParentHarness h;
  late FakeServerClient client;

  void signIn({int tz = 480}) {
    client = FakeServerClient(configured, stored: account);
    h.more = [
      ...h.more,
      serverConfigProvider.overrideWithValue(configured),
      serverClientProvider.overrideWithValue(client),
      syncTimersProvider.overrideWithValue(FakeSyncTimers()),
      tzOffsetProvider.overrideWithValue(Duration(minutes: tz)),
    ];
  }

  Future<void> open(WidgetTester tester) async {
    await h.openParent(tester, Routes.account);
    await tester.pumpAndSettle();
    await tester.ensureVisible(find.byKey(const Key('weekly-email')));
    await tester.pumpAndSettle();
  }

  SwitchListTile tile(WidgetTester tester) =>
      tester.widget<SwitchListTile>(find.byKey(const Key('weekly-email')));

  String? note(WidgetTester tester) =>
      tester.widget<Text>(find.byKey(const Key('weekly-email-note'))).data;

  setUp(() async {
    h = ParentHarness();
    await h.setUp();
  });
  tearDown(() => h.db.close());

  testWidgets('Plus and verified: shows the server value; on writes the '
      "device's offset, off writes off", (tester) async {
    signIn(tz: 330);
    client.weeklyEmailSetting = const WeeklyEmailSetting(
      on: false,
      tzMinutes: 480,
    );
    await open(tester);
    expect(tile(tester).value, isFalse);
    expect(tile(tester).onChanged, isNotNull);
    expect(note(tester), contains('sent to parent@example.test'));

    await tester.tap(find.byKey(const Key('weekly-email')));
    await tester.pumpAndSettle();
    expect(client.weeklyEmailWrites, [(true, 330)]);
    expect(tile(tester).value, isTrue);

    await tester.tap(find.byKey(const Key('weekly-email')));
    await tester.pumpAndSettle();
    expect(client.weeklyEmailWrites.last, (false, null));
    expect(tile(tester).value, isFalse);
  });

  testWidgets('a failed write puts the switch back and says why', (
    tester,
  ) async {
    signIn();
    await open(tester);
    client.weeklyEmailFail = const SyncException(SyncError.offline);
    await tester.tap(find.byKey(const Key('weekly-email')));
    await tester.pumpAndSettle();
    expect(tile(tester).value, isFalse);
    expect(
      find.text("Couldn't reach BrainBubblz. Try again when online."),
      findsOneWidget,
    );
  });

  testWidgets('switch on with another offset: opening SCR-13 updates it', (
    tester,
  ) async {
    signIn(tz: 480);
    client.weeklyEmailSetting = const WeeklyEmailSetting(
      on: true,
      tzMinutes: -300,
    );
    await open(tester);
    expect(tile(tester).value, isTrue);
    expect(client.weeklyEmailWrites, [(true, 480)]);
  });

  testWidgets('same offset: nothing is written on open', (tester) async {
    signIn(tz: 480);
    client.weeklyEmailSetting = const WeeklyEmailSetting(
      on: true,
      tzMinutes: 480,
    );
    await open(tester);
    expect(client.weeklyEmailWrites, isEmpty);
  });

  testWidgets('unverified: off and disabled, with the reason', (tester) async {
    signIn();
    client.weeklyEmailSetting = const WeeklyEmailSetting(
      on: true,
      tzMinutes: 480,
      verified: false,
    );
    await open(tester);
    expect(tile(tester).value, isFalse);
    expect(tile(tester).onChanged, isNull);
    expect(note(tester), 'Verify your email first to get weekly emails.');
  });

  testWidgets('no Plus: off and disabled, with a Plus card', (tester) async {
    h.plus = false;
    signIn();
    client.weeklyEmailSetting = const WeeklyEmailSetting(
      on: true,
      tzMinutes: 480,
    );
    await open(tester);
    expect(tile(tester).value, isFalse);
    expect(tile(tester).onChanged, isNull);
    expect(find.byKey(const Key('plus-card-weeklyEmail')), findsOneWidget);
    expect(client.weeklyEmailWrites, isEmpty);
  });

  testWidgets('offline: disabled, asks for the internet', (tester) async {
    signIn();
    client.weeklyEmailFail = const SyncException(SyncError.offline);
    await open(tester);
    expect(tile(tester).onChanged, isNull);
    expect(note(tester), 'Connect to the internet to change this.');
  });

  test('SCR-20 lists the weekly email (WE-14)', () {
    expect(plusAdds, contains('A weekly progress email'));
  });
}
