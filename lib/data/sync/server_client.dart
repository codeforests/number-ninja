import 'dart:async';

import 'package:pocketbase/pocketbase.dart';

import 'server_config.dart';

/// Result of a server check (FEAT-12, SCR-11 "Server" row).
enum ServerHealth { ok, unreachable, notConfigured }

/// The app's view of the sync server. FEAT-12 has one call; FEAT-13/14 add
/// sign-in and sync. Nothing calls it at start-up or on child screens
/// (NFR-11): only when the parent asks.
abstract class ServerClient {
  ServerConfig get config;
  Future<ServerHealth> health();
}

/// [ServerClient] over the `pocketbase` package.
class PocketBaseServerClient implements ServerClient {
  PocketBaseServerClient(
    this.config, {
    this.timeout = const Duration(seconds: 5),
  });

  @override
  final ServerConfig config;
  final Duration timeout;

  late final PocketBase _pb = PocketBase(config.url.toString());

  @override
  Future<ServerHealth> health() async {
    if (!config.isConfigured) return ServerHealth.notConfigured;
    try {
      final result = await _pb.health.check().timeout(timeout);
      return result.code == 200 ? ServerHealth.ok : ServerHealth.unreachable;
    } on Object {
      return ServerHealth.unreachable;
    }
  }
}
