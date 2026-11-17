// TEMPORARY probe (not for merge): the app's bank check against the live
// server, run from CI because this container can't reach it.
import 'dart:convert';
import 'dart:io';

import 'package:drift/native.dart';
import 'package:flutter/services.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:number_ninja/data/bank_store.dart';
import 'package:number_ninja/data/bank_updater.dart';
import 'package:number_ninja/data/database.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/data/sync/token_store.dart';

final _url = Platform.environment['PROBE_URL'];

void main() {
  test('probe', () async {
    final base = Uri.parse(_url!);
    for (final q in [
      'sort=-version&perPage=1',
      'sort=-version&perPage=1&filter=${Uri.encodeQueryComponent('format <= 1')}',
    ]) {
      final r = await http.get(base.resolve('/api/collections/banks/records?$q'));
      final body = r.body.length > 600 ? r.body.substring(0, 600) : r.body;
      print('GET $q -> ${r.statusCode} $body');
    }
    final client = PocketBaseServerClient(
      ServerConfig.parse(_url),
      store: MemoryTokenStore(),
      timeout: const Duration(seconds: 30),
    );
    try {
      final info = await client.latestBank(maxFormat: 1);
      print('latestBank -> ${info?.version} ${info?.format} ${info?.fileUrl}');
    } on Object catch (e) {
      print('latestBank threw $e');
    }
    final tmp = Directory.systemTemp.createTempSync('probe');
    final db = AppDatabase(NativeDatabase.memory());
    final store = BankStore(db, bundle: _V1Bundle(), dir: () async => Directory('${tmp.path}/banks'));
    final updater = BankUpdater(client: client, store: store, clock: DateTime.now);
    print('check -> ${await updater.check(force: true)} note ${(await store.checkState()).note}');
    final a = await store.loadActive();
    print('active -> ${a.bank.version} ${a.source}');
    await db.close();
  }, skip: _url == null ? 'PROBE_URL not set' : false, timeout: const Timeout(Duration(minutes: 2)));
}

/// The committed bank as version 1, like the m6.3 APK's bundled bank.
class _V1Bundle extends CachingAssetBundle {
  String _v1() {
    final j = jsonDecode(File('assets/questions/bank.json').readAsStringSync()) as Map<String, dynamic>;
    return jsonEncode({...j, 'version': 1});
  }

  @override
  Future<String> loadString(String key, {bool cache = true}) async => _v1();

  @override
  Future<ByteData> load(String key) async => ByteData.sublistView(utf8.encode(_v1()));
}
