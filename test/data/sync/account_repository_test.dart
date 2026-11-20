import 'dart:async';
import 'dart:convert';
import 'dart:io';

import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:number_ninja/data/sync/account_repository.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/data/sync/token_store.dart';
import 'package:number_ninja/providers.dart';

import '../fake_server_client.dart';

const password = 'secret-pass-123';
final config = ServerConfig.parse('https://api.example.test');

Map<String, dynamic> record({bool verified = true}) => {
  'id': 'u1',
  'collectionId': '_pb_users_auth_',
  'collectionName': 'users',
  'email': 'parent@example.test',
  'verified': verified,
};

/// A PocketBase stand-in: [handler] answers by path; every request is kept.
class MockServer {
  MockServer(this.handler);

  http.Response Function(http.Request request) handler;
  final requests = <http.Request>[];

  http.Client client() => MockClient((request) async {
    requests.add(request);
    return handler(request);
  });
}

http.Response json(int status, Object body) => http.Response(
  jsonEncode(body),
  status,
  headers: {'content-type': 'application/json'},
);

/// A JWT the SDK accepts as unexpired (it checks `exp` locally).
final token = [
  base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}')),
  base64Url.encode(utf8.encode('{"id":"u1","exp":4102444800}')),
  'sig',
].join('.').replaceAll('=', '');

http.Response authOk(http.Request _) =>
    json(200, {'token': token, 'record': record()});

