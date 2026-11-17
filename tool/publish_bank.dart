// Publishes the question bank to the server (FEAT-15 D6, BNK-07, BNK-10).
// Run by the "Publish bank" workflow on main; locally against a test server.
//
//   dart run tool/publish_bank.dart [--server URL] [--dry-run]
//       [--bank-file PATH] [--baseline PATH]...
//
// Default: builds the bank as generate_bank.dart does, refuses if it differs
// from assets/questions/bank.json, and keeps every id of the newest release
// tag's bundled bank. --bank-file publishes that file instead (tests), with
// only the --baseline files as extra baselines. The server URL comes from
// --server or PB_URL; the superuser from PB_SUPERUSER_EMAIL and
// PB_SUPERUSER_PASSWORD. Exit 1 with one line on any refusal.
import 'dart:convert';
import 'dart:io';

import 'package:http/http.dart' as http;
import 'package:number_ninja/domain/question.dart';

import 'bank/bank.dart';
import 'bank/generator.dart';
import 'bank/publish.dart';

const committedPath = 'assets/questions/bank.json';

Future<void> main(List<String> args) async {
  try {
    await _run(args);
  } on _Refused catch (e) {
    stderr.writeln('publish_bank: refused: ${e.why}');
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

Future<void> _run(List<String> args) async {
  final dryRun = args.contains('--dry-run');
  final server = _opt(args, '--server') ?? Platform.environment['PB_URL'];
  if (server == null || server.isEmpty) throw _Refused('no --server or PB_URL');
  final base = Uri.parse(server);
  final bankFile = _opt(args, '--bank-file');

  late final List<int> bytes;
  final previous = <QuestionBank>[];
  if (bankFile == null) {
    final text = encodeBank(buildFor(''));
    final committed = File(committedPath).readAsStringSync();
    final p = committedProblem(text, committed);
    if (p != null) throw _Refused(p);
    bytes = utf8.encode(text);
    final tagged = _releaseBank();
    if (tagged != null) previous.add(tagged);
  } else {
    bytes = File(bankFile).readAsBytesSync();
  }
  for (var i = 0; i < args.length - 1; i++) {
    if (args[i] == '--baseline') {
      previous.add(parseBank(File(args[i + 1]).readAsBytesSync()));
    }
  }
  final QuestionBank bank;
  try {
    bank = parseBank(bytes);
  } on Object catch (e) {
    throw _Refused('bank does not parse: $e');
  }

  final client = http.Client();
  try {
    final token = await _superuserToken(client, base);
    final latest = await _latest(client, base);
    int? latestVersion;
    if (latest != null) {
      latestVersion = (latest['version'] as num).toInt();
      final file = latest['file'] as String? ?? '';
      if (file.isNotEmpty) {
        final url = base.resolve('/api/files/banks/${latest['id']}/$file');
        final r = await client.get(url);
        if (r.statusCode != 200) {
          throw _Refused('cannot download the published bank: ${r.statusCode}');
        }
        previous.add(parseBank(r.bodyBytes));
      }
    }
    final p = publishProblem(
      bank,
      latestVersion: latestVersion,
      previous: previous,
    );
    if (p != null) throw _Refused(p);
    final sum = sha256Hex(bytes);
    if (dryRun) {
      stdout.writeln(
        'dry run: would publish version ${bank.version} '
        '(${bank.questions.length} questions, sha256 $sum)',
      );
      return;
    }
    final req =
        http.MultipartRequest(
            'POST',
            base.resolve('/api/collections/banks/records'),
          )
          ..headers['Authorization'] = token
          ..fields.addAll({
            'version': '${bank.version}',
            'format': '${bank.format}',
            'min_app_build': '0',
            'sha256': sum,
            'published_at': DateTime.now().toUtc().toIso8601String(),
          })
          ..files.add(
            http.MultipartFile.fromBytes(
              'file',
              bytes,
              filename: 'bank_v${bank.version}.json',
            ),
          );
    final res = await http.Response.fromStream(await client.send(req));
    if (res.statusCode != 200) {
      throw _Refused('upload failed: ${res.statusCode} ${res.body}');
    }
    stdout.writeln('published version ${bank.version} (sha256 $sum)');
  } finally {
    client.close();
  }
}

Future<String> _superuserToken(http.Client c, Uri base) async {
  final env = Platform.environment;
  final r = await c.post(
    base.resolve('/api/collections/_superusers/auth-with-password'),
    headers: {'Content-Type': 'application/json'},
    body: jsonEncode({
      'identity': env['PB_SUPERUSER_EMAIL'] ?? '',
      'password': env['PB_SUPERUSER_PASSWORD'] ?? '',
    }),
  );
  if (r.statusCode != 200) {
    throw _Refused('superuser sign-in failed: ${r.statusCode}');
  }
  return (jsonDecode(r.body) as Map<String, dynamic>)['token'] as String;
}

Future<Map<String, dynamic>?> _latest(http.Client c, Uri base) async {
  final r = await c.get(
    base.resolve('/api/collections/banks/records?sort=-version&perPage=1'),
  );
  if (r.statusCode != 200) {
    throw _Refused('cannot list banks: ${r.statusCode}');
  }
  final items = (jsonDecode(r.body) as Map<String, dynamic>)['items'] as List;
  return items.isEmpty ? null : (items.first as Map).cast<String, dynamic>();
}

/// The bundled bank of the newest release tag, or null if there is none.
QuestionBank? _releaseBank() {
  final tags = Process.runSync('git', ['tag', '--list', '--sort=-creatordate']);
  if (tags.exitCode != 0) return null;
  final names = (tags.stdout as String)
      .split('\n')
      .where((t) => t.isNotEmpty)
      .toList();
  if (names.isEmpty) return null;
  for (final path in [committedPath, 'assets/questions/bank_v1.json']) {
    final r = Process.runSync('git', [
      'show',
      '${names.first}:$path',
    ], stdoutEncoding: null);
    if (r.exitCode == 0) {
      stdout.writeln('baseline: ${names.first}:$path');
      return parseBank(r.stdout as List<int>);
    }
  }
  return null;
}
