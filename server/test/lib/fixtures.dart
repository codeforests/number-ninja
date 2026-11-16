/// Shared setup for the server tests (FEAT-12): clients for a running
/// PocketBase started by `scripts/server-local.sh`.
library;

import 'dart:io';
import 'dart:math';

import 'package:pocketbase/pocketbase.dart';

String get baseUrl => Platform.environment['PB_URL'] ?? 'http://127.0.0.1:8090';

final _rand = Random();
String uniq(String prefix) =>
    '$prefix-${DateTime.now().microsecondsSinceEpoch}-${_rand.nextInt(1 << 30)}';

PocketBase anonymous() => PocketBase(baseUrl);

/// Sign-ins are rate limited (2 per 3 s per IP, PocketBase's built-in
/// `*:auth` rule, kept on in production): wait and retry on 429.
Future<void> signIn(
  PocketBase pb,
  String collection,
  String email,
  String password,
) async {
  for (var i = 0; ; i++) {
    try {
      await pb.collection(collection).authWithPassword(email, password);
      return;
    } on ClientException catch (e) {
      if (e.statusCode != 429 || i == 10) rethrow;
      await Future<void>.delayed(const Duration(milliseconds: 800));
    }
  }
}

PocketBase? _superuser;

/// One superuser client, signed in once per test run.
Future<PocketBase> superuser() async {
  if (_superuser != null) return _superuser!;
  final pb = PocketBase(baseUrl);
  await signIn(
    pb,
    '_superusers',
    Platform.environment['PB_SUPERUSER_EMAIL'] ?? 'admin@test.local',
    Platform.environment['PB_SUPERUSER_PASSWORD'] ?? 'test-password-123',
  );
  return _superuser = pb;
}

/// A parent signed up through the public create rule, then signed in.
class Parent {
  Parent(this.pb, this.id, this.email, this.password);
  final PocketBase pb;
  final String id;
  final String email;
  final String password;

  /// Verified through the superuser, as the email link would (FEAT-13:
  /// only a verified account can create a child).
  static Future<Parent> signUp(String name) async {
    final email = '${uniq(name)}@test.local';
    const password = 'parent-password-1';
    final pb = PocketBase(baseUrl);
    final user = await pb
        .collection('users')
        .create(
          body: {
            'email': email,
            'password': password,
            'passwordConfirm': password,
          },
        );
    await (await superuser())
        .collection('users')
        .update(user.id, body: {'verified': true});
    await signIn(pb, 'users', email, password);
    return Parent(pb, user.id, email, password);
  }
}

/// One record in each per-child collection, created by the child's owner.
class ChildData {
  ChildData(this.child, this.round, this.attempt, this.badge, this.usage);
  final RecordModel child;
  final RecordModel round;
  final RecordModel attempt;
  final RecordModel badge;
  final RecordModel usage;

  Map<String, RecordModel> get perChild => {
    'rounds': round,
    'attempts': attempt,
    'badges': badge,
    'daily_usage': usage,
  };

  static Future<ChildData> create(Parent p) async {
    final child = await p.pb
        .collection('children')
        .create(body: {'owner': p.id, 'nickname': 'Mei', 'school_year': 2});
    final c = child.id;
    final roundUuid = uniq('round');
    final round = await p.pb
        .collection('rounds')
        .create(body: roundBody(c, roundUuid));
    final attempt = await p.pb
        .collection('attempts')
        .create(body: attemptBody(c, roundUuid));
    final badge = await p.pb
        .collection('badges')
        .create(
          body: {
            'child': c,
            'badge_id': 'first-round',
            'earned_at': '2026-11-16 03:00:00.000Z',
          },
        );
    final usage = await p.pb
        .collection('daily_usage')
        .create(body: usageBody(c));
    return ChildData(child, round, attempt, badge, usage);
  }
}

Map<String, dynamic> roundBody(String child, String uuid) => {
  'child': child,
  'uuid': uuid,
  'topic_id': 'p2-add-3digit',
  'level': 1,
  'kind': 'normal',
  'started_at': '2026-11-16 03:00:00.000Z',
  'finished_at': '2026-11-16 03:05:00.000Z',
  'score': 8,
  'duration_ms': 300000,
  'stars': 2,
  'device_id': 'tablet-1',
};

Map<String, dynamic> attemptBody(String child, String roundUuid) => {
  'child': child,
  'uuid': uniq('attempt'),
  'round_uuid': roundUuid,
  'question_id': 'q-1',
  'answer_given': '42',
  'correct': true,
  'time_ms': 5000,
  'answered_at': '2026-11-16 03:01:00.000Z',
};

Map<String, dynamic> usageBody(String child) => {
  'child': child,
  'day': '2026-11-16',
  'device_id': uniq('device'),
  'seconds_used': 600,
  'extra_seconds_granted': 0,
};

Map<String, dynamic> bodyFor(String collection, String child) =>
    switch (collection) {
      'rounds' => roundBody(child, uniq('round')),
      'attempts' => attemptBody(child, uniq('round')),
      'badges' => {'child': child, 'badge_id': uniq('badge')},
      'daily_usage' => usageBody(child),
      _ => throw ArgumentError(collection),
    };

/// The HTTP status of a failed call, or 200 if it succeeded.
Future<int> statusOf(Future<Object?> Function() call) async {
  try {
    await call();
    return 200;
  } on ClientException catch (e) {
    return e.statusCode;
  }
}
