import 'package:audioplayers/audioplayers.dart';
import 'package:flutter_riverpod/flutter_riverpod.dart';

/// The four sound effects (PRC-11), bundled in `assets/sounds/`.
enum SoundEffect { right, wrong, round, stars }

/// Plays a sound effect. Never throws: sound must not break a round.
abstract class SoundPlayer {
  Future<void> play(SoundEffect effect);
}

/// Plays the bundled WAVs with `audioplayers` in low-latency mode.
class AudioSoundPlayer implements SoundPlayer {
  final Map<SoundEffect, AudioPlayer> _players = {};

  @override
  Future<void> play(SoundEffect effect) async {
    try {
      final player = _players.putIfAbsent(
        effect,
        () => AudioPlayer()..setPlayerMode(PlayerMode.lowLatency),
      );
      await player.stop();
      await player.play(AssetSource('sounds/${effect.name}.wav'));
    } catch (_) {
      // No sound is better than a broken round.
    }
  }
}

final soundPlayerProvider = Provider<SoundPlayer>((ref) => AudioSoundPlayer());

/// Plays [SoundEffect]s unless the parent turned sound off (PRC-11).
/// Errors are swallowed: callers don't await it.
class SoundEffects {
  SoundEffects(this._player, this._soundOn);

  final SoundPlayer _player;
  final Future<bool> Function() _soundOn;

  Future<void> play(SoundEffect effect) async {
    try {
      if (await _soundOn()) await _player.play(effect);
    } catch (_) {
      // Sound never breaks a round.
    }
  }
}
