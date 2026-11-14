import 'package:flutter_riverpod/flutter_riverpod.dart';
import 'package:material_ui/material_ui.dart';

import 'app.dart';
import 'data/database.dart';
import 'data/pin_repository.dart';
import 'domain/clock.dart';
import 'providers.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final db = AppDatabase();
  final hasPin = await PinRepository(db, clock: systemClock).hasPin();
  runApp(
    ProviderScope(
      overrides: [
        databaseProvider.overrideWithValue(db),
        appSessionProvider.overrideWithValue(
          AppSession(hasPin: hasPin, clock: systemClock),
        ),
      ],
      child: const NumberNinjaApp(),
    ),
  );
}
