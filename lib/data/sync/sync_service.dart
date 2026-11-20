import 'dart:convert';

import 'package:drift/drift.dart';

import '../../domain/clock.dart';
import '../../domain/family.dart';
import '../../domain/sync_merge.dart';
import '../child_repository.dart';
import '../database.dart';
import '../profile_repository.dart' show profileOf;
import 'server_client.dart';

/// What one sync run did (FEAT-14). Counts are records, by collection.
class SyncOutcome {
  SyncOutcome();

  /// Whether anything local changed (screens reload their data).
  bool changed = false;
  final pushed = <String, int>{};
  final pulled = <String, int>{};

  /// Rows the server refused even one by one; they stay dirty.
  int rejected = 0;

  void _push(String c, int n) => pushed[c] = (pushed[c] ?? 0) + n;
  void _pull(String c, int n) => pulled[c] = (pulled[c] ?? 0) + n;
}

const _batchSize = 100;
const _pageSize = 500;

/// Copies progress to the server and back (SYN-01..07, ADR-04), as one
/// serial run: refresh, children, push, pull, done. Each local child syncs
/// with her own server `children` record (FEAT-25 FAM-06). The merge decisions come
/// from `domain/sync_merge.dart`.
class SyncService {
  SyncService({
    required this.db,
    required this.client,
    required this.clock,
    required this.forgetSession,
    this.busyWait = const Duration(seconds: 1),
  });

  final AppDatabase db;
  final ServerClient client;
  final Clock clock;

  /// Called after a reset deleted local rounds (FEAT-06 gotcha).
  final void Function() forgetSession;

  /// Wait before sending a batch again after "too many requests" (429).
  final Duration busyWait;

  /// One run. Throws [SyncException] when it has to stop (offline, server
  /// error, expired session); the controller retries.

  Future<SyncOutcome> run() async {
    final out = SyncOutcome();
    final Account account;
    try {
      account = await client.refresh();
    } on AuthException catch (e) {
      throw SyncException(switch (e.error) {
        AuthError.expired => SyncError.expired,
        AuthError.offline || AuthError.notConfigured => SyncError.offline,
        AuthError.tooManyTries => SyncError.server,
        _ => SyncError.unknown,
      });
    }
    var state = await _state();
    if (state.accountId != account.id) {
      await _linkAccount(account.id, switched: state.accountId != null);
      state = await _state();
    }
    final device = await db.deviceId();
    final linked = await _children(out);
    await _moveLegacyCursors(state);
    for (final (local, remote) in linked) {
      await _pushAll(local, remote, device, out);
    }
    final ctx = _PullContext(device);
    for (final (local, remote) in linked) {
      await _pullAll(local, remote, ctx, out);
    }
    await _setState(
      SyncStateCompanion(lastSyncAt: Value(clock()), lastError: Value(null)),
    );
    return out;
  }

  // --- state ---------------------------------------------------------------

  Future<SyncStateData> _state() =>
      (db.select(db.syncState)..where((s) => s.id.equals(1))).getSingle();

  Future<void> _setState(SyncStateCompanion c) =>
      (db.update(db.syncState)..where((s) => s.id.equals(1))).write(c);

  /// The last sync time and error kept on the device (SYN-07).
  Future<({DateTime? lastSyncAt, SyncError? lastError})> savedStatus() async {
    final s = await _state();
    return (
      lastSyncAt: s.lastSyncAt,
      lastError: SyncError.values.asNameMap()[s.lastError],
    );
  }

  /// Records why the last run failed (SCR-13 shows it).
  Future<void> recordError(SyncError? e) =>
      _setState(SyncStateCompanion(lastError: Value(e?.name)));

  /// Asks the next run to clear the server's progress of child [childId]
  /// (SCR-11 reset while signed in, SYN-06, FEAT-25 AD-11).
  Future<void> markPendingReset(int childId) =>
      (db.update(db.children)..where((c) => c.id.equals(childId))).write(
        const ChildrenCompanion(pendingReset: Value(true)),
      );

