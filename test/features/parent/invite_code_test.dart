import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/domain/plus.dart';
import 'package:number_ninja/features/parent/plus_screen.dart';
import 'package:number_ninja/providers.dart';

import '../../data/fake_server_client.dart';
import 'parent_harness.dart';

final _configured = ServerConfig.parse('https://api.example.test');

/// FEAT-36 SCR-20 "Have an invitation code?" (AC-7, AC-8).
void main() {
  late ParentHarness h;
  late FakeServerClient client;

  setUp(() async {
    h = ParentHarness();
    await h.setUp();
  });
  tearDown(() => h.db.close());

  Entitlement ent(String source, {DateTime? until}) => Entitlement(
    plus: true,
    until: (until ?? DateTime(2099, 12, 31, 23, 59)).toUtc(),
    source: source,
    status: 'active',
    checkedAt: h.now.toUtc(),
  );

  Future<void> open(
    WidgetTester tester, {
    bool signedIn = true,
    Entitlement? plus,
    bool allowed = true,
  }) async {
    client = FakeServerClient(
      _configured,
      stored: signedIn ? const Account(id: 'u1', email: 'p@x.co') : null,
    )..plus = plus;
    h.realPlus = true;
    h.more = [
      ...h.more,
      serverClientProvider.overrideWithValue(client),
      inviteCodesAllowedProvider.overrideWithValue(allowed),
    ];
    await h.openParent(tester, Routes.plus);
    await h.container(tester).read(plusControllerProvider.notifier).idle;
    await tester.pumpAndSettle();
  }

  Finder row(String text) => find.descendant(
    of: find.byKey(const Key('plus-invite')),
    matching: find.text(text),
  );

  bool useEnabled(WidgetTester tester) =>
      tester.widget<FilledButton>(find.byKey(const Key('invite-use'))).enabled;

  Future<void> type(WidgetTester tester, String code) async {
    await tester.enterText(find.byKey(const Key('invite-field')), code);
    await tester.pump();
  }

  testWidgets('free: redeem a code, Plus features open (AC-7)', (tester) async {
    await open(tester);
    expect(row('Have an invitation code?'), findsOneWidget);
    expect(h.container(tester).read(plusProvider), isFalse);
    await h.tapKey(tester, 'plus-invite');

    expect(useEnabled(tester), isFalse);
    await type(tester, 'abcd-efg');
    expect(useEnabled(tester), isFalse);
    await type(tester, 'abcd-efgO');
    expect(useEnabled(tester), isFalse, reason: 'O is not a code character');
    await type(tester, 'abcd efgh');
    expect(useEnabled(tester), isTrue);

    final until = DateTime(2027, 11, 20, 12);
    client.inviteResult = InviteResult.ok(ent('invite', until: until));
    await tester.tap(find.byKey(const Key('invite-use')));
    await tester.pumpAndSettle();
    expect(client.redeemCalls, ['ABCDEFGH']);
    expect(find.byKey(const Key('invite-field')), findsNothing);
    expect(
      find.text('Plus until 20 Nov 2027, from an invitation. Enjoy!'),
      findsOneWidget,
    );
    expect(
      tester.widget<Text>(find.byKey(const Key('plus-status'))).data,
      'Plus until 20 Nov 2027, from an invitation',
    );
    expect(row('Have another invitation code?'), findsOneWidget);
    expect(h.container(tester).read(plusProvider), isTrue);

    h.container(tester).read(routerProvider).go(Routes.dayToday);
    await tester.pumpAndSettle();
    expect(
      find.byKey(Key('plus-card-${PlusFeature.dayView.name}')),
      findsNothing,
    );
  });

  testWidgets('each refusal shows its line and keeps the dialog (AC-7)', (
    tester,
  ) async {
    await open(tester);
    await h.tapKey(tester, 'plus-invite');
    await type(tester, 'ABCDEFGH');
    for (final f in InviteFailure.values) {
      client.inviteResult = InviteResult.failed(f);
      await tester.tap(find.byKey(const Key('invite-use')));
      await tester.pumpAndSettle();
      expect(
        tester.widget<Text>(find.byKey(const Key('invite-error'))).data,
        inviteFailureText[f],
        reason: '$f',
      );
      expect(find.byKey(const Key('invite-field')), findsOneWidget);
    }
    expect(inviteFailureText.keys, InviteFailure.values);
    expect(
      inviteFailureText[InviteFailure.notFound],
      "We couldn't find that code. Check the letters and try again.",
    );
    await tester.tap(find.byKey(const Key('invite-cancel')));
    await tester.pumpAndSettle();
    expect(find.byKey(const Key('invite-field')), findsNothing);
    expect(row('Have an invitation code?'), findsOneWidget);
  });

  testWidgets('no row signed out (AC-7)', (tester) async {
    await open(tester, signedIn: false);
    expect(find.byKey(const Key('plus-invite')), findsNothing);
  });

  testWidgets('no row with complimentary Plus (AC-7)', (tester) async {
    await open(tester, plus: ent('complimentary'));
    expect(find.byKey(const Key('plus-status')), findsOneWidget);
    expect(find.byKey(const Key('plus-invite')), findsNothing);
  });

  testWidgets('invite Plus: "Have another invitation code?" (AC-7)', (
    tester,
  ) async {
    await open(tester, plus: ent('invite', until: DateTime(2027, 6, 1, 12)));
    expect(row('Have another invitation code?'), findsOneWidget);
  });

  testWidgets('iOS: no row, signed in and free (AC-8)', (tester) async {
    await open(tester, allowed: false);
    expect(
      tester.widget<Text>(find.byKey(const Key('plus-status'))).data,
      'You are on the free plan.',
    );
    expect(find.byKey(const Key('plus-invite')), findsNothing);
  });
}
