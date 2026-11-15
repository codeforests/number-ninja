/// Writes the sound effects (PRC-11) to `assets/sounds/`.
///
///   dart run tool/generate_sounds.dart [out-dir]
library;

import 'dart:io';

import 'sounds/synth.dart';

void main(List<String> args) {
  final dir = args.isEmpty ? 'assets/sounds' : args.first;
  Directory(dir).createSync(recursive: true);
  for (final e in buildSounds().entries) {
    File('$dir/${e.key}.wav').writeAsBytesSync(e.value);
    stdout.writeln('$dir/${e.key}.wav ${e.value.length} bytes');
  }
}