  /// First sign-in of [accountId] on this device (SYN-03): forget the old
  /// account's ids and cursors and mark everything unsent, so this device's
  /// progress merges into the account's.
  Future<void> _linkAccount(String accountId, {required bool switched}) =>
      db.transaction(() async {
        await _setState(
          SyncStateCompanion(
            accountId: Value(accountId),
            childId: const Value(null),
            resetEpoch: const Value(0),
            // A reset made while signed in to this account before its first
            // sync on this device still applies; one left from another
            // account doesn't (SYN-06).
            pendingReset: switched ? const Value(false) : const Value.absent(),
            cursors: const Value('{}'),
          ),
        );
        // Children link again by nickname (AD-9); a child removed here
        // while signed out has nothing left to delete there.
        await db.customStatement(
          'DELETE FROM children WHERE pending_delete = 1',
        );
        await db.customStatement(
          'UPDATE children SET remote_id = NULL, reset_epoch = 0'
          '${switched ? ', pending_reset = 0' : ''}',
        );
        for (final t in ['rounds', 'badges_earned', 'daily_usage']) {
          await db.customStatement(
            'UPDATE $t SET dirty = dirty + 1, remote_id = NULL',
          );
        }
        await db.customStatement('UPDATE attempts SET dirty = dirty + 1');
        if (switched) {
          // Uuids are unique across the server: copies for another account get
          // new ones (attempts keep pointing at their rounds by local id).
          for (final t in ['rounds', 'attempts']) {
            await db.customStatement(
              'UPDATE $t SET uuid = lower(hex(randomblob(16)))',
            );
          }
        }
        await db.customStatement('UPDATE sync_fields SET dirty = dirty + 1');
      });

  // --- child, reset and fields ----------------------------------------------

  Future<List<ChildRow>> _visibleChildren() =>
      (db.select(db.children)
            ..where((c) => c.pendingDelete.equals(false))
            ..orderBy([(c) => OrderingTerm.asc(c.id)]))
          .get();

  Future<void> _setChild(int id, ChildrenCompanion c) =>
      (db.update(db.children)..where((r) => r.id.equals(id))).write(c);

  /// Brings the family in line with the account's `children` records and
  /// returns each local child with her server id (FEAT-25): removed
  /// children go (AD-10), unlinked ones match by nickname (AD-9), the
  /// account's other children are added here and this device's are created
  /// there; then each child's reset and fields (AD-11).
  Future<List<(int, String)>> _children(SyncOutcome out) async {
    var remote = await client.listChildren();

    // AD-10: removed here while offline: delete her server record now.
    final gone = await (db.select(
      db.children,
    )..where((c) => c.pendingDelete.equals(true))).get();
    for (final l in gone) {
      final rid = l.remoteId;
      if (rid != null && remote.any((c) => c['id'] == rid)) {
        await client.deleteChild(rid);
        remote = [
          for (final c in remote)
            if (c['id'] != rid) c,
        ];
      }
      await (db.delete(db.children)..where((c) => c.id.equals(l.id))).go();
    }
    final byId = {for (final c in remote) c['id'] as String: c};

    // AD-9: unlinked children here meet the account's unlinked ones.
    var locals = await _visibleChildren();
    final linked = {
      for (final l in locals)
        if (byId.containsKey(l.remoteId)) l.remoteId!,
    };
    final matches = matchChildren(
      [
        for (final l in locals)
          if (l.remoteId == null) (l.id, l.nickname),
      ],
      [
        for (final c in remote)
          if (!linked.contains(c['id']))
            (c['id'] as String, '${c['nickname'] ?? ''}'),
      ],
    );
    for (final MapEntry(key: local, value: rid) in matches.entries) {
      // Newly linked: take the account's epoch, keep this device's progress.
      await _setChild(
        local,
        ChildrenCompanion(
          remoteId: Value(rid),
          resetEpoch: Value(_int(byId[rid]!['reset_epoch'])),
        ),
      );
    }
    final taken = {...linked, ...matches.values};
    for (final c in remote) {
      if (taken.contains(c['id'])) continue;
      // A sibling added on another device (AD-1: never dropped, even past
      // maxChildren). Her fields come from the account in the merge below.
      final now = clock();
      final year = _int(c['school_year']);
      final avatar = '${c['avatar'] ?? ''}';
      final id = await db
          .into(db.children)
          .insert(
            ChildrenCompanion.insert(
              schoolYear: Value(year == 0 ? 1 : year),
              avatar: Value(
                avatarIds.contains(avatar)
                    ? avatar
                    : nextAvatar(locals.map((l) => l.avatar)),
              ),
              createdAt: now,
              updatedAt: now,
              remoteId: Value(c['id'] as String),
              resetEpoch: Value(_int(c['reset_epoch'])),
            ),
          );
      await db.seedChildFields(id, profileTime: null);
      out.changed = true;
    }

    // AD-10: a linked child the account no longer has was removed on
    // another device.
    for (final l in await _visibleChildren()) {
      if (l.remoteId == null || byId.containsKey(l.remoteId)) continue;
      if ((await _visibleChildren()).length <= 1) {
        // There is always a child (AD-2): keep her, as new to the account.
        await _setChild(
          l.id,
          const ChildrenCompanion(
            remoteId: Value(null),
            resetEpoch: Value(0),
            pendingReset: Value(false),
          ),
        );
        for (final t in ['rounds', 'badges_earned', 'daily_usage']) {
          await db.customStatement(
            'UPDATE $t SET dirty = dirty + 1, remote_id = NULL '
            'WHERE child_id = ?',
            [l.id],
          );
        }
        await db.customStatement(
          'UPDATE attempts SET dirty = dirty + 1 WHERE child_id = ?',
          [l.id],
        );
        continue;
      }
      await db.transaction(() async {
        await ChildRepository(db, clock: clock).deleteRows(l.id);
        await (db.delete(db.children)..where((c) => c.id.equals(l.id))).go();
      });
      out.changed = true;
    }

    final pairs = <(int, String)>[];
    locals = await _visibleChildren();
    for (final l in locals) {
      final rid = l.remoteId;
      if (rid == null) {
        final local = await _localFields(l.id);
        final created = await client.createChild({
          ..._fieldBody(local.values, local.times.keys),
          'field_times': _timesJson(local.times),
          'reset_epoch': 0,
        });
        await _setChild(
          l.id,
          ChildrenCompanion(
            remoteId: Value(created['id'] as String),
            resetEpoch: const Value(0),
            pendingReset: const Value(false),
          ),
        );
        await _fieldsSent(l.id);
        pairs.add((l.id, created['id'] as String));
        continue;
      }
      final c = byId[rid]!;
      final remoteEpoch = _int(c['reset_epoch']);
      if (l.pendingReset) {
        // Also when newly linked: a reset made before this device's first
        // successful sync clears the server before the pull (SYN-06).
        final r = await client.resetChild(rid);
        await _setChild(
          l.id,
          ChildrenCompanion(
            resetEpoch: Value(r.epoch),
            pendingReset: const Value(false),
          ),
        );
      } else if (remoteEpoch > l.resetEpoch) {
        final at = _date(c['reset_at']);
        if (at != null) await _clearBefore(l.id, at);
        forgetSession();
        out.changed = true;
        await _setChild(
          l.id,
          ChildrenCompanion(resetEpoch: Value(remoteEpoch)),
        );
      }
      await _mergeChild(l.id, c, out);
      pairs.add((l.id, rid));
    }
    return pairs;
  }

