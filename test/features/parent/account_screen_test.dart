import 'package:flutter_test/flutter_test.dart';
import 'package:material_ui/material_ui.dart';
import 'package:number_ninja/app.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/features/parent/account_screen.dart';
import 'package:number_ninja/features/parent/pin_entry_screen.dart';
import 'package:number_ninja/providers.dart';

import '../../data/fake_server_client.dart';
import '../../ui/layout_checks.dart';
import 'parent_harness.dart';

class FakeBrowser extends SignInBrowser {
  final opened = <Uri>[];
  int closed = 0;

  @override
  Future<Uri> open(Uri url) async {
    opened.add(url);
    return Uri.parse('brainbubblz://signin/google?state=s&code=c');
  }

  @override
  Future<void> close() async => closed++;
}

const email = 'parent@example.test';
const password = 'long-enough-1';
final configured = ServerConfig.parse('https://api.example.test');

/// FEAT-13 AC-4: SCR-13 with a fake server client.
void main() {
  late ParentHarness h;
  late FakeServerClient client;
  late FakeBrowser browser;

  String? textOf(WidgetTester tester, String key) =>
      tester.widget<Text>(find.byKey(Key(key))).data;

  Future<void> open(
    WidgetTester tester, {
    ServerConfig? config,
    Account? stored,
    bool google = false,
    Size? size,
  }) async {
    client = FakeServerClient(
      config ?? configured,
      stored: stored,
      google: google,
    );
    browser = FakeBrowser();
    h.more = [
      ...h.more,
      serverClientProvider.overrideWithValue(client),
      signInBrowserProvider.overrideWithValue(browser),
    ];
    await h.openParent(tester, Routes.account, size: size);
  }

  Future<void> fill(WidgetTester tester, String e, String p) async {
    await tester.enterText(find.byKey(const Key('account-email')), e);
    await tester.enterText(find.byKey(const Key('account-password')), p);
    await tester.pumpAndSettle();
  }

  Future<int> rounds() async => (await h.db.select(h.db.rounds).get()).length;

  setUp(() async {
    h = ParentHarness();
    await h.setUp();
    await h.seed('p2-add-3digit', [(1, true), (2, false)]);
  });
  tearDown(() => h.db.close());

  testWidgets('without the PIN session, /parent/account asks for the PIN', (
    tester,
  ) async {
    client = FakeServerClient(configured);
    h.more = [...h.more, serverClientProvider.overrideWithValue(client)];
    await h.pumpApp(tester, location: Routes.account);
    expect(find.byType(PinEntryScreen), findsOneWidget);
    expect(find.byType(AccountScreen), findsNothing);
  });

  testWidgets('SCR-11 row shows "Not signed in" and opens SCR-13', (
    tester,
  ) async {
    client = FakeServerClient(configured);
    h.more = [...h.more, serverClientProvider.overrideWithValue(client)];
    await h.openParent(tester, Routes.parent);
    await h.tapKey(tester, 'account-row');
    expect(find.byType(AccountScreen), findsOneWidget);
  });

  testWidgets('create account shows the inbox text', (tester) async {
    await open(tester);
    await fill(tester, email, password);
    await h.tapKey(tester, 'account-create');
    expect(client.log, contains('signUp:$email'));
    expect(
      textOf(tester, 'account-message'),
      'Check your inbox and tap the link, then sign in.',
    );
  });

  testWidgets('unverified sign-in asks to verify; Resend sends again', (
    tester,
  ) async {
    await open(tester);
    client.unverified.add(email);
    await fill(tester, email, password);
    await h.tapKey(tester, 'account-signin');
    expect(
      textOf(tester, 'account-message'),
      'Please verify your email first.',
    );
    await h.tapKey(tester, 'account-resend');
    expect(client.log, contains('requestVerification:$email'));
    expect(find.byKey(const Key('account-signout')), findsNothing);
  });

  testWidgets('sign in shows the account and the SCR-11 row', (tester) async {
    await open(tester);
    await fill(tester, email, password);
    await h.tapKey(tester, 'account-signin');
    expect(textOf(tester, 'account-email-shown'), email);
    await h.tapKey(tester, 'back-parent');
    await tester.scrollUntilVisible(
      find.byKey(const Key('account-row-subtitle')),
      200,
      scrollable: find.byType(Scrollable).first,
    );
    expect(textOf(tester, 'account-row-subtitle'), email);
  });

  final errors = {
    AuthError.offline:
        "Can't reach the server. Check the internet and try again.",
    AuthError.wrongCredentials: 'Email or password is wrong.',
    AuthError.emailTaken: 'That email already has an account. Sign in instead.',
    AuthError.weakPassword: 'Use at least 8 characters.',
    AuthError.tooManyTries: 'Too many tries. Wait a minute and try again.',
    AuthError.unknown: 'Something went wrong. Try again.',
  };
  for (final MapEntry(key: error, value: message) in errors.entries) {
    testWidgets('$error shows its text', (tester) async {
      await open(tester);
      await fill(tester, email, password);
      client.fail = error;
      await h.tapKey(tester, 'account-create');
      expect(textOf(tester, 'account-message'), message);
    });
  }

  testWidgets('client-side checks: bad email, short password, no request', (
    tester,
  ) async {
    await open(tester);
    await fill(tester, 'nope', password);
    await h.tapKey(tester, 'account-create');
    expect(textOf(tester, 'account-message'), 'Enter a valid email address.');
    await fill(tester, email, '1234567');
    await h.tapKey(tester, 'account-create');
    expect(textOf(tester, 'account-message'), 'Use at least 8 characters.');
    expect(client.log.where((l) => l.startsWith('signUp')), isEmpty);
  });

  testWidgets('forgot password always shows the neutral text', (tester) async {
    await open(tester);
    await fill(tester, 'nobody@example.test', '');
    client.fail = AuthError.unknown;
    await h.tapKey(tester, 'account-forgot');
    expect(
      textOf(tester, 'account-message'),
      'If that email has an account, a reset link is on its way.',
    );
  });

  testWidgets('Google is hidden when the server does not offer it', (
    tester,
  ) async {
    await open(tester);
    expect(find.byKey(const Key('account-google')), findsNothing);
  });

  testWidgets('Google sign-in opens the browser and signs in', (tester) async {
    await open(tester, google: true);
    await h.tapKey(tester, 'account-google');
    expect(client.log, contains('google'));
    expect(browser.opened, hasLength(1));
    expect(browser.closed, 1);
    expect(find.text('Signed in with Google'), findsOneWidget);
  });

  testWidgets('Google cancelled shows its text', (tester) async {
    await open(tester, google: true);
    client.fail = AuthError.cancelled;
    await h.tapKey(tester, 'account-google');
    expect(textOf(tester, 'account-message'), "Google sign-in didn't finish.");
  });

  group('signed in', () {
    const account = Account(id: 'u1', email: email);

    testWidgets('opening while signed in refreshes once', (tester) async {
      await open(tester, stored: account);
      expect(client.log.where((l) => l == 'refresh'), hasLength(1));
    });

    testWidgets('expired session on open: back to the form', (tester) async {
      client = FakeServerClient(configured, stored: account)
        ..fail = AuthError.expired;
      h.more = [...h.more, serverClientProvider.overrideWithValue(client)];
      await h.openParent(tester, Routes.account);
      expect(textOf(tester, 'account-message'), 'Please sign in again.');
      expect(find.byKey(const Key('account-signin')), findsOneWidget);
    });

    testWidgets('offline on open stays signed in', (tester) async {
      client = FakeServerClient(configured, stored: account)
        ..fail = AuthError.offline;
      h.more = [...h.more, serverClientProvider.overrideWithValue(client)];
      await h.openParent(tester, Routes.account);
      expect(find.byKey(const Key('account-signout')), findsOneWidget);
    });

    testWidgets('sign out returns to the form and keeps local rounds', (
      tester,
    ) async {
      await open(tester, stored: account);
      final before = await rounds();
      await h.tapKey(tester, 'account-signout');
      expect(find.byKey(const Key('account-signin')), findsOneWidget);
      expect(client.stored, isNull);
      expect(await rounds(), before);
      expect(before, greaterThan(0));
    });

    testWidgets('delete: a wrong PIN makes no call', (tester) async {
      await open(tester, stored: account);
      await h.tapKey(tester, 'account-delete');
      await h.tapKey(tester, 'account-delete-confirm');
      await h.enterPin(tester, '1111');
      await tester.pumpAndSettle();
      expect(textOf(tester, 'account-pin-message'), contains('Wrong PIN'));
      expect(client.log, isNot(contains('delete')));
    });

    testWidgets('delete: the right PIN deletes, signs out, keeps rounds', (
      tester,
    ) async {
      await open(tester, stored: account);
      final before = await rounds();
      await h.tapKey(tester, 'account-delete');
      await h.tapKey(tester, 'account-delete-confirm');
      await h.enterPin(tester, parentPin);
      await tester.pumpAndSettle();
      expect(client.log, contains('delete'));
      expect(find.byKey(const Key('account-signin')), findsOneWidget);
      expect(
        textOf(tester, 'account-message'),
        'The account is deleted. Progress on this tablet stays.',
      );
      expect(await rounds(), before);
    });

    testWidgets('delete offline: still signed in, message shown', (
      tester,
    ) async {
      await open(tester, stored: account);
      await h.tapKey(tester, 'account-delete');
      await h.tapKey(tester, 'account-delete-confirm');
      client.fail = AuthError.offline;
      await h.enterPin(tester, parentPin);
      await tester.pumpAndSettle();
      expect(find.byKey(const Key('account-signout')), findsOneWidget);
      expect(
        textOf(tester, 'account-message'),
        "Can't reach the server. Check the internet and try again.",
      );
    });

    testWidgets('delete can be cancelled in the dialog', (tester) async {
      await open(tester, stored: account);
      await h.tapKey(tester, 'account-delete');
      await h.tapKey(tester, 'account-delete-cancel');
      expect(find.byKey(const Key('account-signout')), findsOneWidget);
      expect(client.log, isNot(contains('delete')));
    });
  });

  testWidgets('privacy note is always shown', (tester) async {
    await open(tester);
    expect(textOf(tester, 'account-privacy'), privacyNote);
  });

  testWidgets('a build without a server shows no form', (tester) async {
    await open(tester, config: ServerConfig.none);
    expect(
      textOf(tester, 'account-message'),
      "Accounts aren't set up in this build.",
    );
    expect(find.byKey(const Key('account-email')), findsNothing);
    expect(client.log, isEmpty);
  });

  for (final dp in [...layoutSizes, scaledSize]) {
    final scale = dp == scaledSize ? scaledText : 1.0;
    for (final signedIn in [false, true]) {
      testWidgets(
        'layout ${dp.width.toInt()} × ${dp.height.toInt()} at text scale '
        '$scale, ${signedIn ? 'signed in' : 'signed out'}',
        (tester) async {
          if (scale != 1) setTextScale(tester, scale);
          await open(
            tester,
            size: physical(dp),
            google: true,
            stored: signedIn ? const Account(id: 'u1', email: email) : null,
          );
          expect(tester.takeException(), isNull);
          if (signedIn) {
            expectNoOverlap(tester, [
              'account-last-sync',
              'account-sync-now',
              'account-signout',
              'account-delete',
            ]);
          } else {
            expectNoOverlap(tester, [
              'account-email',
              'account-password',
              'account-signin',
              'account-create',
              'account-forgot',
            ]);
          }
        },
      );
    }
  }
}