void main() {
  group('PocketBaseServerClient session (AC-1)', () {
    late MemoryTokenStore store;
    late MockServer server;
    PocketBaseServerClient client() => PocketBaseServerClient(
      config,
      store: store,
      httpClientFactory: server.client,
    );

    setUp(() {
      store = MemoryTokenStore();
      server = MockServer(authOk);
    });

    test('sign-in stores the token, never the password', () async {
      final c = client();
      final account = await c.signIn('parent@example.test', password);
      expect(account.email, 'parent@example.test');
      expect(store.value, contains(token));
      expect(store.value, isNot(contains(password)));
      expect(c.currentAccount.toString(), isNot(contains(password)));
    });

    test('a new client over the same store is signed in offline', () async {
      await client().signIn('parent@example.test', password);
      server.requests.clear();
      final again = client();
      final account = await again.loadSession();
      expect(account?.email, 'parent@example.test');
      expect(server.requests, isEmpty);
    });

    test('an unverified sign-in keeps nothing', () async {
      server.handler = (_) =>
          json(200, {'token': token, 'record': record(verified: false)});
      final c = client();
      await expectLater(
        c.signIn('parent@example.test', password),
        throwsA(
          isA<AuthException>().having(
            (e) => e.error,
            'error',
            AuthError.notVerified,
          ),
        ),
      );
      expect(store.value, isNull);
      expect(c.currentAccount, isNull);
    });

    test('refresh 401 signs out (expired)', () async {
      await client().signIn('parent@example.test', password);
      server.handler = (_) => json(401, {'status': 401, 'message': 'no'});
      final c = client();
      await expectLater(
        c.refresh(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.error,
            'error',
            AuthError.expired,
          ),
        ),
      );
      expect(store.value, isNull);
      expect(c.currentAccount, isNull);
    });

    test('refresh offline keeps the session', () async {
      await client().signIn('parent@example.test', password);
      server.handler = (_) => throw const SocketException('no network');
      final c = client();
      await expectLater(
        c.refresh(),
        throwsA(
          isA<AuthException>().having(
            (e) => e.error,
            'error',
            AuthError.offline,
          ),
        ),
      );
      expect(store.value, isNotNull);
      expect(c.currentAccount, isNotNull);
    });

    test('errors map to AuthError', () async {
      Future<AuthError> errorOf(
        http.Response response,
        Future<void> Function(PocketBaseServerClient) call,
      ) async {
        server.handler = (_) => response;
        try {
          await call(client());
        } on AuthException catch (e) {
          return e.error;
        }
        fail('no error');
      }

      expect(
        await errorOf(
          json(400, {'status': 400, 'message': 'Failed', 'data': {}}),
          (c) => c.signIn('a@b.co', password),
        ),
        AuthError.wrongCredentials,
      );
      expect(
        await errorOf(
          json(400, {
            'status': 400,
            'data': {
              'email': {'code': 'validation_not_unique', 'message': 'x'},
            },
          }),
          (c) => c.signUp('a@b.co', password),
        ),
        AuthError.emailTaken,
      );
      expect(
        await errorOf(
          json(400, {
            'status': 400,
            'data': {
              'password': {'code': 'validation_min_text_constraint'},
            },
          }),
          (c) => c.signUp('a@b.co', 'short'),
        ),
        AuthError.weakPassword,
      );
      expect(
        await errorOf(
          json(429, {'status': 429}),
          (c) => c.signIn('a@b.co', password),
        ),
        AuthError.tooManyTries,
      );
    });

    test('no server URL: notConfigured, no request', () async {
      final c = PocketBaseServerClient(
        ServerConfig.none,
        store: store,
        httpClientFactory: server.client,
      );
      expect(await c.loadSession(), isNull);
      await expectLater(
        c.signIn('a@b.co', password),
        throwsA(
          isA<AuthException>().having(
            (e) => e.error,
            'error',
            AuthError.notConfigured,
          ),
        ),
      );
      expect(server.requests, isEmpty);
    });
  });

  group('Google sign-in returns through the app link', () {
    late MemoryTokenStore store;
    late MockServer server;
    const authUrl =
        'https://accounts.google.com/o/oauth2/auth?client_id=cid'
        '&response_type=code&scope=openid&state=st1&redirect_uri=';

    http.Response handler(http.Request r) {
      if (r.url.path.endsWith('/auth-methods')) {
        return json(200, {
          'password': {'enabled': true},
          'oauth2': {
            'enabled': true,
            'providers': [
              {
                'name': 'google',
                'displayName': 'Google',
                'state': 'st1',
                'authURL': authUrl,
                'codeVerifier': 'cv1',
                'codeChallenge': 'cc1',
                'codeChallengeMethod': 'S256',
              },
            ],
          },
        });
      }
      if (r.url.path.endsWith('/auth-with-oauth2')) return authOk(r);
      return json(404, {});
    }

    PocketBaseServerClient client() => PocketBaseServerClient(
      config,
      store: store,
      httpClientFactory: server.client,
    );

    setUp(() {
      store = MemoryTokenStore();
      server = MockServer(handler);
    });

    test('opens Google with the app return page, then signs in with the '
        'code (no realtime connection)', () async {
      Uri? opened;
      final account = await client().signInWithGoogle((url) async {
        opened = url;
        return Uri.parse('brainbubblz://signin/google?state=st1&code=4%2F0Ab');
      });
      expect(account.viaGoogle, isTrue);
      expect(opened!.host, 'accounts.google.com');
      expect(
        opened!.queryParameters['redirect_uri'],
        'https://api.example.test/signin/google',
      );
      expect(opened!.queryParameters['state'], 'st1');
      expect(
        server.requests.where((r) => r.url.path.contains('realtime')),
        isEmpty,
      );
      final body = jsonDecode(
        server.requests
            .lastWhere((r) => r.url.path.endsWith('/auth-with-oauth2'))
            .body,
      ) as Map<String, dynamic>;
      expect(body['provider'], 'google');
      expect(body['code'], '4/0Ab');
      expect(body['codeVerifier'], 'cv1');
      expect(body['redirectURL'], 'https://api.example.test/signin/google');
      expect(store.value, contains(token));
    });

    for (final (name, link) in [
      ('another state', 'brainbubblz://signin/google?state=other&code=x'),
      ('an error', 'brainbubblz://signin/google?state=st1&error=access_denied'),
      ('no code', 'brainbubblz://signin/google?state=st1'),
    ]) {
      test('$name: cancelled, nothing kept', () async {
        await expectLater(
          client().signInWithGoogle((_) async => Uri.parse(link)),
          throwsA(
            isA<AuthException>().having(
              (e) => e.error,
              'error',
              AuthError.cancelled,
            ),
          ),
        );
        expect(
          server.requests.where(
            (r) => r.url.path.endsWith('/auth-with-oauth2'),
          ),
          isEmpty,
        );
        expect(store.value, isNull);
      });
    }

    test('the parent never comes back: cancelled after the time limit', () {
      final c = PocketBaseServerClient(
        config,
        store: store,
        httpClientFactory: server.client,
        googleTimeout: const Duration(milliseconds: 50),
      );
      return expectLater(
        c.signInWithGoogle((_) => Completer<Uri>().future),
        throwsA(
          isA<AuthException>().having(
            (e) => e.error,
            'error',
            AuthError.cancelled,
          ),
        ),
      );
    });
  });

  group('AccountRepository', () {
    late FakeServerClient fake;
    late ProviderContainer container;

    Future<AccountState> loaded() async {
      container.read(accountProvider);
      await Future<void>.delayed(Duration.zero);
      return container.read(accountProvider);
    }

    setUp(() {
      fake = FakeServerClient(config);
      container = ProviderContainer(
        overrides: [serverClientProvider.overrideWithValue(fake)],
      );
    });
    tearDown(() => container.dispose());

    test('starts signed in from the stored session, no network', () async {
      fake.stored = const Account(id: 'u1', email: 'p@x.co');
      final state = await loaded();
      expect(state.loaded, isTrue);
      expect(state.account?.email, 'p@x.co');
      expect(fake.log, isEmpty);
    });

    test('refresh on open: expired signs out, offline stays', () async {
      fake.stored = const Account(id: 'u1', email: 'p@x.co');
      await loaded();
      final repo = container.read(accountProvider.notifier);
      fake.fail = AuthError.offline;
      await repo.refreshOnOpen();
      expect(container.read(accountProvider).signedIn, isTrue);

      container.invalidate(accountProvider);
      await loaded();
      fake.fail = AuthError.expired;
      await container.read(accountProvider.notifier).refreshOnOpen();
      final state = container.read(accountProvider);
      expect(state.signedIn, isFalse);
      expect(state.notice, AccountNotice.signInAgain);
    });

    test(
      'sign-up asks to check the inbox; unverified sign-in asks to verify',
      () async {
        await loaded();
        final repo = container.read(accountProvider.notifier);
        await repo.signUp('p@x.co', password);
        expect(
          container.read(accountProvider).notice,
          AccountNotice.checkInbox,
        );
        await repo.signIn('p@x.co', password);
        final state = container.read(accountProvider);
        expect(state.signedIn, isFalse);
        expect(state.notice, AccountNotice.verifyFirst);
      },
    );

    test('client-side checks come first', () async {
      await loaded();
      final repo = container.read(accountProvider.notifier);
      await repo.signUp('not-an-email', password);
      expect(container.read(accountProvider).error, AuthError.badEmail);
      await repo.signUp('p@x.co', '1234567');
      expect(container.read(accountProvider).error, AuthError.weakPassword);
      expect(fake.log, isEmpty);
    });

    test('forgot password is neutral for unknown emails', () async {
      await loaded();
      fake.fail = AuthError.unknown;
      await container.read(accountProvider.notifier).forgotPassword('who@x.co');
      expect(container.read(accountProvider).notice, AccountNotice.resetSent);
      expect(container.read(accountProvider).error, isNull);
    });
  });
}