  Future<void> _fieldsSent(int childId) => db.customStatement(
    'UPDATE sync_fields SET dirty = 0 WHERE child_id = ?',
    [childId],
  );

  /// Cursors before FEAT-25 were per collection for the one child
  /// (`sync_state.child_id`); they become that child's (AD-16).
  Future<void> _moveLegacyCursors(SyncStateData state) async {
    final cursors = Map<String, String>.from(
      jsonDecode((await _state()).cursors) as Map,
    );
    final old = state.childId;
    if (!_pulled.any(cursors.containsKey)) return;
    for (final c in _pulled) {
      final v = cursors.remove(c);
      if (v != null && old != null) cursors.putIfAbsent('$old/$c', () => v);
    }
    await _setState(SyncStateCompanion(cursors: Value(jsonEncode(cursors))));
  }

  static const _pulled = ['rounds', 'attempts', 'badges', 'daily_usage'];

  /// Deletes child [childId]'s local rounds started before [at] (with their
  /// attempts) and badges earned before it: another device reset her
  /// progress (SYN-06, AD-11).
  Future<void> _clearBefore(
    int childId,
    DateTime at,
  ) => db.transaction(() async {
    final old = db.selectOnly(db.rounds)
      ..addColumns([db.rounds.id])
      ..where(
        db.rounds.startedAt.isSmallerThanValue(at) &
            db.rounds.childId.equals(childId),
      );
    await (db.delete(db.attempts)..where((a) => a.roundId.isInQuery(old))).go();
    await (db.delete(db.rounds)..where(
          (r) => r.startedAt.isSmallerThanValue(at) & r.childId.equals(childId),
        ))
        .go();
    await (db.delete(db.badgesEarned)..where(
          (b) => b.earnedAt.isSmallerThanValue(at) & b.childId.equals(childId),
        ))
        .go();
  });

