import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/sync_merge.dart';

void main() {
  final t1 = DateTime.utc(2027, 1, 5, 9);
  final t2 = DateTime.utc(2027, 1, 5, 10);

  group('rounds (AC-2)', () {
    test('unknown inserts', () {
      expect(
        mergeRound(known: false, localFinishedAt: null, remoteFinishedAt: t1),
        RoundMerge.insert,
      );
    });
    test('finish moves from empty to set', () {
      expect(
        mergeRound(known: true, localFinishedAt: null, remoteFinishedAt: t1),
        RoundMerge.finish,
      );
    });
    test('an unfinished remote copy never clears a local finish', () {
      expect(
        mergeRound(known: true, localFinishedAt: t1, remoteFinishedAt: null),
        RoundMerge.keep,
      );
      expect(
        mergeRound(known: true, localFinishedAt: t1, remoteFinishedAt: t2),
        RoundMerge.keep,
      );
      expect(
        mergeRound(known: true, localFinishedAt: null, remoteFinishedAt: null),
        RoundMerge.keep,
      );
    });
  });

  test('attempts by uuid are never doubled (AC-2)', () {
    expect(attemptIsNew(known: false), isTrue);
    expect(attemptIsNew(known: true), isFalse);
  });

  test('badge: earliest date wins both ways (AC-2)', () {
    expect(mergeBadge(null, t1), BadgeMerge.insert);
    expect(mergeBadge(t2, t1), BadgeMerge.takeRemote);
    expect(mergeBadge(t1, t2), BadgeMerge.pushLocal);
    expect(mergeBadge(t1, t1), BadgeMerge.keep);
  });

  test('fields: later time wins, ties keep the server (AC-2)', () {
    final w = mergeFields(
      {'a': t2, 'b': t1, 'c': t1, 'd': t1},
      {'a': t1, 'b': t2, 'c': t1, 'e': t1},
    );
    expect(w, {
      'a': FieldWinner.local,
      'b': FieldWinner.remote,
      'c': FieldWinner.remote,
      'd': FieldWinner.local,
      'e': FieldWinner.remote,
    });
  });

  test('usage: max per device row, sum over devices (AC-2)', () {
    expect(mergeUsage(null, const UsageCounts(5, 0)), const UsageCounts(5, 0));
    expect(
      mergeUsage(const UsageCounts(300, 0), const UsageCounts(200, 600)),
      const UsageCounts(300, 600),
    );
    expect(
      dayTotal(const [UsageCounts(300, 60), UsageCounts(200, 0)]),
      const UsageCounts(500, 60),
    );
  });
}
