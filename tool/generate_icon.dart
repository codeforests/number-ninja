/// Writes the launcher icon sources to `assets/icon/`. Then
/// `dart run flutter_launcher_icons` writes the Android mipmaps.
///
///   dart run tool/generate_icon.dart [out-dir]
library;

import 'dart:io';

import 'icon/draw.dart';

void main(List<String> args) {
  final dir = args.isEmpty ? 'assets/icon' : args.first;
  Directory(dir).createSync(recursive: true);
  for (final e in buildIcons().entries) {
    File('$dir/${e.key}.png').writeAsBytesSync(e.value);
    stdout.writeln('$dir/${e.key}.png ${e.value.length} bytes');
  }
}