  Future<void> _mergeChild(
    int childId,
    Map<String, dynamic> c,
    SyncOutcome out,
  ) async {
    final local = await _localFields(childId);
    final remoteTimes = <String, DateTime>{
      for (final e in ((c['field_times'] as Map?) ?? const {}).entries)
        if (_date(e.value) != null) e.key as String: _date(e.value)!,
    };
    final remoteValues = _remoteValues(c);
    final localTimes = {...local.times};
    // Her profile isn't filled in here yet (a first run, or a sibling just
    // added from the account).
    final pending = local.values[syncFieldNickname] == null;
    final remoteHasProfile =
        (remoteValues[syncFieldNickname] as String? ?? '').isNotEmpty;
    if (pending) {
      // No profile here yet: never send the empty one, take the account's.
      for (final f in profileSyncFields) {
        localTimes.remove(f);
      }
    }
    final winners = mergeFields(localTimes, remoteTimes);
    bool inSync(String f) =>
        localTimes[f] != null &&
        remoteTimes[f] != null &&
        localTimes[f]!.isAtSameMomentAs(remoteTimes[f]!);
    final takeRemote = [
      for (final e in winners.entries)
        if (e.value == FieldWinner.remote && !inSync(e.key)) e.key,
    ];
    final sendLocal = [
      for (final e in winners.entries)
        if (e.value == FieldWinner.local) e.key,
    ];
    if (takeRemote.isNotEmpty) {
      final changed = await _applyRemote(
        childId,
        takeRemote,
        remoteValues,
        remoteTimes,
        local.values,
        takeProfile: !pending || remoteHasProfile,
      );
      if (changed) out.changed = true;
    }
    if (sendLocal.isEmpty) {
      await _fieldsSent(childId);
      return;
    }
    final times = {...remoteTimes};
    for (final f in sendLocal) {
      times[f] = localTimes[f]!;
    }
    await client.updateChild(c['id'] as String, {
      ..._fieldBody(local.values, sendLocal),
      'field_times': _timesJson(times),
    });
    await _fieldsSent(childId);
  }

  /// Writes the server's value of each of [fields] here, stamped with the
  /// server's time (no new change). Returns whether anything changed.
  Future<bool> _applyRemote(
    int childId,
    List<String> fields,
    Map<String, Object?> remote,
    Map<String, DateTime> remoteTimes,
    Map<String, Object?> local, {
    required bool takeProfile,
  }) => db.transaction(() async {
    final profileFields = takeProfile
        ? fields.where(profileSyncFields.contains).toList()
        : <String>[];
    var changed = false;
    Object? v(String f) => (profileFields.contains(f) ? remote : local)[f];
    if (profileFields.isNotEmpty) {
      final nickname = v(syncFieldNickname) as String? ?? '';
      final year = v(syncFieldSchoolYear) as int?;
      if (nickname.isNotEmpty && year != null) {
        await (db.update(
          db.children,
        )..where((c) => c.id.equals(childId))).write(
          ChildrenCompanion(
            nickname: Value(nickname),
            schoolYear: Value(year),
            schoolStartLevel: Value(v(syncFieldStartSchool) as int?),
            olympiadStartLevel: Value(v(syncFieldStartOlympiad) as int?),
            updatedAt: Value(clock()),
          ),
        );
        await (db.update(db.appSettings)..where((s) => s.id.equals(1))).write(
          const AppSettingsCompanion(profilePending: Value(false)),
        );
        changed = true;
      }
    }
    final settings = ChildrenCompanion(
      dailyLimitMin: fields.contains(syncFieldDailyLimit)
          ? Value(remote[syncFieldDailyLimit] as int)
          : const Value.absent(),
      soundOn: fields.contains(syncFieldSound)
          ? Value(remote[syncFieldSound] as bool)
          : const Value.absent(),
      // A record from before FEAT-25 has no avatar: keep hers.
      avatar:
          fields.contains(syncFieldAvatar) &&
              avatarIds.contains(remote[syncFieldAvatar])
          ? Value(remote[syncFieldAvatar] as String)
          : const Value.absent(),
    );
    if (settings.dailyLimitMin.present ||
        settings.soundOn.present ||
        settings.avatar.present) {
      await (db.update(
        db.children,
      )..where((c) => c.id.equals(childId))).write(settings);
      changed = true;
    }
    if (fields.contains(syncFieldTopics)) {
      final want = (remote[syncFieldTopics] as List<String>).toSet();
      final have = {for (final r in await _topicRows(childId)) r.topicId};
      if (want.length != have.length || !want.containsAll(have)) {
        await (db.delete(db.topicUnlocks)..where(
              (t) => t.topicId.isNotIn(want) & t.childId.equals(childId),
            ))
            .go();
        for (final id in want.difference(have)) {
          await db
              .into(db.topicUnlocks)
              .insert(
                TopicUnlocksCompanion.insert(
                  childId: childId,
                  topicId: id,
                  openedAt: clock(),
                ),
              );
        }
        changed = true;
      }
    }
    for (final f in fields) {
      if (profileSyncFields.contains(f) && !profileFields.contains(f)) continue;
      await (db.update(
        db.syncFields,
      )..where((s) => s.field.equals(f) & s.childId.equals(childId))).write(
        SyncFieldsCompanion(
          changedAt: Value(remoteTimes[f]!),
          dirty: const Value(0),
        ),
      );
    }
    return changed;
  });

