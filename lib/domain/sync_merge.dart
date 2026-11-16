/// Merge rules for progress sync (ADR-04, SYN-04, FEAT-14). Pure functions:
/// the sync service applies what they decide.
library;

/// What a pulled round does to the local copy.
enum RoundMerge {
  /// Unknown here: insert it.
  insert,

  /// Known and unfinished here, finished remotely: take the finish fields.
  finish,

  /// Nothing to change. A finish only moves from empty to set, so an
  /// unfinished remote copy never clears a local finish.
  keep,
}

RoundMerge mergeRound({
  required bool known,
  required DateTime? localFinishedAt,
  required DateTime? remoteFinishedAt,
}) {
  if (!known) return RoundMerge.insert;
  if (localFinishedAt == null && remoteFinishedAt != null) {
    return RoundMerge.finish;
  }
  return RoundMerge.keep;
}

/// Attempts never change: insert when the uuid is unknown, else nothing.
bool attemptIsNew({required bool known}) => !known;

/// What a pulled badge does to the local copy: the earliest date wins.
enum BadgeMerge {
  /// Not earned here: insert with the remote date.
  insert,

  /// Remote is earlier: take its date.
  takeRemote,

  /// Local is earlier: keep it and send it to the server again.
  pushLocal,

  /// Same date.
  keep,
}

BadgeMerge mergeBadge(DateTime? localEarnedAt, DateTime remoteEarnedAt) {
  if (localEarnedAt == null) return BadgeMerge.insert;
  if (remoteEarnedAt.isBefore(localEarnedAt)) return BadgeMerge.takeRemote;
  if (localEarnedAt.isBefore(remoteEarnedAt)) return BadgeMerge.pushLocal;
  return BadgeMerge.keep;
}

enum FieldWinner { local, remote }

/// Per profile or settings field, the later change wins; equal times keep
/// the server's. A field only one side has goes to that side.
Map<String, FieldWinner> mergeFields(
  Map<String, DateTime> localTimes,
  Map<String, DateTime> remoteTimes,
) => {
  for (final f in {...localTimes.keys, ...remoteTimes.keys})
    f: switch ((localTimes[f], remoteTimes[f])) {
      (_, null) => FieldWinner.local,
      (null, _) => FieldWinner.remote,
      (final l?, final r?) =>
        l.isAfter(r) ? FieldWinner.local : FieldWinner.remote,
    },
};

/// One device's screen-time row for one day.
class UsageCounts {
  const UsageCounts(this.secondsUsed, this.extraSecondsGranted);

  final int secondsUsed;
  final int extraSecondsGranted;

  @override
  bool operator ==(Object other) =>
      other is UsageCounts &&
      other.secondsUsed == secondsUsed &&
      other.extraSecondsGranted == extraSecondsGranted;

  @override
  int get hashCode => Object.hash(secondsUsed, extraSecondsGranted);

  @override
  String toString() => 'UsageCounts($secondsUsed, $extraSecondsGranted)';
}

/// Another device's row: both counters only grow, so take the larger of
/// each.
UsageCounts mergeUsage(UsageCounts? local, UsageCounts remote) => local == null
    ? remote
    : UsageCounts(
        local.secondsUsed > remote.secondsUsed
            ? local.secondsUsed
            : remote.secondsUsed,
        local.extraSecondsGranted > remote.extraSecondsGranted
            ? local.extraSecondsGranted
            : remote.extraSecondsGranted,
      );

/// A day's total over every device's row (the limit holds across tablets).
UsageCounts dayTotal(Iterable<UsageCounts> rows) => UsageCounts(
  rows.fold(0, (s, r) => s + r.secondsUsed),
  rows.fold(0, (s, r) => s + r.extraSecondsGranted),
);
