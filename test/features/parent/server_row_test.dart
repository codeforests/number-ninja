import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/providers.dart';

import '../../data/fake_server_client.dart';
import '../../ui/layout_checks.dart';
import 'parent_harness.dart';

String? textOf(WidgetTester tester, String key) =>
    tester.widget<Text>(find.byKey(Key(key))).data;

/// FEAT-12 AC-5: the "Server" row on SCR-11 with a fake client.
void main() {
  late ParentHarness h;
  late FakeServerClient client;

  Future<void> open(
    WidgetTester tester,
    ServerConfig config, {
    Size? size,
  }) async {
    client = FakeServerClient(config);
    h.more = [...h.more, serverClientProvider.overrideWithValue(client)];
    await h.openParent(tester, Routes.parent, size: size);
    await tester.scrollUntilVisible(
      find.byKey(const Key('server-row')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    await tester.pumpAndSettle();
  }

  final configured = ServerConfig.parse('https://api.example.test');

  setUp(() async {
    h = ParentHarness();
    await h.setUp();
  });
  tearDown(() => h.db.close());

  testWidgets('not set up: says so, no Check button, no network call', (
    tester,
  ) async {
    await open(tester, ServerConfig.none);
    expect(textOf(tester, 'server-host'), 'Not set up');
    expect(find.byKey(const Key('server-check')), findsNothing);
    expect(client.calls, 0);
  });

  testWidgets('configured: says set up, never the address, and calls only '
      'on Check', (tester) async {
    await open(tester, configured);
    expect(textOf(tester, 'server-host'), 'Set up');
    expect(find.textContaining('example.test'), findsNothing);
    expect(client.calls, 0);
    await h.tapKey(tester, 'server-check');
    expect(client.calls, 1);
    expect(textOf(tester, 'server-status'), 'Connected');
  });

  testWidgets('unreachable: the offline text', (tester) async {
    await open(tester, configured);
    client.result = ServerHealth.unreachable;
    await h.tapKey(tester, 'server-check');
    expect(
      textOf(tester, 'server-status'),
      "Can't reach the server. Practice still works offline.",
    );
  });

  for (final dp in [...layoutSizes, scaledSize]) {
    final scale = dp == scaledSize ? scaledText : 1.0;
    testWidgets(
      'layout ${dp.width.toInt()} × ${dp.height.toInt()} at text scale $scale',
      (tester) async {
        if (scale != 1) setTextScale(tester, scale);
        await open(tester, configured, size: physical(dp));
        client.result = ServerHealth.unreachable;
        await h.tapKey(tester, 'server-check');
        expect(tester.takeException(), isNull);
        expectNoOverlap(tester, ['server-host', 'server-check']);
        expectNoOverlap(tester, ['server-row', 'server-status']);
      },
    );
  }
}