  Future<({Map<String, Object?> values, Map<String, DateTime> times})>
  _localFields(int childId) async {
    final child = await (db.select(
      db.children,
    )..where((c) => c.id.equals(childId))).getSingle();
    final profile = profileOf(child);
    final settings = child;
    final topics = [for (final r in await _topicRows(childId)) r.topicId]
      ..sort();
    final times = {
      for (final f in await (db.select(
        db.syncFields,
      )..where((f) => f.childId.equals(childId))).get())
        f.field: f.changedAt,
    };
    if (profile == null) {
      for (final f in profileSyncFields) {
        times.remove(f);
      }
    }
    return (
      values: <String, Object?>{
        syncFieldNickname: profile?.nickname,
        syncFieldSchoolYear: profile?.schoolYear,
        syncFieldStartSchool: profile?.schoolStartLevel,
        syncFieldStartOlympiad: profile?.olympiadStartLevel,
        syncFieldDailyLimit: settings.dailyLimitMin,
        syncFieldSound: settings.soundOn,
        syncFieldAvatar: settings.avatar,
        syncFieldTopics: topics,
      },
      times: times,
    );
  }

  Future<List<TopicUnlock>> _topicRows(int childId) => (db.select(
    db.topicUnlocks,
  )..where((t) => t.childId.equals(childId))).get();

  /// The child record's fields as local values (a start level of 0 means
  /// none: PocketBase numbers can't be null).
  Map<String, Object?> _remoteValues(Map<String, dynamic> c) {
    int? level(Object? v) => _int(v) == 0 ? null : _int(v);
    return {
      syncFieldNickname: c['nickname'] as String? ?? '',
      syncFieldSchoolYear: _int(c['school_year']) == 0
          ? null
          : _int(c['school_year']),
      syncFieldStartSchool: level(c['start_level_school']),
      syncFieldStartOlympiad: level(c['start_level_olympiad']),
      syncFieldDailyLimit: _int(c['daily_limit_min']),
      syncFieldSound: c['sound_on'] == true,
      syncFieldAvatar: c['avatar'] as String? ?? '',
      syncFieldTopics: [
        for (final t in (c['unlocked_topics'] as List?) ?? const []) '$t',
      ],
    };
  }

  Map<String, dynamic> _fieldBody(
    Map<String, Object?> values,
    Iterable<String> fields,
  ) => {
    for (final f in fields)
      f: switch (f) {
        syncFieldStartSchool || syncFieldStartOlympiad => values[f] ?? 0,
        _ => values[f],
      },
  };

  Map<String, String> _timesJson(Map<String, DateTime> times) => {
    for (final e in times.entries) e.key: _iso(e.value),
  };

  // --- push ------------------------------------------------------------------

