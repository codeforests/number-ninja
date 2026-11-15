/// Synthesises the four sound effects (PRC-11) as mono 16-bit WAV bytes.
/// Deterministic: the same code always gives the same bytes, so
/// `test/tool/sounds_test.dart` can compare them with `assets/sounds/`.
library;

import 'dart:math';
import 'dart:typed_data';

const sampleRate = 22050;

/// One note: frequency in Hz, start and length in seconds.
class Note {
  const Note(this.freq, this.start, this.length, {this.volume = 0.5});
  final double freq;
  final double start;
  final double length;
  final double volume;
}

/// The sounds by file name (without `.wav`).
final Map<String, List<Note>> sounds = {
  // Two rising notes (E5, A5).
  'right': const [Note(659.25, 0, 0.11), Note(880.0, 0.1, 0.16)],
  // One low, soft "bonk" with a falling pitch: gentle, not a buzzer.
  'wrong': const [Note(196.0, 0, 0.3, volume: 0.45)],
  // C5 E5 G5 arpeggio.
  'round': const [
    Note(523.25, 0, 0.16),
    Note(659.25, 0.15, 0.16),
    Note(783.99, 0.3, 0.3),
  ],
  // The arpeggio up to C6, then a high sparkle.
  'stars': const [
    Note(523.25, 0, 0.14),
    Note(659.25, 0.13, 0.14),
    Note(783.99, 0.26, 0.14),
    Note(1046.5, 0.39, 0.35),
    Note(2093.0, 0.62, 0.12, volume: 0.25),
    Note(2637.0, 0.72, 0.12, volume: 0.22),
    Note(3135.96, 0.82, 0.16, volume: 0.2),
  ],
};

/// Renders [notes] to WAV bytes. `wrong` glides down in pitch.
Uint8List renderWav(List<Note> notes, {bool glide = false}) {
  final end = notes.map((n) => n.start + n.length).reduce(max);
  final count = (end * sampleRate).ceil();
  final mix = List<double>.filled(count, 0);
  for (final n in notes) {
    final first = (n.start * sampleRate).round();
    final len = (n.length * sampleRate).round();
    var phase = 0.0;
    for (var i = 0; i < len && first + i < count; i++) {
      final t = i / len;
      final f = glide ? n.freq * (1 - 0.35 * t) : n.freq;
      phase += 2 * pi * f / sampleRate;
      // Soft attack, exponential decay; a little second harmonic for warmth.
      final env = min(1.0, i / (0.005 * sampleRate)) * exp(-4 * t);
      final v = sin(phase) + 0.25 * sin(2 * phase);
      mix[first + i] += n.volume * env * v / 1.25;
    }
  }
  final data = ByteData(44 + count * 2);
  void ascii(int at, String s) {
    for (var i = 0; i < s.length; i++) {
      data.setUint8(at + i, s.codeUnitAt(i));
    }
  }

  ascii(0, 'RIFF');
  data.setUint32(4, 36 + count * 2, Endian.little);
  ascii(8, 'WAVE');
  ascii(12, 'fmt ');
  data.setUint32(16, 16, Endian.little);
  data.setUint16(20, 1, Endian.little); // PCM
  data.setUint16(22, 1, Endian.little); // mono
  data.setUint32(24, sampleRate, Endian.little);
  data.setUint32(28, sampleRate * 2, Endian.little);
  data.setUint16(32, 2, Endian.little);
  data.setUint16(34, 16, Endian.little);
  ascii(36, 'data');
  data.setUint32(40, count * 2, Endian.little);
  for (var i = 0; i < count; i++) {
    final s = (mix[i].clamp(-1.0, 1.0) * 32767).round();
    data.setInt16(44 + i * 2, s, Endian.little);
  }
  return data.buffer.asUint8List();
}

/// All four files: name → bytes.
Map<String, Uint8List> buildSounds() => {
  for (final e in sounds.entries)
    e.key: renderWav(e.value, glide: e.key == 'wrong'),
};
