// FEAT-29 AC-8 (BNK-13, AD-4): signed in, the bank's file URL carries a
// file token; signed out, no token is asked for.
import 'dart:convert';

import 'package:flutter_test/flutter_test.dart';
import 'package:http/http.dart' as http;
import 'package:http/testing.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';
import 'package:number_ninja/data/sync/token_store.dart';

http.Response json(Object body) => http.Response(
  jsonEncode(body),
  200,
  headers: {'content-type': 'application/json'},
);

/// A JWT the SDK accepts as unexpired (it checks `exp` locally).
final jwt = [
  base64Url.encode(utf8.encode('{"alg":"HS256","typ":"JWT"}')),
  base64Url.encode(utf8.encode('{"id":"u1","exp":4102444800}')),
  'sig',
].join('.').replaceAll('=', '');

void main() {
  late List<http.Request> requests;
  late PocketBaseServerClient client;

  setUp(() {
    requests = [];
    client = PocketBaseServerClient(
      ServerConfig.parse('https://api.example.test'),
      store: MemoryTokenStore(),
      httpClientFactory: () => MockClient((r) async {
        requests.add(r);
        final path = r.url.path;
        if (path.endsWith('/auth-with-password')) {
          return json({
            'token': jwt,
            'record': {
              'id': 'u1',
              'collectionId': '_pb_users_auth_',
              'collectionName': 'users',
              'email': 'parent@example.test',
              'verified': true,
            },
          });
        }
        if (path == '/api/files/token') return json({'token': 'file-tok'});
        if (path == '/api/collections/banks/records') {
          return json({
            'page': 1,
            'perPage': 1,
            'totalItems': 1,
            'totalPages': 1,
            'items': [
              {
                'id': 'b1',
                'collectionId': 'pbc_banks',
                'collectionName': 'banks',
                'version': 9,
                'format': 1,
                'sha256': 'abc',
                'file': 'bank_9.json',
              },
            ],
          });
        }
        return http.Response('not found', 404);
      }),
    );
  });

  test('signed in: latestBank asks for a file token', () async {
    await client.signIn('parent@example.test', 'secret-pass-123');
    final info = await client.latestBank(maxFormat: 1);
    expect(requests.map((r) => r.url.path), contains('/api/files/token'));
    expect(info!.fileUrl.queryParameters['token'], 'file-tok');
    expect(info.fileUrl.path, '/api/files/pbc_banks/b1/bank_9.json');
  });

  test('signed out: no token call, no token in the URL', () async {
    final info = await client.latestBank(maxFormat: 1);
    expect(
      requests.map((r) => r.url.path),
      isNot(contains('/api/files/token')),
    );
    expect(info!.fileUrl.queryParameters, isNot(contains('token')));
  });
}
