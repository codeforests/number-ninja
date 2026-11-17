import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:number_ninja/data/bank_store.dart';
import 'package:number_ninja/data/bank_updater.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/domain/question.dart';

import 'fake_server_client.dart';

/// A bank store, updater and fake server on an in-memory database and a
/// temp directory (FEAT-15 tests). The bundled bank is the real asset.
class BankRig {
  BankRig({bool configured = true})
    : client = FakeServerClient(
        configured
            ? ServerConfig.parse('https://api.example.test')
            : ServerConfig.none,
      ) {
    store = BankStore(db, bundle: rootBundle, dir: () async => banksDir);
    updater = BankUpdater(client: client, store: store, clock: () => now);
  }

  final db = AppDatabase(NativeDatabase.memory());
  final Directory tmp = Directory.systemTemp.createTempSync('banks');
  Directory get banksDir => Directory('${tmp.path}/banks');
  final FakeServerClient client;
  late final BankStore store;
  late final BankUpdater updater;
  DateTime now = DateTime(2027, 1, 5, 9);

  /// The bundled bank as [version] (same questions unless given).
  Future<QuestionBank> bankAs(int version, {List<Question>? questions}) async {
    final b = await store.bundled();
    return QuestionBank(version: version, questions: questions ?? b.questions);
  }

  Future<void> dispose() async {
    await db.close();
    tmp.deleteSync(recursive: true);
  }
}
