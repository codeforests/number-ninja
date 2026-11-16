import 'dart:async';

import 'package:number_ninja/data/sync/sync_controller.dart';

class FakeTimer implements Timer {
  FakeTimer(this.duration, this.run);
  final Duration duration;
  final void Function() run;
  bool _active = true;

  @override
  void cancel() => _active = false;

  @override
  bool get isActive => _active;

  @override
  int get tick => 0;
}

/// Timers the test fires by hand (NFR-08).
class FakeSyncTimers implements SyncTimers {
  final onces = <FakeTimer>[];
  final everys = <FakeTimer>[];

  @override
  Timer once(Duration after, void Function() run) {
    final t = FakeTimer(after, run);
    onces.add(t);
    return t;
  }

  @override
  Timer every(Duration period, void Function() run) {
    final t = FakeTimer(period, run);
    everys.add(t);
    return t;
  }

  List<Duration> get retryDelays => [for (final t in onces) t.duration];

  void fireRetry() {
    final t = onces.lastWhere((t) => t.isActive);
    t.cancel();
    t.run();
  }

  void firePeriodic() => everys.lastWhere((t) => t.isActive).run();
}
