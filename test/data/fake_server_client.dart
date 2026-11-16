import 'package:number_ninja/data/sync/server_client.dart';
import 'package:number_ninja/data/sync/server_config.dart';

/// A [ServerClient] that answers [result] and counts calls (FEAT-12).
class FakeServerClient implements ServerClient {
  FakeServerClient(this.config, {this.result = ServerHealth.ok});

  @override
  final ServerConfig config;
  ServerHealth result;
  int calls = 0;

  @override
  Future<ServerHealth> health() async {
    calls++;
    return config.isConfigured ? result : ServerHealth.notConfigured;
  }
}
