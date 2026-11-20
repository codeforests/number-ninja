import 'dart:io';

import 'package:flutter/services.dart';

import '../domain/crash.dart';

/// App version and device for crash reports (FEAT-24 AD-5), from the
/// `brainbubblz/device` channel in `MainActivity.kt`. Off Android (tests,
/// desktop) it falls back to the OS name and `--dart-define=APP_VERSION`.
class DeviceInfo {
  const DeviceInfo();

  static const _channel = MethodChannel('brainbubblz/device');
  static const _defineVersion = String.fromEnvironment(
    'APP_VERSION',
    defaultValue: 'unknown',
  );

  Future<CrashInfo> load() async {
    try {
      final m = await _channel.invokeMapMethod<String, Object?>('info');
      if (m != null) {
        final name = m['versionName'] ?? 'unknown';
        final code = m['versionCode'];
        final maker = '${m['manufacturer'] ?? ''}'.trim();
        final model = '${m['model'] ?? ''}'.trim();
        return CrashInfo(
          appVersion: code == null ? '$name' : '$name+$code',
          os: 'Android ${m['release'] ?? '?'} (SDK ${m['sdk'] ?? '?'})',
          device: [maker, model].where((s) => s.isNotEmpty).join(' '),
        );
      }
    } on Object {
      // No channel here: fall through.
    }
    return CrashInfo(
      appVersion: _defineVersion,
      os: Platform.operatingSystem,
      device: 'unknown',
    );
  }
}
