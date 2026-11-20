import 'dart:convert';

import 'package:crypto/crypto.dart';

/// Crash reports (FEAT-24, CRS-01..07): pure helpers shared by the reporter
/// and the repository.

/// Caps (AD-7, mirrored by the server's field limits, AD-10).
const crashMessageMax = 1000;
const crashStackMax = 8000;
const crashTextMax = 128;

/// Unsent rows kept on the device (AD-8) and rows per send (AD-9).
const crashMaxUnsent = 30;
const crashSendBatch = 10;

/// Sent rows are deleted after this (AD-9).
const crashKeepSent = Duration(days: 7);

/// What every report says about the app and device (AD-5). No identifier.
class CrashInfo {
  const CrashInfo({
    required this.appVersion,
    required this.os,
    required this.device,
  });

  /// `versionName+versionCode`, e.g. `2.2.0+22`, or `unknown`.
  final String appVersion;

  /// e.g. `Android 14 (SDK 34)`.
  final String os;

  /// e.g. `samsung SM-X200`.
  final String device;
}

/// One captured error, before it is grouped into a row.
class CrashEntry {
  const CrashEntry({
    required this.type,
    required this.message,
    required this.stack,
    required this.screen,
    required this.at,
  });

  final String type;
  final String message;
  final String stack;

  /// Route pattern, e.g. `/quiz/:topicId` (AD-6), or empty.
  final String screen;
  final DateTime at;
}

final _column = RegExp(r':(\d+):\d+\)');

/// Grouping key (AD-8): sha1 of the type and the first 5 stack frames,
/// with column numbers dropped.
String crashSignature(String type, String stack) {
  final frames = stack
      .split('\n')
      .map((l) => l.trim())
      .where((l) => l.isNotEmpty)
      .take(5)
      .map((l) => l.replaceAllMapped(_column, (m) => ':${m[1]})'));
  return sha1.convert(utf8.encode([type, ...frames].join('\n'))).toString();
}

/// Replaces every name (case-insensitive) with `<name>` and the email with
/// `<email>` (AD-7). Names shorter than 2 characters are left alone, so a
/// one-letter nickname doesn't blank out every "a" in a stack trace.
String scrubText(String text, Iterable<String> names, String? email) {
  var out = text;
  if (email != null && email.trim().isNotEmpty) {
    out = out.replaceAll(
      RegExp(RegExp.escape(email.trim()), caseSensitive: false),
      '<email>',
    );
  }
  // Longest first, so "Mia Tan" goes before "Mia".
  final sorted =
      names.map((n) => n.trim()).where((n) => n.length >= 2).toSet().toList()
        ..sort((a, b) => b.length.compareTo(a.length));
  for (final name in sorted) {
    out = out.replaceAll(
      RegExp(RegExp.escape(name), caseSensitive: false),
      '<name>',
    );
  }
  return out;
}

/// The stack capped at [max] characters, keeping the top frames whole.
String trimStack(String stack, [int max = crashStackMax]) {
  if (stack.length <= max) return stack;
  final cut = stack.substring(0, max);
  final lastLine = cut.lastIndexOf('\n');
  return lastLine > 0 ? cut.substring(0, lastLine) : cut;
}

/// The message capped at [max] characters.
String trimMessage(String message, [int max = crashMessageMax]) =>
    message.length <= max ? message : message.substring(0, max);

/// Any other text field capped at [crashTextMax].
String trimText(String text) =>
    text.length <= crashTextMax ? text : text.substring(0, crashTextMax);
