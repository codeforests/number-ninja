import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'data/child_repository.dart';
import 'data/crash_reporter.dart';
import 'data/device_info.dart';
import 'data/database.dart';
import 'features/family/change_child.dart';
import 'data/pin_repository.dart';
import 'data/setup_repository.dart';
import 'domain/clock.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  // FEAT-24 AD-11: catch errors from the start; they wait in memory until
  // the app attaches the database.
  final crash = CrashReporter(clock: systemClock)..install();
  crash.info = await const DeviceInfo().load();
  final db = AppDatabase();
  final setupStep = await SetupRepository(db).step();
  final pinSet = await PinRepository(db, clock: systemClock).hasPin();
  final children = ChildRepository(db, clock: systemClock);
  final childId = await children.current();
  final choosing = await pickerShows(children);
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        crashReporterProvider.overrideWithValue(crash),
        startChildProvider.overrideWithValue(childId),
        appSessionProvider.overrideWithValue(
          AppSession(
            setupStep: setupStep,
            pinSet: pinSet,
            clock: systemClock,
            choosingChild: choosing,
          ),
        ),
      ],
      child: const NumberNinjaApp(),
    ),
  );
}
