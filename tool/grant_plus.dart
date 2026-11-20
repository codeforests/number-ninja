// Gives or takes away complimentary BrainBubblz Plus (FEAT-29 AD-9, ENT-05).
// Run by the "Grant Plus" workflow; locally against a test server.
//
//   dart run tool/grant_plus.dart --email E
//       (--until YYYY-MM-DD | --forever | --revoke) [--note N] [--server URL]
//
// Upserts the account's one `complimentary` entitlement: --until ends Plus
// at the end of that day (UTC), --forever never, --revoke now (status
// revoked; nothing is deleted). The server URL comes from --server or
// PB_URL; the superuser from PB_SUPERUSER_EMAIL and PB_SUPERUSER_PASSWORD.
// Never prints the email. Exit 1 with one line on any refusal.
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const forever = '2099-12-31 23:59:59.000Z';

Future<void> main(List<String> args) async {
  try {
    await _run(args);
  } on _Refused catch (e) {
    stderr.writeln('grant_plus: refused: ${e.why}');
    exitCode = 1;
  }
}

class _Refused implements Exception {
  _Refused(this.why);
  final String why;
}

String? _opt(List<String> args, String name) {
  final i = args.indexOf(name);
  return i >= 0 && i + 1 < args.length ? args[i + 1] : null;
}

String _pbDate(DateTime t) =>
    t.toUtc().toIso8601String().replaceFirst('T', ' ');

Future<void> _run(List<String> args) async {
  final server = _opt(args, '--server') ?? Platform.environment['PB_URL'];
  if (server == null || server.isEmpty) throw _Refused('no --server or PB_URL');
  final email = _opt(args, '--email')?.trim() ?? '';
  if (email.isEmpty) throw _Refused('no --email');
  final until = _opt(args, '--until');
  final modes = [
    until != null,
    args.contains('--forever'),
    args.contains('--revoke'),
  ].where((m) => m).length;
  if (modes != 1) throw _Refused('give one of --until, --forever, --revoke');
  final revoke = args.contains('--revoke');
  final note = _opt(args, '--note');

  final String expiresAt;
  if (revoke) {
    expiresAt = _pbDate(DateTime.now());
  } else if (until != null) {
    final day = DateTime.tryParse(until);
    if (day == null || !RegExp(r'^\d{4}-\d{2}-\d{2}$').hasMatch(until)) {
      throw _Refused('--until must be YYYY-MM-DD');
    }
    final end = DateTime.utc(day.year, day.month, day.day, 23, 59, 59);
    if (end.isBefore(DateTime.now())) throw _Refused('--until is in the past');
    expiresAt = _pbDate(end);
  } else {
    expiresAt = forever;
  }

  final base = Uri.parse(server);
  final c = http.Client();
  try {
    final token = await _superuserToken(c, base);
    final h = {'Authorization': token, 'Content-Type': 'application/json'};
    Future<List<dynamic>> list(String collection, String filter) async {
      final r = await c.get(
        base.replace(
          path: '/api/collections/$collection/records',
          queryParameters: {'filter': filter, 'perPage': '1'},
        ),
        headers: h,
      );
      if (r.statusCode != 200) {
        throw _Refused('cannot read $collection: ${r.statusCode}');
      }
      return (jsonDecode(r.body) as Map<String, dynamic>)['items'] as List;
    }

    final quoted = jsonEncode(email);
    final users = await list('users', 'email = $quoted');
    if (users.isEmpty) throw _Refused('no account with that email');
    final userId = (users.first as Map)['id'] as String;
    final existing = await list(
      'entitlements',
      'user = "$userId" && source = "complimentary"',
    );
    final body = {
      'user': userId,
      'plan': 'plus',
      'source': 'complimentary',
      'status': revoke ? 'revoked' : 'active',
      'expires_at': expiresAt,
      'note': ?note,
    };
    final http.Response r;
    if (existing.isEmpty) {
      if (revoke) {
        stdout.writeln('no complimentary Plus to revoke');
        return;
      }
      r = await c.post(
        base.resolve('/api/collections/entitlements/records'),
        headers: h,
        body: jsonEncode(body),
      );
    } else {
      final id = (existing.first as Map)['id'] as String;
      r = await c.patch(
        base.resolve('/api/collections/entitlements/records/$id'),
        headers: h,
        body: jsonEncode(body),
      );
    }
    if (r.statusCode != 200) {
      throw _Refused('cannot save the entitlement: ${r.statusCode}');
    }
    stdout.writeln(
      revoke ? 'plus revoked' : 'plus until ${expiresAt.substring(0, 10)}',
    );
  } finally {
    c.close();
  }
}

Future<String> _superuserToken(http.Client c, Uri base) async {
  final env = Platform.environment;
  Future<http.Response> signIn() => c.post(
    base.resolve('/api/collections/_superusers/auth-with-password'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'identity': env['PB_SUPERUSER_EMAIL'] ?? '',
      'password': env['PB_SUPERUSER_PASSWORD'] ?? '',
    }),
  );
  // Sign-ins are rate limited (2 per 3 s per IP): wait and retry on 429.
  var r = await signIn();
  for (var i = 0; r.statusCode == 429 && i < 5; i++) {
    await Future<void>.delayed(const Duration(seconds: 2));
    r = await signIn();
  }
  if (r.statusCode != 200) {
    throw _Refused('superuser sign-in failed: ${r.statusCode}');
  }
  return (jsonDecode(r.body) as Map<String, dynamic>)['token'] as String;
}
