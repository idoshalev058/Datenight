import 'package:flutter/material.dart';

import '../data/would_you_rather_data.dart';
import '../models/would_you_rather_question.dart';
import '../services/audio_service.dart';
import '../services/question_queue_service.dart';

class WouldYouRatherScreen extends StatefulWidget {
  const WouldYouRatherScreen({super.key});

  @override
  State<WouldYouRatherScreen> createState() => _WouldYouRatherScreenState();
}

class _WouldYouRatherScreenState extends State<WouldYouRatherScreen> {
  static const _accent = Color(0xFFFF6B9D);

  final QuestionQueueService<WouldYouRatherQuestion> _queue =
      QuestionQueueService(wouldYouRatherQuestions);
  final AudioService _audio = AudioService();

  late WouldYouRatherQuestion _current;
  bool? _pickedA;

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

  void _pick(bool isA) {
    if (_pickedA != null) return;
    _audio.play(SoundEffect.tap);
    setState(() => _pickedA = isA);
  }

  void _next() {
    _audio.play(SoundEffect.flip);
    setState(() {
      _current = _queue.next();
      _pickedA = null;
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Would You Rather')),
      body: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
          child: Column(
            children: [
              const Text(
                'No wrong answers. Just talk it out.',
                style: TextStyle(color: Color(0xFFB8AFC2), fontSize: 14),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: AnimatedSwitcher(
                  duration: const Duration(milliseconds: 320),
                  transitionBuilder: (child, animation) => FadeTransition(
                    opacity: animation,
                    child: ScaleTransition(scale: animation, child: child),
                  ),
                  child: Column(
                    key: ValueKey(_current.id),
                    mainAxisAlignment: MainAxisAlignment.center,
                    children: [
                      _buildOption(_current.optionA, isA: true),
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: 14),
                        child: Text(
                          'OR',
                          style: TextStyle(
                            color: _accent,
                            fontWeight: FontWeight.w800,
                            fontSize: 16,
                            letterSpacing: 2,
                          ),
                        ),
                      ),
                      _buildOption(_current.optionB, isA: false),
                    ],
                  ),
                ),
              ),
              const SizedBox(height: 20),
              SizedBox(
                width: double.infinity,
                child: FilledButton(
                  style: FilledButton.styleFrom(
                    backgroundColor: _accent,
                    padding: const EdgeInsets.symmetric(vertical: 16),
                    shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
                  ),
                  onPressed: _next,
                  child: const Text('Next Question', style: TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildOption(String text, {required bool isA}) {
    final picked = _pickedA == isA;
    final faded = _pickedA != null && !picked;

    return GestureDetector(
      onTap: () => _pick(isA),
      child: AnimatedScale(
        scale: picked ? 1.03 : 1.0,
        duration: const Duration(milliseconds: 180),
        curve: Curves.easeOut,
        child: AnimatedContainer(
          duration: const Duration(milliseconds: 220),
          width: double.infinity,
          padding: const EdgeInsets.symmetric(vertical: 22, horizontal: 20),
          decoration: BoxDecoration(
            color: picked ? _accent.withValues(alpha: 0.12) : const Color(0xFF1E1A24),
            borderRadius: BorderRadius.circular(18),
            border: Border.all(
              color: picked ? _accent : const Color(0xFF332D3D),
              width: picked ? 2 : 1,
            ),
          ),
          child: Opacity(
            opacity: faded ? 0.45 : 1.0,
            child: Text(
              text,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w600, color: Color(0xFFF5F1F8)),
            ),
          ),
        ),
      ),
    );
  }
}
