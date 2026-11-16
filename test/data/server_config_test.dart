import 'package:flutter_test/flutter_test.dart';
import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';

/// FEAT-12 AC-4 (NFR-12): only an https URL configures the server.
void main() {
  test('empty is not configured', () {
    expect(ServerConfig.parse('').isConfigured, isFalse);
    expect(ServerConfig.parse('   ').isConfigured, isFalse);
  });

  test('plain http is rejected', () {
    expect(ServerConfig.parse('http://api.example.test').isConfigured, isFalse);
  });

  test('other junk is rejected', () {
    for (final raw in ['api.example.test', 'https://', 'ftp://x.test', ':::']) {
      expect(ServerConfig.parse(raw).isConfigured, isFalse, reason: raw);
    }
  });

  test('https://host is configured', () {
    final c = ServerConfig.parse('https://api.example.test/');
    expect(c.isConfigured, isTrue);
    expect(c.host, 'api.example.test');
    expect(c.url.toString(), 'https://api.example.test');
  });

  test('tests and local builds have no SERVER_URL', () {
    expect(ServerConfig.fromEnvironment().isConfigured, isFalse);
  });

  test('the real client does no network call when not configured', () async {
    final client = PocketBaseServerClient(ServerConfig.none);
    expect(await client.health(), ServerHealth.notConfigured);
  });

  test('the real client reports an unreachable server', () async {
    // Port 9 on localhost (discard) refuses the connection at once.
    final client = PocketBaseServerClient(
      ServerConfig.parse('https://127.0.0.1:9'),
      timeout: const Duration(seconds: 2),
    );
    expect(await client.health(), ServerHealth.unreachable);
  });
}
