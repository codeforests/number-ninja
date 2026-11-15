import 'clock.dart';

/// Screen-time rules (TIM-01..06, design §5). Pure Dart: no timers here;
/// the caller drives [ScreenTimeClock.flush].

/// The day key used by `daily_usage`: `yyyy-MM-dd` in local time.
String dayKey(DateTime t) {
  String two(int n) => n.toString().padLeft(2, '0');
  return '${t.year.toString().padLeft(4, '0')}-${two(t.month)}-${two(t.day)}';
}

/// "Today" for screen time: the later of the device date and the latest day
/// already recorded, so setting the clock back can't reopen a used day
/// (TIM-05). The key format sorts as a string.
String effectiveDay(DateTime now, String? latestRecorded) {
  final today = dayKey(now);
  if (latestRecorded == null) return today;
  return latestRecorded.compareTo(today) > 0 ? latestRecorded : today;
}

/// The warning shows when this much time is left (TIM-03).
const warnAt = Duration(minutes: 2);

/// A question left open may run at most this long after time is up (TIM-03).
const graceCap = Duration(minutes: 2);

/// The daily limit a parent can set, in minutes (D5, TIM-04).
const minDailyLimit = 5;
const maxDailyLimit = 120;

/// How often used time is written to the database (design §5).
const flushEvery = Duration(seconds: 10);

/// One day's usage against its allowance.
class ScreenTimeStatus {
  const ScreenTimeStatus({
    required this.day,
    required this.usedSeconds,
    required this.limitMinutes,
    required this.extraSeconds,
  });

  final String day;
  final int usedSeconds;
  final int limitMinutes;
  final int extraSeconds;

  /// Daily limit plus extra time granted today.
  int get allowanceSeconds => limitMinutes * 60 + extraSeconds;

  int get secondsLeft {
    final left = allowanceSeconds - usedSeconds;
    return left < 0 ? 0 : left;
  }

  /// Rounded up, so "1 min left" until the very last second.
  int get minutesLeft => (secondsLeft + 59) ~/ 60;

  bool get warning => secondsLeft > 0 && secondsLeft <= warnAt.inSeconds;

  bool get timeUp => secondsLeft == 0;

  @override
  bool operator ==(Object other) =>
      other is ScreenTimeStatus &&
      other.day == day &&
      other.usedSeconds == usedSeconds &&
      other.limitMinutes == limitMinutes &&
      other.extraSeconds == extraSeconds;

  @override
  int get hashCode => Object.hash(day, usedSeconds, limitMinutes, extraSeconds);

  @override
  String toString() =>
      'ScreenTimeStatus($day, used $usedSeconds s, limit $limitMinutes min, '
      'extra $extraSeconds s)';
}

/// Where usage is kept (implemented by the data layer).
abstract interface class UsageStore {
  /// The latest day with a usage row, or null.
  Future<String?> latestDay();

  Future<void> addSeconds(String day, int seconds);

  Future<ScreenTimeStatus> status(String day);
}

/// Counts foreground seconds between [start] and [stop] and adds them to
/// the effective day on each [flush] (TIM-01, TIM-05).
class ScreenTimeClock {
  ScreenTimeClock(this._store, {required this.now, required this.elapsed});

  final UsageStore _store;
  final Clock now;

  /// A monotonic source of elapsed time, such as a running [Stopwatch].
  final Duration Function() elapsed;

  bool _running = false;
  Duration _mark = Duration.zero;
  Duration _pending = Duration.zero;

  bool get running => _running;

  void start() {
    if (_running) return;
    _running = true;
    _mark = elapsed();
  }

  /// Stops counting; time counted so far is written on the next [flush].
  void stop() {
    if (!_running) return;
    _take();
    _running = false;
  }

  void _take() {
    final e = elapsed();
    _pending += e - _mark;
    _mark = e;
  }

  /// The effective day right now.
  Future<String> today() async => effectiveDay(now(), await _store.latestDay());

  /// Writes whole counted seconds (keeping the remainder) and returns the
  /// day's status.
  Future<ScreenTimeStatus> flush() async {
    if (_running) _take();
    final whole = _pending.inSeconds;
    _pending -= Duration(seconds: whole);
    final day = await today();
    if (whole > 0) await _store.addSeconds(day, whole);
    return _store.status(day);
  }
}
