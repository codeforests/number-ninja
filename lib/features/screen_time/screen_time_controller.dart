import 'dart:async';

import 'package:flutter/foundation.dart' show ValueListenable;
import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import '../../data/usage_repository.dart';
import '../../domain/clock.dart';
import '../../domain/screen_time.dart';
import '../../providers.dart';

/// The elapsed-time source for screen time; a fake in tests.
final elapsedProvider = Provider<Duration Function()>((ref) {
  final watch = Stopwatch()..start();
  return () => watch.elapsed;
});

/// Screen time for the app (TIM-01..06). The router and the screens listen
/// to it.
final screenTimeProvider = Provider<ScreenTimeController>((ref) {
  final c = ScreenTimeController(
    ref.watch(usageRepositoryProvider),
    clock: ref.watch(clockProvider),
    elapsed: ref.watch(elapsedProvider),
  );
  ref.onDispose(c.dispose);
  // Screen time synced from her other tablets counts today (FEAT-14).
  ref.listen(syncDataVersionProvider, (_, _) => c.flush());
  return c;
});

/// Drives a [ScreenTimeClock] with a timer and the app lifecycle, and works
/// out whether the child screens are locked (design: Controller).
class ScreenTimeController extends ChangeNotifier {
  ScreenTimeController(
    this._repo, {
    required this.clock,
    required Duration Function() elapsed,
  }) {
    _clock = ScreenTimeClock(_repo, now: clock, elapsed: elapsed);
    _timer = Timer.periodic(flushEvery, (_) => flush());
    _lifecycle = AppLifecycleListener(
      onHide: () {
        _foreground = false;
        _gate();
        flush();
      },
      onShow: () {
        _foreground = true;
        _gate();
      },
    );
    flush();
  }

  final UsageRepository _repo;
  final Clock clock;
  late final ScreenTimeClock _clock;
  late final Timer _timer;
  late final AppLifecycleListener _lifecycle;
  final _warnings = StreamController<void>.broadcast();

  ScreenTimeStatus? _status;
  bool _childRoute = false;
  bool _foreground = true;
  bool _disposed = false;

  /// Screens holding a question open (quiz, result).
  int _holds = 0;

  /// When time ran out today, and whether a question was open then.
  DateTime? _timeUpAt;
  bool _graceGranted = false;
  bool _warned = false;
  final _locked = ValueNotifier(false);

  /// Null until the first read.
  ScreenTimeStatus? get status => _status;

  /// Fires once each time the last 2 minutes start (TIM-03).
  Stream<void> get warnings => _warnings.stream;

  bool get counting => _clock.running;

  /// Time is up but she may finish the question she is on (TIM-03).
  bool get holding =>
      _status != null &&
      _status!.timeUp &&
      _graceGranted &&
      _holds > 0 &&
      _timeUpAt != null &&
      clock().difference(_timeUpAt!) < graceCap;

  /// Child screens show SCR-07 (TIM-02).
  bool get locked => _locked.value;

  /// Notifies only when [locked] changes; the router listens to this, so
  /// a new status doesn't rebuild the route stack.
  ValueListenable<bool> get lockedListenable => _locked;

  /// Counting runs only on child routes in the foreground (TIM-01).
  void setChildRoute(bool child) {
    if (_childRoute == child) return;
    _childRoute = child;
    _gate();
  }

  void _gate() {
    if (_childRoute && _foreground) {
      _clock.start();
    } else {
      _clock.stop();
    }
  }

  /// Writes counted time and refreshes [status].
  Future<void> flush() async {
    final s = await _clock.flush();
    _apply(s);
  }

  /// A screen with a question open calls this; pair with [releaseHold].
  void holdQuestion() {
    _holds++;
    _recompute();
  }

  void releaseHold() {
    if (_holds > 0) _holds--;
    if (_holds == 0) _graceGranted = false;
    _recompute();
  }

  /// Adds extra minutes for today (TIM-04).
  Future<void> grantExtra(int minutes) async {
    await _repo.grantExtra(await _clock.today(), minutes);
    await flush();
  }

  /// Saves the daily limit (5–120, D5) and applies it today.
  Future<void> setDailyLimit(int minutes) async {
    await _repo.setDailyLimit(minutes);
    await flush();
  }

  void _apply(ScreenTimeStatus s) {
    if (_disposed) return;
    final changed = s != _status;
    if (s.timeUp) {
      if (_timeUpAt == null) {
        _timeUpAt = clock();
        _graceGranted = _holds > 0;
      }
    } else {
      _timeUpAt = null;
      _graceGranted = false;
    }
    if (!s.warning) {
      _warned = false;
    } else if (!_warned && _childRoute) {
      _warned = true;
      _warnings.add(null);
    }
    _status = s;
    if (!_recompute() && changed) notifyListeners();
  }

  /// Updates [locked]; notifies and returns true when it changed.
  bool _recompute() {
    if (_disposed) return false;
    final now = _status != null && _status!.timeUp && !holding;
    if (now == _locked.value) return false;
    _locked.value = now;
    notifyListeners();
    return true;
  }

  @override
  void dispose() {
    _disposed = true;
    _timer.cancel();
    _lifecycle.dispose();
    _warnings.close();
    _locked.dispose();
    super.dispose();
  }
}
