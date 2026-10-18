import 'dart:math';

import 'package:flutter/material.dart';

import '../models/splurt_game_result.dart';
import '../models/splurt_round.dart';
import '../services/audio_service.dart';
import '../services/scoreboard_service.dart';
import '../services/splurt_service.dart';

enum _SplurtPhase { ready, playing, buzzed, results }

const _kRoundSeconds = 60;

class SplurtScreen extends StatefulWidget {
  const SplurtScreen({super.key});

  @override
  State<SplurtScreen> createState() => _SplurtScreenState();
}

class _SplurtScreenState extends State<SplurtScreen> with TickerProviderStateMixin {
  static const _accent = Color(0xFFFFB13D);
  static const _idoColor = Color(0xFF5B8DEF);
  static const _shiraColor = Color(0xFFFF8A3D);

  final SplurtDeckService _deckService = SplurtDeckService();
  final ScoreboardService _scoreboardService = ScoreboardService();
  final AudioService _audio = AudioService();
  final Random _random = Random();

  late AnimationController _flipController;
  late AnimationController _countdownController;

  late List<SplurtRound> _deck;
  int _deckIndex = 0;
  int _stackMultiplier = 1;
  int _idoScore = 0;
  int _shiraScore = 0;

  _SplurtPhase _phase = _SplurtPhase.ready;
  bool _showConfetti = false;
  List<_ConfettiParticle> _confetti = [];
  bool? _buzzedPlayer; // true = Ido, false = Shira

  SplurtRound get _current => _deck[_deckIndex];

  @override
  void initState() {
    super.initState();
    _deck = _deckService.buildDeck();
    _flipController = AnimationController(vsync: this, duration: const Duration(milliseconds: 500));
    _countdownController = AnimationController(
      vsync: this,
      duration: const Duration(seconds: _kRoundSeconds),
    )..addStatusListener(_onCountdownStatus);
  }

  @override
  void dispose() {
    _flipController.dispose();
    _countdownController.dispose();
    _audio.dispose();
    super.dispose();
  }

  void _onCountdownStatus(AnimationStatus status) {
    if (status == AnimationStatus.dismissed && _phase == _SplurtPhase.playing) {
      _handleTimeout();
    }
  }

  void _startRound() {
    _audio.play(SoundEffect.flip);
    _flipController.forward(from: 0);
    setState(() => _phase = _SplurtPhase.playing);
    _countdownController.reverse(from: 1.0);
  }

  void _handleTimeout() {
    setState(() {
      _stackMultiplier += 1;
      _phase = _SplurtPhase.ready;
      _flipController.value = 0;
      _buzzedPlayer = null;
    });
  }

  void _buzz(bool ido) {
    if (_phase != _SplurtPhase.playing) return;
    _audio.play(SoundEffect.tap);
    setState(() {
      _phase = _SplurtPhase.buzzed;
      _buzzedPlayer = ido;
    });
    _countdownController.stop();
  }

  void _confirmBuzz(bool correct) {
    if (!correct) {
      _audio.play(SoundEffect.flip);
      setState(() {
        _phase = _SplurtPhase.playing;
        _buzzedPlayer = null;
        _countdownController.reverse(from: _countdownController.value);
      });
      return;
    }

    _audio.play(SoundEffect.correct);
    _triggerConfetti();
    setState(() {
      if (_buzzedPlayer == true) {
        _idoScore += _stackMultiplier;
      } else {
        _shiraScore += _stackMultiplier;
      }
      _stackMultiplier = 1;
      _buzzedPlayer = null;
      _flipController.value = 0;

      if (_deckIndex + 1 >= _deck.length) {
        _phase = _SplurtPhase.results;
        _audio.play(SoundEffect.gameOver);
      } else {
        _deckIndex += 1;
        _phase = _SplurtPhase.ready;
      }
    });
  }

  void _triggerConfetti() {
    _confetti = List.generate(14, (_) {
      final angle = _random.nextDouble() * 2 * pi;
      final distance = 60 + _random.nextDouble() * 70;
      return _ConfettiParticle(
        offset: Offset(cos(angle) * distance, sin(angle) * distance),
        emoji: ['🎉', '✨', '🎊', '⚡'][_random.nextInt(4)],
      );
    });
    setState(() => _showConfetti = true);
    Future.delayed(const Duration(milliseconds: 850), () {
      if (mounted) setState(() => _showConfetti = false);
    });
  }

  Future<void> _finishGame() async {
    await _scoreboardService.addResult(
      SplurtGameResult(playedAt: DateTime.now(), idoScore: _idoScore, shiraScore: _shiraScore),
    );
    if (mounted) Navigator.pop(context);
  }

