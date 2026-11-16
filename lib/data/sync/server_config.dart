/// Where the sync server is (FEAT-12, ADR-02). The URL is baked in at build
/// time with `--dart-define=SERVER_URL=https://<SERVER_HOSTNAME>`; there is no
/// hostname in the code. Only `https://` URLs are accepted (NFR-12).
class ServerConfig {
  const ServerConfig._(this.url);

  /// No server: the app works offline only, as in v1.
  static const none = ServerConfig._(null);

  /// The server's base URL, or null when not set up.
  final Uri? url;

  bool get isConfigured => url != null;

  /// The hostname shown to the parent, or null.
  String? get host => url?.host;

  /// Parses [raw]; anything but an absolute `https://` URL with a host is
  /// [none].
  factory ServerConfig.parse(String raw) {
    final uri = Uri.tryParse(raw.trim());
    if (uri == null || uri.scheme != 'https' || uri.host.isEmpty) return none;
    return ServerConfig._(uri.replace(path: '', query: null, fragment: null));
  }

  /// A PocketBase on this machine over plain http, for the live sync test
  /// against the CI server (FEAT-14 AC-7). Loopback only, so NFR-12 holds.
  factory ServerConfig.loopback(int port) =>
      ServerConfig._(Uri(scheme: 'http', host: '127.0.0.1', port: port));

  /// From the `SERVER_URL` build define (empty in tests and local builds).
  factory ServerConfig.fromEnvironment() =>
      ServerConfig.parse(const String.fromEnvironment('SERVER_URL'));
}
