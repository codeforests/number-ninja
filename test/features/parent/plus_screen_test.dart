import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/purchase_service.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/domain/plus.dart';
import 'package:number_ninja/features/parent/account_screen.dart';
import 'package:number_ninja/features/parent/plus_screen.dart';
import 'package:number_ninja/providers.dart';

import '../../data/fake_server_client.dart';
import 'parent_harness.dart';

final _configured = ServerConfig.parse('https://api.example.test');

/// A store that sells one offer and records each buy (AC-7).
class _FakeStore implements PurchaseService {
  final bought = <String>[];

  @override
  bool get available => true;

  @override
  Future<List<PlusOffer>> offers() async => const [
    PlusOffer(id: 'yearly', title: 'Plus for a year', price: r'S$48'),
  ];

  @override
  Future<PurchaseOutcome> buy(PlusOffer offer) async {
    bought.add(offer.id);
    return PurchaseOutcome.bought;
  }

  @override
  Future<void> restore() async {}

  @override
  Uri? get manageUrl => null;
}

/// FEAT-30 SCR-20 (AC-6, AC-7).
void main() {
  late ParentHarness h;
  late FakeServerClient client;

  setUp(() async {
    h = ParentHarness();
    await h.setUp();
  });
  tearDown(() => h.db.close());

  String? textOf(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data;

  Entitlement ent({
    DateTime? until,
    String source = 'complimentary',
    String status = 'active',
    bool willRenew = false,
  }) => Entitlement(
    plus: true,
    until: (until ?? DateTime(2099, 12, 31, 23, 59)).toUtc(),
    source: source,
    status: status,
    willRenew: willRenew,
    checkedAt: h.now.toUtc(),
  );

  Future<void> open(
    WidgetTester tester, {
    bool signedIn = true,
    Entitlement? plus,
    PurchaseService? store,
    String location = Routes.plus,
  }) async {
    client = FakeServerClient(
      _configured,
      stored: signedIn ? const Account(id: 'u1', email: 'p@x.co') : null,
    )..plus = plus;
    h.plus = plus != null;
    h.more = [
      ...h.more,
      serverClientProvider.overrideWithValue(client),
      if (store != null) purchaseServiceProvider.overrideWithValue(store),
    ];
    await h.openParent(tester, location);
  }

  testWidgets('signed out: Sign in opens SCR-13', (tester) async {
    await open(tester, signedIn: false);
    expect(textOf(tester, 'plus-status'), 'Sign in to use Plus.');
    expect(find.byKey(const Key('plus-check')), findsNothing);
    await h.tapKey(tester, 'plus-sign-in');
    expect(find.byType(AccountScreen), findsOneWidget);
  });

  testWidgets('free: coming soon, no buy button (AC-7)', (tester) async {
    await open(tester);
    expect(textOf(tester, 'plus-status'), 'You are on the free plan.');
    expect(find.byKey(const Key('plus-coming-soon')), findsOneWidget);
    expect(find.byType(FilledButton), findsNothing);
  });

  testWidgets('complimentary forever', (tester) async {
    await open(tester, plus: ent());
    expect(textOf(tester, 'plus-status'), 'Plus, a gift from BrainBubblz');
    expect(find.byKey(const Key('plus-coming-soon')), findsNothing);
  });

  testWidgets('store renewing, ending and billing issue', (tester) async {
    final until = DateTime(2027, 3, 1, 12);
    await open(
      tester,
      plus: ent(until: until, source: 'google_play', willRenew: true),
    );
    expect(textOf(tester, 'plus-status'), 'Plus, renews on 1 Mar 2027');

    client.plus = ent(until: until, source: 'google_play', status: 'cancelled');
    await h.tapKey(tester, 'plus-check');
    expect(textOf(tester, 'plus-status'), 'Plus, ends on 1 Mar 2027');

    client.plus = ent(
      until: until,
      source: 'app_store',
      status: 'billing_issue',
    );
    await h.tapKey(tester, 'plus-check');
    expect(
      textOf(tester, 'plus-status'),
      'Plus: payment problem, check your store account',
    );
  });

  testWidgets('offline grace says when it last checked', (tester) async {
    await open(tester, plus: ent());
    expect(find.byKey(const Key('plus-checked')), findsNothing);
    h.tick(const Duration(days: 3, hours: 1));
    client.entitlementFail = const SyncException(SyncError.offline);
    await h.tapKey(tester, 'plus-check');
    expect(textOf(tester, 'plus-status'), 'Plus, a gift from BrainBubblz');
    expect(textOf(tester, 'plus-checked'), 'Last checked 3 days ago');
  });

  testWidgets('check again refreshes', (tester) async {
    await open(tester);
    final calls = client.entitlementCalls;
    client.plus = ent();
    await h.tapKey(tester, 'plus-check');
    expect(client.entitlementCalls, calls + 1);
    expect(textOf(tester, 'plus-status'), 'Plus, a gift from BrainBubblz');
  });

  testWidgets('reached from SCR-11 and a Plus card', (tester) async {
    await open(tester, location: Routes.parent);
    await h.tapKey(tester, 'open-plus');
    expect(find.byType(PlusScreen), findsOneWidget);
    h.setPlus(tester, false);
    h.container(tester).read(routerProvider).go(Routes.dayToday);
    await tester.pumpAndSettle();
    await h.tapKey(tester, 'plus-card-${PlusFeature.dayView.name}');
    expect(find.byType(PlusScreen), findsOneWidget);
  });

  testWidgets('only inside the PIN area', (tester) async {
    await h.pumpApp(tester);
    h.container(tester).read(routerProvider).go(Routes.plus);
    await tester.pumpAndSettle();
    expect(find.byType(PlusScreen), findsNothing);
    expect(find.byKey(const Key('pin-1')), findsOneWidget);
  });

  testWidgets('a store offer is listed and bought (AC-7)', (tester) async {
    final store = _FakeStore();
    await open(tester, store: store);
    expect(find.byKey(const Key('plus-coming-soon')), findsNothing);
    await h.tapKey(tester, 'plus-buy-yearly');
    expect(store.bought, ['yearly']);
  });
}