  /// Pushes child [local]'s dirty rows to her server record [child].
  Future<void> _pushAll(
    int local,
    String child,
    String device,
    SyncOutcome out,
  ) async {
    final rounds =
        await (db.select(db.rounds)..where(
              (r) => r.dirty.isBiggerThanValue(0) & r.childId.equals(local),
            ))
            .get();
    await _push(
      'rounds',
      [
        for (final r in rounds)
          _Row(
            r.dirty,
            r.remoteId,
            {
              'child': child,
              'uuid': r.uuid,
              'topic_id': r.topicId,
              'level': r.level,
              'kind': r.kind,
              'started_at': _iso(r.startedAt),
              'finished_at': r.finishedAt == null ? '' : _iso(r.finishedAt!),
              'score': r.score,
              'duration_ms': r.durationMs,
              'stars': r.stars,
              'device_id': device,
            },
            key: r.uuid,
            find: ('uuid = {:u}', {'u': r.uuid}),
          ),
      ],
      (row, remoteId) =>
          _clearDirty('rounds', 'uuid', row.key, row.dirty, remoteId),
      out,
    );

    final attempts = await db
        .customSelect(
          'SELECT a.uuid, a.dirty, a.question_id, a.answer_given, a.correct, '
          'a.time_ms, a.answered_at, r.uuid AS round_uuid FROM attempts a '
          'JOIN rounds r ON r.id = a.round_id '
          'WHERE a.dirty > 0 AND a.child_id = ?',
          variables: [Variable.withInt(local)],
          readsFrom: {db.attempts, db.rounds},
        )
        .get();
    await _push(
      'attempts',
      [
        for (final a in attempts)
          _Row(
            a.read<int>('dirty'),
            null,
            {
              'child': child,
              'uuid': a.read<String>('uuid'),
              'round_uuid': a.read<String>('round_uuid'),
              'question_id': a.read<String>('question_id'),
              'answer_given': a.read<String>('answer_given'),
              'correct': a.read<bool>('correct'),
              'time_ms': a.read<int>('time_ms'),
              'answered_at': _iso(a.read<DateTime>('answered_at')),
            },
            key: a.read<String>('uuid'),
            find: ('uuid = {:u}', {'u': a.read<String>('uuid')}),
            appendOnly: true,
          ),
      ],
      (row, _) => _clearDirty('attempts', 'uuid', row.key, row.dirty, null),
      out,
    );

    final badges =
        await (db.select(db.badgesEarned)..where(
              (b) => b.dirty.isBiggerThanValue(0) & b.childId.equals(local),
            ))
            .get();
    await _push(
      'badges',
      [
        for (final b in badges)
          _Row(
            b.dirty,
            b.remoteId,
            {
              'child': child,
              'badge_id': b.badgeId,
              'earned_at': _iso(b.earnedAt),
            },
            key: b.badgeId,
            find: (
              'child = {:c} && badge_id = {:b}',
              {'c': child, 'b': b.badgeId},
            ),
            // Earliest date wins: only overwrite a later one.
            updateFound: (found) =>
                mergeBadge(b.earnedAt, _date(found['earned_at']) ?? clock()) ==
                BadgeMerge.pushLocal,
          ),
      ],
      (row, remoteId) => _clearDirty(
        'badges_earned',
        'badge_id',
        row.key,
        row.dirty,
        remoteId,
        extra: ' AND child_id = ?',
        extraArgs: [local],
      ),
      out,
    );

    final usage =
        await (db.select(db.dailyUsage)..where(
              (u) =>
                  u.dirty.isBiggerThanValue(0) &
                  u.deviceId.equals(device) &
                  u.childId.equals(local),
            ))
            .get();
    await _push(
      'daily_usage',
      [
        for (final u in usage)
          _Row(
            u.dirty,
            u.remoteId,
            {
              'child': child,
              'day': u.day,
              'device_id': device,
              'seconds_used': u.secondsUsed,
              'extra_seconds_granted': u.extraSecondsGranted,
            },
            key: u.day,
            find: (
              'child = {:c} && day = {:d} && device_id = {:v}',
              {'c': child, 'd': u.day, 'v': device},
            ),
          ),
      ],
      (row, remoteId) => _clearDirty(
        'daily_usage',
        'day',
        row.key,
        row.dirty,
        remoteId,
        extra: ' AND device_id = ? AND child_id = ?',
        extraArgs: [device, local],
      ),
      out,
    );
  }

  /// Sends [rows] in batches of 100; a failed batch (one duplicate fails it
  /// all) goes again row by row.
  Future<void> _push(
    String collection,
    List<_Row> rows,
    Future<void> Function(_Row row, String? remoteId) sent,
    SyncOutcome out,
  ) async {
    for (var i = 0; i < rows.length; i += _batchSize) {
      final chunk = rows.sublist(i, (i + _batchSize).clamp(0, rows.length));
      try {
        final results = await _retryBusy(
          () => client.pushBatch([
            for (final r in chunk) PushOp(collection, r.body, id: r.remoteId),
          ]),
        );
        await db.transaction(() async {
          for (var j = 0; j < chunk.length; j++) {
            await sent(chunk[j], results[j]['id'] as String?);
          }
        });
        out._push(collection, chunk.length);
      } on SyncException catch (e) {
        if (e.error != SyncError.rejected) rethrow;
        for (final r in chunk) {
          await _pushOne(collection, r, sent, out);
        }
      }
    }
  }

  /// Runs [call] again after [busyWait] while the server says it's busy
  /// (rate limit, 429), up to 20 times.
  Future<T> _retryBusy<T>(Future<T> Function() call) async {
    for (var i = 0; ; i++) {
      try {
        return await call();
      } on SyncException catch (e) {
        if (e.status != 429 || i >= 20) rethrow;
        await Future<void>.delayed(busyWait);
      }
    }
  }

  Future<void> _pushOne(
    String collection,
    _Row row,
    Future<void> Function(_Row row, String? remoteId) sent,
    SyncOutcome out,
  ) async {
    try {
      final r = await client.pushBatch([
        PushOp(collection, row.body, id: row.remoteId),
      ]);
      await sent(row, r.single['id'] as String?);
      out._push(collection, 1);
      return;
    } on SyncException catch (e) {
      if (e.error != SyncError.rejected) rethrow;
      if (!(e.notUnique && row.remoteId == null) && e.status != 404) {
        out.rejected++;
        return;
      }
    }
    // Already there (a duplicate) or gone (404 on update): find it by key.
    try {
      final found = await client.findOne(collection, row.find.$1, row.find.$2);
      if (found == null) {
        final r = await client.pushBatch([PushOp(collection, row.body)]);
        await sent(row, r.single['id'] as String?);
      } else if (row.appendOnly || !row.updateFound(found)) {
        await sent(row, found['id'] as String);
      } else {
        final id = found['id'] as String;
        await client.pushBatch([PushOp(collection, row.body, id: id)]);
        await sent(row, id);
      }
      out._push(collection, 1);
    } on SyncException catch (e) {
      if (e.error != SyncError.rejected) rethrow;
      out.rejected++;
    }
  }

