// FEAT-29 AC-4, AC-5 (ENT-03, ENT-04): the Plus read endpoint and the
// RevenueCat webhook, with fixture events from test/fixtures/revenuecat.
// Needs a running PocketBase with BILLING_WEBHOOK_SECRET=$PB_WEBHOOK_SECRET
// (server/test/run.sh); PB_URL_NO_BILLING is one started without it.
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:number_ninja_server_test/fixtures.dart';
import 'package:pocketbase/pocketbase.dart';
import 'package:test/test.dart';

final secret =
    Platform.environment['PB_WEBHOOK_SECRET'] ?? 'test-webhook-secret';
final noBilling = Platform.environment['PB_URL_NO_BILLING'];

const day = Duration(days: 1);
int msIn(Duration d) => DateTime.now().add(d).millisecondsSinceEpoch;
String pbDate(int ms) => DateTime.fromMillisecondsSinceEpoch(
  ms,
  isUtc: true,
).toIso8601String().replaceFirst('T', ' ');

/// A fixture event with its `$NAME` placeholders replaced from [values].
Map<String, dynamic> event(String name, Map<String, Object?> values) {
  Object? fill(Object? v) => switch (v) {
    final String s when s.startsWith(r'$') => values[s.substring(1)],
    final List<Object?> l => [for (final x in l) fill(x)],
    final Map<String, Object?> m => {
      for (final e in m.entries) e.key: fill(e.value),
    },
    _ => v,
  };
  final raw = File('test/fixtures/revenuecat/$name.json').readAsStringSync();
  return fill(jsonDecode(raw)) as Map<String, dynamic>;
}

Future<http.Response> post(
  Map<String, dynamic> body, {
  String? auth,
  String? url,
}) => http.post(
  Uri.parse('${url ?? baseUrl}/api/nn/billing/revenuecat'),
  headers: {'Content-Type': 'application/json', 'Authorization': ?auth},
  body: jsonEncode(body),
);

/// Posts with the right secret and expects 200.
Future<Map<String, dynamic>> send(Map<String, dynamic> body) async {
  final r = await post(body, auth: secret);
  expect(r.statusCode, 200, reason: r.body);
  return jsonDecode(r.body) as Map<String, dynamic>;
}

Future<Map<String, dynamic>> entitlement(PocketBase pb) async =>
    await pb.send<Map<String, dynamic>>('/api/nn/entitlement');

Future<List<RecordModel>> records(String userId) async => (await superuser())
    .collection('entitlements')
    .getFullList(filter: 'user = "$userId"');

int _n = 0;
String eventId() => uniq('evt${_n++}');

