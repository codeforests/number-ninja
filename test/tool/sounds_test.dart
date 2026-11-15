import 'dart:io';
import 'dart:typed_data';

import 'package:flutter_test/flutter_test.dart';

import '../../tool/sounds/synth.dart';

void main() {
  final built = buildSounds();

  test('there are four sounds (PRC-11)', () {
    expect(built.keys, unorderedEquals(['right', 'wrong', 'round', 'stars']));
  });

  for (final name in ['right', 'wrong', 'round', 'stars']) {
    test('$name.wav is a short mono 16-bit WAV matching the asset (AC-1)', () {
      final bytes = built[name]!;
      final d = ByteData.sublistView(bytes);
      String ascii(int at) => String.fromCharCodes(bytes.sublist(at, at + 4));
      expect(ascii(0), 'RIFF');
      expect(ascii(8), 'WAVE');
      expect(d.getUint16(20, Endian.little), 1, reason: 'PCM');
      expect(d.getUint16(22, Endian.little), 1, reason: 'mono');
      expect(d.getUint16(34, Endian.little), 16, reason: '16-bit');
      final rate = d.getUint32(24, Endian.little);
      final seconds = d.getUint32(40, Endian.little) / 2 / rate;
      expect(seconds, inInclusiveRange(0.1, 1.2));
      expect(bytes.length, lessThan(100 * 1024));
      expect(
        File('assets/sounds/$name.wav').readAsBytesSync(),
        bytes,
        reason: 'run dart run tool/generate_sounds.dart',
      );
    });
  }

  test('pubspec bundles the sounds', () {
    expect(File('pubspec.yaml').readAsStringSync(), contains('assets/sounds/'));
  });
}
