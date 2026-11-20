import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'data/child_repository.dart';
import 'data/database.dart';
import 'data/pin_repository.dart';
import 'data/profile_repository.dart';
import 'domain/clock.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  final hasPin = await PinRepository(db, clock: systemClock).hasPin();
  final profilePending = await ProfileRepository(
    db,
    clock: systemClock,
  ).pending();
  final childId = await ChildRepository(db, clock: systemClock).current();
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        startChildProvider.overrideWithValue(childId),
        appSessionProvider.overrideWithValue(
          AppSession(
            hasPin: hasPin,
            profilePending: profilePending,
            clock: systemClock,
          ),
        ),
      ],
      child: const NumberNinjaApp(),
    ),
  );
}
