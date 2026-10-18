import 'package:flutter/material.dart';

import '../data/icebreaker_data.dart';
import '../models/icebreaker_question.dart';
import '../services/audio_service.dart';
import '../services/question_queue_service.dart';

class IcebreakerScreen extends StatefulWidget {
  const IcebreakerScreen({super.key});

  @override
  State<IcebreakerScreen> createState() => _IcebreakerScreenState();
}

class _IcebreakerScreenState extends State<IcebreakerScreen> {
  static const _accent = Color(0xFF4FD8C4);
  static const _idoColor = Color(0xFF5B8DEF);
  static const _shiraColor = Color(0xFFFF8A3D);

  final QuestionQueueService<IcebreakerQuestion> _queue =
      QuestionQueueService(icebreakerQuestions);
  final AudioService _audio = AudioService();

  late IcebreakerQuestion _current;
  bool _isIdoTurn = true;

  @override
  void initState() {
    super.initState();
    _current = _queue.next();
  }

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  void _pass() {
    _audio.play(SoundEffect.pass);
    setState(() => _isIdoTurn = !_isIdoTurn);
  }

  void _next() {
    _audio.play(SoundEffect.flip);
    setState(() {
      _current = _queue.next();
      _isIdoTurn = !_isIdoTurn;
    });
  }

  @override
  Widget build(BuildContext context) {
    final turnColor = _isIdoTurn ? _idoColor : _shiraColor;

    return Scaffold(
      appBar: AppBar(title: const Text('Icebreaker')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              _buildTurnIndicator(),
              const SizedBox(height: 24),
              Expanded(
                child: Center(
                  child: AnimatedSwitcher(
                    duration: const Duration(milliseconds: 320),
                    transitionBuilder: (child, animation) => FadeTransition(
                      opacity: animation,
                      child: ScaleTransition(scale: animation, child: child),
                    ),
                    child: Container(
                      key: ValueKey(_current.id),
                      width: double.infinity,
                      padding: const EdgeInsets.all(28),
                      decoration: BoxDecoration(
                        color: const Color(0xFF1E1A24),
                        borderRadius: BorderRadius.circular(22),
                        border: Border.all(color: turnColor.withValues(alpha: 0.3), width: 2),
                        boxShadow: [
                          BoxShadow(color: turnColor.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4)),
                        ],
                      ),
                      child: Text(
                        _current.text,
                        textAlign: TextAlign.center,
                        style: const TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w600,
                          color: Color(0xFFF5F1F8),
                          height: 1.35,
                        ),
                      ),
                    ),
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  Expanded(
                    child: OutlinedButton(
                      style: OutlinedButton.styleFrom(
                        side: BorderSide(color: turnColor, width: 1.5),
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _pass,
                      child: Text(
                        'Pass to ${_isIdoTurn ? 'Shira 🦊' : 'Ido 🎸'}',
                        style: TextStyle(color: turnColor, fontWeight: FontWeight.w700),
                      ),
                    ),
                  ),
                  const SizedBox(width: 12),
                  Expanded(
                    child: FilledButton(
                      style: FilledButton.styleFrom(
                        backgroundColor: _accent,
                        padding: const EdgeInsets.symmetric(vertical: 15),
                        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                      ),
                      onPressed: _next,
                      child: const Text('Next Question', style: TextStyle(fontWeight: FontWeight.w700)),
                    ),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTurnIndicator() {
    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 280),
      transitionBuilder: (child, animation) {
        final slide = Tween<Offset>(
          begin: Offset(_isIdoTurn ? -0.3 : 0.3, 0),
          end: Offset.zero,
        ).animate(animation);
        return SlideTransition(position: slide, child: FadeTransition(opacity: animation, child: child));
      },
      child: Row(
        key: ValueKey(_isIdoTurn),
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          _buildNameChip('Ido 🎸', _idoColor, active: _isIdoTurn),
          const SizedBox(width: 12),
          const Text('vs', style: TextStyle(color: Color(0xFFB8AFC2))),
          const SizedBox(width: 12),
          _buildNameChip('Shira 🦊', _shiraColor, active: !_isIdoTurn),
        ],
      ),
    );
  }

  Widget _buildNameChip(String label, Color color, {required bool active}) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      decoration: BoxDecoration(
        color: active ? color.withValues(alpha: 0.22) : Colors.transparent,
        borderRadius: BorderRadius.circular(30),
        border: Border.all(color: active ? color : const Color(0xFF332D3D), width: active ? 2 : 1),
      ),
      child: Text(
        label,
        style: TextStyle(
          fontWeight: active ? FontWeight.w800 : FontWeight.w500,
          color: active ? color : const Color(0xFFB8AFC2),
        ),
      ),
    );
  }
}