void main() {
  group('GET /api/nn/entitlement (AC-4)', () {
    test('a guest gets 401', () async {
      expect(await statusOf(() => entitlement(anonymous())), 401);
    });

    test('no records: plus false, ended_at null, checked_at now', () async {
      final p = await Parent.signUp('none');
      final e = await entitlement(p.pb);
      expect(e['plus'], false);
      expect(e['ended_at'], isNull);
      final checked = DateTime.parse(e['checked_at'] as String);
      expect(checked.difference(DateTime.now()).inSeconds.abs(), lessThan(10));
    });

    test('a FOREVER complimentary grant', () async {
      final p = await Parent.signUp('forever');
      await grant(p.id, expiresAt: forever);
      final e = await entitlement(p.pb);
      expect(e['plus'], true);
      expect(e['until'], startsWith('2099-12-31'));
      expect(e['source'], 'complimentary');
      expect(e['will_renew'], false);
    });

    test('an expired store record and an active complimentary one', () async {
      final p = await Parent.signUp('mixed');
      await grant(
        p.id,
        source: 'google_play',
        status: 'expired',
        expiresAt: pbDateIn(-day),
      );
      await grant(p.id, expiresAt: pbDateIn(const Duration(days: 30)));
      final e = await entitlement(p.pb);
      expect(e['plus'], true);
      expect(e['source'], 'complimentary');
    });

    test('only expired: plus false, ended_at = that expiry', () async {
      final p = await Parent.signUp('ended');
      final ended = pbDateIn(-day);
      await grant(p.id, status: 'expired', expiresAt: ended);
      final e = await entitlement(p.pb);
      expect(e['plus'], false);
      expect(DateTime.parse(e['ended_at'] as String), DateTime.parse(ended));
    });
  });

  group('POST /api/nn/billing/revenuecat (AC-5)', () {
    late Parent p;
    setUp(() async => p = await Parent.signUp('rc'));

    Map<String, dynamic> ev(
      String name, {
      Duration at = Duration.zero,
      Duration exp = const Duration(days: 365),
      String? id,
      String? user,
    }) => event(name, {
      'ID': id ?? eventId(),
      'USER': user ?? p.id,
      'RCANON': r'$RCAnonymousID:abc',
      'AT': msIn(at),
      'EXP': msIn(exp),
      'GRACE': msIn(const Duration(days: 3)),
    });

    test('no secret configured gives 503', () async {
      final r = await post(ev('initial_purchase'), auth: 'x', url: noBilling);
      expect(r.statusCode, 503);
    }, skip: noBilling == null ? 'PB_URL_NO_BILLING not set' : false);

    test('a wrong or missing secret gives 401 and writes nothing', () async {
      expect(
        (await post(ev('initial_purchase'), auth: 'wrong')).statusCode,
        401,
      );
      expect((await post(ev('initial_purchase'))).statusCode, 401);
      expect(await records(p.id), isEmpty);
    });

    test('purchase, renewal, cancellation, expiration', () async {
      await send(ev('initial_purchase', at: -const Duration(hours: 3)));
      var rs = await records(p.id);
      expect(rs.single.getStringValue('source'), 'google_play');
      expect(rs.single.getStringValue('status'), 'active');
      expect(rs.single.getStringValue('environment'), 'SANDBOX');
      var e = await entitlement(p.pb);
      expect(e['plus'], true);
      expect(e['will_renew'], true);

      final renewed = ev(
        'renewal',
        at: -const Duration(hours: 2),
        exp: const Duration(days: 730),
      );
      await send(renewed);
      rs = await records(p.id);
      expect(rs, hasLength(1), reason: 'one record per source');
      expect(
        DateTime.parse(rs.single.getStringValue('expires_at')),
        DateTime.parse(pbDate(renewed['event']['expiration_at_ms'] as int)),
      );

      await send(
        ev(
          'cancellation',
          at: -const Duration(hours: 1),
          exp: const Duration(days: 730),
        ),
      );
      e = await entitlement(p.pb);
      expect(e['plus'], true, reason: 'cancelled keeps Plus until expiry');
      expect(e['status'], 'cancelled');
      expect(e['will_renew'], false);

      await send(ev('expiration', exp: const Duration(days: 730)));
      e = await entitlement(p.pb);
      expect(e['plus'], false, reason: 'expiration ends it now');
      expect((await records(p.id)).single.getStringValue('status'), 'expired');
    });

    test('a refund in the past ends Plus', () async {
      await send(ev('initial_purchase', at: -const Duration(hours: 1)));
      await send(ev('refund', exp: -const Duration(minutes: 1)));
      final e = await entitlement(p.pb);
      expect(e['plus'], false);
      expect((await records(p.id)).single.getStringValue('status'), 'refunded');
    });

    test('a billing issue keeps Plus through the grace period', () async {
      await send(ev('initial_purchase', at: -const Duration(hours: 1)));
      await send(ev('billing_issue', exp: -const Duration(minutes: 1)));
      final e = await entitlement(p.pb);
      expect(e['plus'], true);
      expect(e['status'], 'billing_issue');
    });

    test('the same event twice, or an older one, changes nothing', () async {
      final first = ev('initial_purchase', at: -const Duration(hours: 2));
      await send(first);
      final before = (await records(p.id)).single;
      await send(ev('expiration', id: first['event']['id'] as String));
      expect(
        (await records(p.id)).single.getStringValue('status'),
        'active',
        reason: 'same id',
      );
      final older = await send(ev('expiration', at: -const Duration(hours: 3)));
      expect(older['ignored'], isNotNull);
      final after = (await records(p.id)).single;
      expect(after.getStringValue('status'), 'active');
      expect(
        after.getStringValue('expires_at'),
        before.getStringValue('expires_at'),
      );
    });

    test('unknown user, other store, other entitlement and TEST write '
        'nothing', () async {
      final stranger = ev('initial_purchase', user: 'nosuchuser12345');
      (stranger['event'] as Map)['aliases'] = ['nosuchuser12345'];
      expect((await send(stranger))['ignored'], 'unknown user');
      final stripe = ev('initial_purchase')..['event']['store'] = 'STRIPE';
      expect((await send(stripe))['ignored'], isNotNull);
      final other = ev('initial_purchase')
        ..['event']['entitlement_ids'] = ['gold'];
      expect((await send(other))['ignored'], isNotNull);
      expect((await send(ev('test')))['ignored'], isNotNull);
      expect(await records(p.id), isEmpty);
    });

    test('the anonymous RevenueCat id is skipped for an alias', () async {
      final e = ev('initial_purchase');
      (e['event'] as Map)
        ..['app_user_id'] = r'$RCAnonymousID:abc'
        ..['original_app_user_id'] = r'$RCAnonymousID:abc';
      await send(e);
      expect(await records(p.id), hasLength(1));
    });

    test('TRANSFER moves the record to the new account', () async {
      final to = await Parent.signUp('rc-to');
      await send(ev('initial_purchase', at: -const Duration(hours: 1)));
      final moved = await send(
        event('transfer', {
          'ID': eventId(),
          'AT': msIn(Duration.zero),
          'FROM': p.id,
          'TO': to.id,
        }),
      );
      expect(moved['moved'], 1);
      expect((await entitlement(p.pb))['plus'], false);
      final e = await entitlement(to.pb);
      expect(e['plus'], true);
      expect(e['source'], 'google_play');
    });
  });
}
