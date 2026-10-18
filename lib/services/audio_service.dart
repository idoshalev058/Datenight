import 'package:audioplayers/audioplayers.dart';

enum SoundEffect { tap, flip, pass, tick, correct, gameOver }

extension on SoundEffect {
  String get _fileName {
    switch (this) {
      case SoundEffect.tap:
        return 'tap.wav';
      case SoundEffect.flip:
        return 'flip.wav';
      case SoundEffect.pass:
        return 'pass.wav';
      case SoundEffect.tick:
        return 'tick.wav';
      case SoundEffect.correct:
        return 'correct.wav';
      case SoundEffect.gameOver:
        return 'game_over.wav';
    }
  }
}

/// Thin wrapper around audioplayers. Playback failures are swallowed —
/// sound is polish, never something that should block gameplay.
class AudioService {
  final AudioPlayer _player = AudioPlayer();

  Future<void> play(SoundEffect effect) async {
    try {
      await _player.stop();
      await _player.play(AssetSource('sounds/${effect._fileName}'));
    } catch (_) {}
  }

  void dispose() {
    _player.dispose();
  }
}
