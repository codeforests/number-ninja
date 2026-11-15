import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/domain/screen_time.dart';

/// In-memory [UsageStore] for the AC-1 tests.
class FakeUsageStore implements UsageStore {
  final used = <String, int>{};
  int limitMinutes = 20;
  final extra = <String, int>{};

  @override
  Future<String?> latestDay() async {
    if (used.isEmpty) return null;
    return (used.keys.toList()..sort()).last;
  }

  @override
  Future<void> addSeconds(String day, int seconds) async {
    used[day] = (used[day] ?? 0) + seconds;
  }

  @override
  Future<ScreenTimeStatus> status(String day) async => ScreenTimeStatus(
    day: day,
    usedSeconds: used[day] ?? 0,
    limitMinutes: limitMinutes,
    extraSeconds: extra[day] ?? 0,
  );
}

void main() {
  late FakeUsageStore store;
  late DateTime now;
  late Duration elapsed;
  late ScreenTimeClock clock;

  setUp(() {
    store = FakeUsageStore();
    now = DateTime(2027, 1, 5, 9);
    elapsed = Duration.zero;
    clock = ScreenTimeClock(store, now: () => now, elapsed: () => elapsed);
  });

  void advance(Duration d) {
    elapsed += d;
    now = now.add(d);
  }

  group('dayKey and effectiveDay (AC-2)', () {
    test('dayKey pads to yyyy-MM-dd in local time', () {
      expect(dayKey(DateTime(2027, 1, 5, 23, 59)), '2027-01-05');
      expect(dayKey(DateTime(2027, 12, 31)), '2027-12-31');
    });

    test('effectiveDay takes the later of today and the latest record', () {
      final now = DateTime(2027, 1, 5, 9);
      expect(effectiveDay(now, null), '2027-01-05');
      expect(effectiveDay(now, '2027-01-04'), '2027-01-05'); // earlier
      expect(effectiveDay(now, '2027-01-05'), '2027-01-05'); // same
      expect(effectiveDay(now, '2027-01-06'), '2027-01-06'); // later
      expect(effectiveDay(now, '2028-01-01'), '2028-01-01');
    });
  });

  group('ScreenTimeStatus', () {
    ScreenTimeStatus s(int used, {int limit = 20, int extra = 0}) =>
        ScreenTimeStatus(
          day: '2027-01-05',
          usedSeconds: used,
          limitMinutes: limit,
          extraSeconds: extra,
        );

    test('minutes left round up and stop at 0', () {
      expect(s(0).minutesLeft, 20);
      expect(s(1).minutesLeft, 20);
      expect(s(60).minutesLeft, 19);
      expect(s(19 * 60 + 50).minutesLeft, 1);
      expect(s(20 * 60).minutesLeft, 0);
      expect(s(30 * 60).secondsLeft, 0);
    });

    test('warning is the last 2 minutes; timeUp at 0', () {
      expect(s(18 * 60 - 1).warning, isFalse);
      expect(s(18 * 60).warning, isTrue);
      expect(s(20 * 60 - 1).warning, isTrue);
      expect(s(20 * 60).warning, isFalse);
      expect(s(20 * 60).timeUp, isTrue);
      expect(s(20 * 60 - 1).timeUp, isFalse);
    });

    test('extra seconds add to the allowance', () {
      final st = s(20 * 60, extra: 600);
      expect(st.allowanceSeconds, 30 * 60);
      expect(st.minutesLeft, 10);
      expect(st.timeUp, isFalse);
    });
  });

  group('ScreenTimeClock (AC-1)', () {
    test('adds elapsed seconds only between start and stop', () async {
      advance(const Duration(seconds: 30)); // not started
      expect((await clock.flush()).usedSeconds, 0);

      clock.start();
      advance(const Duration(seconds: 10));
      expect((await clock.flush()).usedSeconds, 10);

      advance(const Duration(seconds: 5));
      clock.stop();
      advance(const Duration(minutes: 5)); // stopped
      expect((await clock.flush()).usedSeconds, 15);
      expect((await clock.flush()).usedSeconds, 15);

      clock.start();
      advance(const Duration(seconds: 3));
      expect((await clock.flush()).usedSeconds, 18);
    });

    test('carries sub-second remainders to the next flush', () async {
      clock.start();
      advance(const Duration(milliseconds: 1600));
      expect((await clock.flush()).usedSeconds, 1);
      advance(const Duration(milliseconds: 600));
      expect((await clock.flush()).usedSeconds, 2);
      advance(const Duration(milliseconds: 700));
      expect((await clock.flush()).usedSeconds, 2);
      advance(const Duration(milliseconds: 100));
      expect((await clock.flush()).usedSeconds, 3);
    });

    test('crosses midnight into the new day', () async {
      now = DateTime(2027, 1, 5, 23, 59, 50);
      clock.start();
      advance(const Duration(seconds: 5));
      expect((await clock.flush()).day, '2027-01-05');
      advance(const Duration(seconds: 10));
      final st = await clock.flush();
      expect(st.day, '2027-01-06');
      expect(st.usedSeconds, 10);
      expect(store.used['2027-01-05'], 5);
    });

    test('with the clock set back a day, keeps adding to the later day '
        '(TIM-05)', () async {
      clock.start();
      advance(const Duration(seconds: 100));
      expect((await clock.flush()).usedSeconds, 100);

      now = now.subtract(const Duration(days: 1));
      advance(const Duration(seconds: 20));
      final st = await clock.flush();
      expect(st.day, '2027-01-05');
      expect(st.usedSeconds, 120);
      expect(store.used.keys, ['2027-01-05']);
    });

    test('start and stop are idempotent', () async {
      clock.start();
      advance(const Duration(seconds: 4));
      clock.start();
      advance(const Duration(seconds: 4));
      clock.stop();
      clock.stop();
      expect((await clock.flush()).usedSeconds, 8);
      expect(clock.running, isFalse);
    });
  });
}