  /// Marks a row sent, unless it changed again since it was read.
  Future<void> _clearDirty(
    String table,
    String keyColumn,
    String key,
    int dirty,
    String? remoteId, {
    String extra = '',
    List<Object> extraArgs = const [],
  }) async {
    if (remoteId != null && table != 'attempts') {
      await db.customStatement(
        'UPDATE $table SET remote_id = ? WHERE $keyColumn = ?$extra',
        [remoteId, key, ...extraArgs],
      );
    }
    await db.customStatement(
      'UPDATE $table SET dirty = 0 WHERE $keyColumn = ? AND dirty = ?$extra',
      [key, dirty, ...extraArgs],
    );
  }

  // --- pull ------------------------------------------------------------------

  /// Pulls child [local]'s records from her server record [child], from
  /// her own cursor per collection (`<child>/<collection>`, AD-16).
  Future<void> _pullAll(
    int local,
    String child,
    _PullContext ctx,
    SyncOutcome out,
  ) async {
    final cursors = Map<String, String>.from(
      jsonDecode((await _state()).cursors) as Map,
    );
    for (final collection in _pulled) {
      final key = '$child/$collection';
      final from = cursors[key] ?? '';
      var last = from;
      String? blockedAt;
      var total = 1;
      for (var page = 1; page <= total; page++) {
        final p = await client.pullPage(
          collection,
          child,
          from,
          page,
          perPage: _pageSize,
        );
        if (page == 1) total = p.totalPages;
        await db.transaction(() async {
          for (final item in p.items) {
            final updated = item['updated'] as String? ?? '';
            final ok = await _merge(local, collection, item, ctx, out);
            if (!ok) blockedAt ??= updated;
            if (updated.compareTo(last) > 0) last = updated;
          }
        });
        out._pull(collection, p.items.length);
        if (p.items.isEmpty) break;
      }
      cursors[key] = blockedAt ?? last;
    }
    await _setState(SyncStateCompanion(cursors: Value(jsonEncode(cursors))));
  }

