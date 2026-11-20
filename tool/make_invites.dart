// Makes, lists and revokes BrainBubblz invitation codes (FEAT-36 IC-6,
// INV-05). Run by the "Make invitation codes" workflow; locally against a
// test server.
//
//   dart run tool/make_invites.dart --count N --note TEXT
//       [--months 12] [--uses 5] [--days 365]
//       [--send-to EMAIL | --email] [--print] [--server URL]
//   dart run tool/make_invites.dart --list [--note TEXT]
//   dart run tool/make_invites.dart --revoke CODE
//
// --send-to mails the codes to EMAIL, --email to the server's INVITE_MAIL_TO
// (else CRASH_DIGEST_TO); a mailed batch is never returned to the tool.
// Without either, the codes stay in the PocketBase admin (invite_codes,
// filter by note) and are printed only with --print. The repository is
// public, so the workflow never passes --print or --list. The server URL
// comes from --server or PB_URL; the superuser from PB_SUPERUSER_EMAIL and
// PB_SUPERUSER_PASSWORD. Never prints an email address. Exit 1 with one line
// on any refusal.
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;

const alphabet = 'ABCDEFGHJKLMNPQRSTUVWXYZ23456789';

Future<void> main(List<String> args) async {
  try {
    await _run(args);
  } on _Refused catch (e) {
    stderr.writeln('make_invites: refused: ${e.why}');
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

int? _int(List<String> args, String name) {
  final v = _opt(args, name);
  if (v == null) return null;
  return int.tryParse(v) ?? (throw _Refused('$name must be a whole number'));
}

String _pretty(String c) => '${c.substring(0, 4)}-${c.substring(4)}';

String _normalise(String raw) =>
    raw.toUpperCase().split('').where(alphabet.contains).join();

Future<void> _run(List<String> args) async {
  final server = _opt(args, '--server') ?? Platform.environment['PB_URL'];
  if (server == null || server.isEmpty) throw _Refused('no --server or PB_URL');
  final base = Uri.parse(server);
  final c = http.Client();
  try {
    final token = await _superuserToken(c, base);
    final h = {'Authorization': token, 'Content-Type': 'application/json'};
    if (args.contains('--list')) return await _list(c, base, h, args);
    final revoke = _opt(args, '--revoke');
    if (revoke != null) return await _revoke(c, base, h, revoke);
    await _make(c, base, h, args);
  } finally {
    c.close();
  }
}

Future<void> _make(
  http.Client c,
  Uri base,
  Map<String, String> h,
  List<String> args,
) async {
  final count = _int(args, '--count');
  if (count == null) throw _Refused('no --count');
  final note = _opt(args, '--note')?.trim() ?? '';
  if (note.isEmpty) throw _Refused('no --note (who the codes are for)');
  final sendTo = _opt(args, '--send-to')?.trim();
  final r = await c.post(
    base.resolve('/api/nn/admin/invites'),
    headers: h,
    body: jsonEncode({
      'count': count,
      'months': ?_int(args, '--months'),
      'max_uses': ?_int(args, '--uses'),
      'redeem_by_days': ?_int(args, '--days'),
      'note': note,
      if (sendTo != null && sendTo.isNotEmpty)
        'send_to': sendTo
      else if (args.contains('--email'))
        'send_to': 'default',
    }),
  );
  if (r.statusCode != 200) {
    final why = (jsonDecode(r.body) as Map<String, dynamic>)['message'];
    throw _Refused('cannot make codes: ${r.statusCode} $why');
  }
  final b = jsonDecode(r.body) as Map<String, dynamic>;
  final where = b['emailed'] == true
      ? 'emailed'
      : 'not emailed; read them in the admin (invite_codes, note "$note")';
  stdout.writeln(
    'made ${b['count']} codes: ${b['months']} months of Plus, '
    '${b['max_uses']} families each, redeem by '
    '${(b['redeem_by'] as String).substring(0, 10)}; $where',
  );
  if (args.contains('--print')) {
    for (final code in (b['codes'] as List? ?? const []).cast<String>()) {
      stdout.writeln(_pretty(code));
    }
  }
}

Future<List<Map<String, dynamic>>> _codes(
  http.Client c,
  Uri base,
  Map<String, String> h,
  String? filter,
) async {
  final r = await c.get(
    base.replace(
      path: '/api/collections/invite_codes/records',
      queryParameters: {'perPage': '500', 'sort': 'created', 'filter': ?filter},
    ),
    headers: h,
  );
  if (r.statusCode != 200) throw _Refused('cannot read codes: ${r.statusCode}');
  return ((jsonDecode(r.body) as Map<String, dynamic>)['items'] as List)
      .cast<Map<String, dynamic>>();
}

Future<void> _list(
  http.Client c,
  Uri base,
  Map<String, String> h,
  List<String> args,
) async {
  final note = _opt(args, '--note');
  final rows = await _codes(
    c,
    base,
    h,
    note == null ? null : 'note = ${jsonEncode(note)}',
  );
  for (final r in rows) {
    stdout.writeln(
      '${_pretty(r['code'] as String)}  ${r['uses']}/${r['max_uses']}  '
      'redeem by ${(r['redeem_by'] as String).substring(0, 10)}'
      '${r['revoked'] == true ? '  revoked' : ''}  ${r['note']}',
    );
  }
  stdout.writeln('${rows.length} codes');
}

Future<void> _revoke(
  http.Client c,
  Uri base,
  Map<String, String> h,
  String raw,
) async {
  final code = _normalise(raw);
  if (code.length != 8) throw _Refused('not a code: $raw');
  final rows = await _codes(c, base, h, 'code = "$code"');
  if (rows.isEmpty) throw _Refused('no such code');
  final r = await c.patch(
    base.resolve('/api/collections/invite_codes/records/${rows.first['id']}'),
    headers: h,
    body: jsonEncode({'revoked': true}),
  );
  if (r.statusCode != 200) throw _Refused('cannot revoke: ${r.statusCode}');
  stdout.writeln('revoked ${_pretty(code)}');
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