  void _playAgain() {
    setState(() {
      _deck = _deckService.buildDeck();
      _deckIndex = 0;
      _stackMultiplier = 1;
      _idoScore = 0;
      _shiraScore = 0;
      _phase = _SplurtPhase.ready;
      _flipController.value = 0;
      _buzzedPlayer = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Splurt!')),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: Padding(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 8),
                child: _phase == _SplurtPhase.results ? _buildResults() : _buildGame(),
              ),
            ),
            if (_phase != _SplurtPhase.results)
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(16),
                color: const Color(0xFF0F0D14),
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: const Color(0xFFFF1744),
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                  ),
                  onPressed: () {
                    _audio.play(SoundEffect.gameOver);
                    setState(() => _phase = _SplurtPhase.results);
                  },
                  child: const Text('FINISH GAME & SAVE', style: TextStyle(fontWeight: FontWeight.w900, fontSize: 16, letterSpacing: 0.5)),
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGame() {
    return Column(
      children: [
        _buildScoreRow(),
        const SizedBox(height: 10),
        Text(
          'Pair ${_deckIndex + 1} of ${_deck.length}'
          '${_stackMultiplier > 1 ? '  •  worth x$_stackMultiplier' : ''}',
          style: const TextStyle(color: Color(0xFFB8AFC2), fontSize: 13),
        ),
        const SizedBox(height: 16),
        if (_phase == _SplurtPhase.playing) _buildTopBuzzerButton(),
        if (_phase == _SplurtPhase.playing) const SizedBox(height: 12),
        Expanded(
          child: Stack(
            alignment: Alignment.center,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Expanded(child: _buildFlipCard(label: 'CATEGORY', text: _current.category)),
                  const SizedBox(width: 14),
                  Expanded(child: _buildFlipCard(label: 'RULE', text: _current.rule.label)),
                ],
              ),
              if (_showConfetti) ..._confetti.map((p) => _buildConfettiParticle(p)),
            ],
          ),
        ),
        if (_phase == _SplurtPhase.playing) const SizedBox(height: 12),
        if (_phase == _SplurtPhase.playing) _buildBottomBuzzerButton(),
        if (_phase == _SplurtPhase.playing) const SizedBox(height: 12),
        if (_phase == _SplurtPhase.playing) _buildCountdownRing(),
        if (_phase == _SplurtPhase.playing) const SizedBox(height: 14),
        if (_phase == _SplurtPhase.buzzed) _buildCorrectConfirmation(),
        if (_phase == _SplurtPhase.ready) _buildStartButton(),
      ],
    );
  }

  Widget _buildScoreRow() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.spaceBetween,
      children: [
        _buildScoreChip('Ido 🎸', _idoScore, _idoColor),
        _buildScoreChip('Shira 🦊', _shiraScore, _shiraColor),
      ],
    );
  }

  Widget _buildScoreChip(String label, int score, Color color) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
      decoration: BoxDecoration(
        color: color.withValues(alpha: 0.16),
        borderRadius: BorderRadius.circular(14),
      ),
      child: Text(
        '$label · $score',
        style: TextStyle(color: color, fontWeight: FontWeight.w700, fontSize: 14),
      ),
    );
  }

  Widget _buildFlipCard({required String label, required String text}) {
    return AnimatedBuilder(
      animation: _flipController,
      builder: (context, child) {
        final v = _flipController.value;
        final showFront = v >= 0.5;
        final angle = showFront ? (v - 1) * pi : v * pi;
        return Transform(
          alignment: Alignment.center,
          transform: Matrix4.identity()
            ..setEntry(3, 2, 0.0012)
            ..rotateY(angle),
          child: showFront ? _cardFace(label: label, text: text, isFront: true) : _cardFace(isFront: false),
        );
      },
    );
  }

  Widget _cardFace({String? label, String? text, required bool isFront}) {
    return Container(
      height: 150,
      padding: const EdgeInsets.all(14),
      alignment: Alignment.center,
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A24),
        borderRadius: BorderRadius.circular(18),
        border: Border.all(color: _accent.withValues(alpha: 0.4), width: 1.5),
      ),
      child: isFront
          ? Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  label!,
                  style: const TextStyle(
                    color: Color(0xFFB8AFC2),
                    fontSize: 11,
                    fontWeight: FontWeight.w700,
                    letterSpacing: 1.5,
                  ),
                ),
                const SizedBox(height: 10),
                Text(
                  text!,
                  textAlign: TextAlign.center,
                  style: const TextStyle(color: Color(0xFFF5F1F8), fontSize: 17, fontWeight: FontWeight.w700),
                ),
              ],
            )
          : const Text('⚡', style: TextStyle(fontSize: 40)),
    );
  }

  Widget _buildCountdownRing() {
    return AnimatedBuilder(
      animation: _countdownController,
      builder: (context, _) {
        final remaining = (_countdownController.value * _kRoundSeconds).ceil();
        final urgent = remaining <= 3;
        return SizedBox(
          width: 56,
          height: 56,
          child: Stack(
            alignment: Alignment.center,
            children: [
              CircularProgressIndicator(
                value: _countdownController.value,
                strokeWidth: 5,
                backgroundColor: const Color(0xFF332D3D),
                valueColor: AlwaysStoppedAnimation(urgent ? Colors.redAccent : _accent),
              ),
              Text(
                '$remaining',
                style: TextStyle(
                  color: urgent ? Colors.redAccent : const Color(0xFFF5F1F8),
                  fontWeight: FontWeight.w800,
                  fontSize: 16,
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTopBuzzerButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: _idoColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () => _buzz(true),
        child: const Text('BUZZ 🎸', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      ),
    );
  }

  Widget _buildBottomBuzzerButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: _shiraColor,
          padding: const EdgeInsets.symmetric(vertical: 16),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        ),
        onPressed: () => _buzz(false),
        child: const Text('BUZZ 🦊', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
      ),
    );
  }

  Widget _buildCorrectConfirmation() {
    return Column(
      children: [
        Text(
          _buzzedPlayer == true ? 'Ido 🎸 buzzed!' : 'Shira 🦊 buzzed!',
          style: const TextStyle(color: Color(0xFFF5F1F8), fontWeight: FontWeight.w700, fontSize: 16),
        ),
        const SizedBox(height: 12),
        Row(
          children: [
            Expanded(
              child: OutlinedButton(
                style: OutlinedButton.styleFrom(
                  side: const BorderSide(color: Color(0xFFFFB13D), width: 2),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _confirmBuzz(false),
                child: const Text('Wrong', style: TextStyle(color: Color(0xFFFFB13D), fontWeight: FontWeight.w700)),
              ),
            ),
            const SizedBox(width: 12),
            Expanded(
              child: FilledButton(
                style: FilledButton.styleFrom(
                  backgroundColor: const Color(0xFFFFB13D),
                  padding: const EdgeInsets.symmetric(vertical: 14),
                  shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(14)),
                ),
                onPressed: () => _confirmBuzz(true),
                child: const Text('Correct!', style: TextStyle(color: Color(0xFF2D2D2D), fontWeight: FontWeight.w800)),
              ),
            ),
          ],
        ),
      ],
    );
  }

  Widget _buildStartButton() {
    return SizedBox(
      width: double.infinity,
      child: FilledButton(
        style: FilledButton.styleFrom(
          backgroundColor: _accent,
          padding: const EdgeInsets.symmetric(vertical: 18),
          shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(18)),
        ),
        onPressed: _startRound,
        child: const Text(
          'SPLURT!',
          style: TextStyle(fontSize: 20, fontWeight: FontWeight.w900, letterSpacing: 1.5),
        ),
      ),
    );
  }

  Widget _buildConfettiParticle(_ConfettiParticle p) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: const Duration(milliseconds: 850),
      curve: Curves.easeOut,
      builder: (context, t, child) {
        return Opacity(
          opacity: (1 - t).clamp(0, 1),
          child: Transform.translate(
            offset: p.offset * t,
            child: Transform.scale(scale: 1 - (t * 0.3), child: child),
          ),
        );
      },
      child: Text(p.emoji, style: const TextStyle(fontSize: 22)),
    );
  }

  Widget _buildResults() {
    final idoWon = _idoScore > _shiraScore;
    final tie = _idoScore == _shiraScore;
    final winnerText = tie ? "It's a tie! 🤝" : (idoWon ? 'Ido 🎸 wins!' : 'Shira 🦊 wins!');

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        const Text('Game Over', style: TextStyle(fontSize: 22, fontWeight: FontWeight.w700, color: Color(0xFFF5F1F8))),
        const SizedBox(height: 6),
        Text(winnerText, style: const TextStyle(fontSize: 18, color: Color(0xFFFFB13D), fontWeight: FontWeight.w700)),
        const SizedBox(height: 28),
        Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _buildScoreChip('Ido 🎸', _idoScore, _idoColor),
            const SizedBox(width: 16),
            _buildScoreChip('Shira 🦊', _shiraScore, _shiraColor),
          ],
        ),
        const SizedBox(height: 8),
        Text('${_deck.length} card pairs played', style: const TextStyle(color: Color(0xFFB8AFC2))),
        const SizedBox(height: 32),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: _accent,
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _playAgain,
            child: const Text('Play Again', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
        ),
        const SizedBox(height: 12),
        SizedBox(
          width: double.infinity,
          child: FilledButton(
            style: FilledButton.styleFrom(
              backgroundColor: const Color(0xFFFF6B9D),
              padding: const EdgeInsets.symmetric(vertical: 16),
              shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
            ),
            onPressed: _finishGame,
            child: const Text('Finish & Save 🏆', style: TextStyle(fontWeight: FontWeight.w800, fontSize: 16)),
          ),
        ),
      ],
    );
  }
}

class _ConfettiParticle {
  final Offset offset;
  final String emoji;

  const _ConfettiParticle({required this.offset, required this.emoji});
}