  /// Merges one pulled record; false when it can't be placed yet (an
  /// attempt of an unknown round).
  Future<bool> _merge(
    int childId,
    String collection,
    Map<String, dynamic> item,
    _PullContext ctx,
    SyncOutcome out,
  ) async {
    switch (collection) {
      case 'rounds':
        final uuid = item['uuid'] as String;
        final local = await (db.select(
          db.rounds,
        )..where((r) => r.uuid.equals(uuid))).getSingleOrNull();
        final finishedAt = _date(item['finished_at']);
        switch (mergeRound(
          known: local != null,
          localFinishedAt: local?.finishedAt,
          remoteFinishedAt: finishedAt,
        )) {
          case RoundMerge.insert:
            ctx.session ??= await db
                .into(db.playSessions)
                .insert(PlaySessionsCompanion.insert(startedAt: clock()));
            await db
                .into(db.rounds)
                .insert(
                  RoundsCompanion.insert(
                    sessionId: ctx.session!,
                    childId: childId,
                    topicId: item['topic_id'] as String,
                    level: Value(_int(item['level'])),
                    startedAt: _date(item['started_at']) ?? clock(),
                    score: Value(_int(item['score'])),
                    durationMs: Value(_int(item['duration_ms'])),
                    stars: Value(_int(item['stars'])),
                    finishedAt: Value(finishedAt),
                    kind: Value(item['kind'] as String? ?? 'normal'),
                    uuid: Value(uuid),
                    dirty: const Value(0),
                    remoteId: Value(item['id'] as String),
                  ),
                );
            out.changed = true;
          case RoundMerge.finish:
            await (db.update(
              db.rounds,
            )..where((r) => r.uuid.equals(uuid))).write(
              RoundsCompanion(
                score: Value(_int(item['score'])),
                durationMs: Value(_int(item['duration_ms'])),
                stars: Value(_int(item['stars'])),
                finishedAt: Value(finishedAt),
                remoteId: Value(item['id'] as String),
              ),
            );
            out.changed = true;
          case RoundMerge.keep:
            if (local!.remoteId == null) {
              await (db.update(
                db.rounds,
              )..where((r) => r.uuid.equals(uuid))).write(
                RoundsCompanion(remoteId: Value(item['id'] as String)),
              );
            }
        }
        return true;
      case 'attempts':
        final uuid = item['uuid'] as String;
        final known = await (db.select(
          db.attempts,
        )..where((a) => a.uuid.equals(uuid))).getSingleOrNull();
        if (!attemptIsNew(known: known != null)) return true;
        final round =
            await (db.select(db.rounds)
                  ..where((r) => r.uuid.equals(item['round_uuid'] as String)))
                .getSingleOrNull();
        if (round == null) return false;
        await db
            .into(db.attempts)
            .insert(
              AttemptsCompanion.insert(
                roundId: round.id,
                childId: round.childId,
                questionId: item['question_id'] as String,
                answerGiven: item['answer_given'] as String? ?? '',
                correct: item['correct'] == true,
                timeMs: _int(item['time_ms']),
                answeredAt: _date(item['answered_at']) ?? clock(),
                uuid: Value(uuid),
                dirty: const Value(0),
              ),
            );
        out.changed = true;
        return true;
      case 'badges':
        final id = item['badge_id'] as String;
        final remoteAt = _date(item['earned_at']) ?? clock();
        final local =
            await (db.select(db.badgesEarned)..where(
                  (b) => b.badgeId.equals(id) & b.childId.equals(childId),
                ))
                .getSingleOrNull();
        switch (mergeBadge(local?.earnedAt, remoteAt)) {
          case BadgeMerge.insert:
            await db
                .into(db.badgesEarned)
                .insert(
                  BadgesEarnedCompanion.insert(
                    childId: childId,
                    badgeId: id,
                    earnedAt: remoteAt,
                    dirty: const Value(0),
                    remoteId: Value(item['id'] as String),
                  ),
                );
            out.changed = true;
          case BadgeMerge.takeRemote:
            await (db.update(db.badgesEarned)..where(
                  (b) => b.badgeId.equals(id) & b.childId.equals(childId),
                ))
                .write(
                  BadgesEarnedCompanion(
                    earnedAt: Value(remoteAt),
                    remoteId: Value(item['id'] as String),
                  ),
                );
            out.changed = true;
          case BadgeMerge.pushLocal:
            await db.customStatement(
              'UPDATE badges_earned SET dirty = dirty + 1, remote_id = ? '
              'WHERE badge_id = ? AND child_id = ?',
              [item['id'] as String, id, childId],
            );
          case BadgeMerge.keep:
            break;
        }
        return true;
      case 'daily_usage':
        final device = item['device_id'] as String;
        if (device == ctx.device) return true;
        final day = item['day'] as String;
        final local =
            await (db.select(db.dailyUsage)..where(
                  (u) =>
                      u.day.equals(day) &
                      u.deviceId.equals(device) &
                      u.childId.equals(childId),
                ))
                .getSingleOrNull();
        final remote = UsageCounts(
          _int(item['seconds_used']),
          _int(item['extra_seconds_granted']),
        );
        final have = local == null
            ? null
            : UsageCounts(local.secondsUsed, local.extraSecondsGranted);
        final merged = mergeUsage(have, remote);
        if (merged == have) return true;
        await db
            .into(db.dailyUsage)
            .insertOnConflictUpdate(
              DailyUsageCompanion.insert(
                childId: childId,
                day: day,
                deviceId: device,
                secondsUsed: Value(merged.secondsUsed),
                extraSecondsGranted: Value(merged.extraSecondsGranted),
                dirty: const Value(0),
                remoteId: Value(item['id'] as String),
              ),
            );
        out.changed = true;
        return true;
    }
    return true;
  }
}

class _Row {
  _Row(
    this.dirty,
    this.remoteId,
    this.body, {
    required this.key,
    required this.find,
    this.appendOnly = false,
    this.updateFound = _always,
  });

  final int dirty;
  final String? remoteId;
  final Map<String, dynamic> body;
  final String key;
  final (String, Map<String, dynamic>) find;
  final bool appendOnly;

  /// Whether a record found by [find] after a duplicate gets this body.
  final bool Function(Map<String, dynamic> found) updateFound;

  static bool _always(Map<String, dynamic> _) => true;
}

class _PullContext {
  _PullContext(this.device);
  final String device;

  /// The `play_sessions` row pulled rounds attach to (one per run).
  int? session;
}

int _int(Object? v) => v is num ? v.toInt() : 0;

DateTime? _date(Object? v) =>
    v is String && v.isNotEmpty ? DateTime.tryParse(v) : null;

/// PocketBase's date format, in UTC.
String _iso(DateTime d) => d.toUtc().toIso8601String().replaceFirst('T', ' ');
