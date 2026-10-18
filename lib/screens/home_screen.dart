import 'package:flutter/material.dart';

import '../services/audio_service.dart';
import 'icebreaker_screen.dart';
import 'scoreboard_screen.dart';
import 'splurt_screen.dart';
import 'would_you_rather_screen.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen({super.key});

  @override
  State<HomeScreen> createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  final AudioService _audio = AudioService();

  @override
  void dispose() {
    _audio.dispose();
    super.dispose();
  }

  void _openGame(Widget screen) {
    _audio.play(SoundEffect.tap);
    Navigator.push(context, MaterialPageRoute(builder: (_) => screen));
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Date Night'),
        actions: [
          IconButton(
            tooltip: 'Scoreboard',
            icon: const Text('🏆', style: TextStyle(fontSize: 22)),
            onPressed: () => _openGame(const ScoreboardScreen()),
          ),
        ],
      ),
      body: SafeArea(
        child: ListView(
          padding: const EdgeInsets.fromLTRB(20, 12, 20, 32),
          children: [
            _buildHeader(),
            const SizedBox(height: 28),
            _buildGameCard(
              title: 'Would You Rather',
              subtitle: 'Pick a side. No scorekeeping, just chaos.',
              emoji: '🤔',
              color: const Color(0xFFFF4FA3),
              onTap: () => _openGame(const WouldYouRatherScreen()),
              delayMs: 0,
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              title: 'Icebreaker',
              subtitle: 'Get-to-know-you questions. Pass if you dare.',
              emoji: '💬',
              color: const Color(0xFF4FD8C4),
              onTap: () => _openGame(const IcebreakerScreen()),
              delayMs: 90,
            ),
            const SizedBox(height: 16),
            _buildGameCard(
              title: 'Splurt!',
              subtitle: 'Race the clock, race each other.',
              emoji: '⚡',
              color: const Color(0xFFFFB13D),
              onTap: () => _openGame(const SplurtScreen()),
              delayMs: 180,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildHeader() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: const [
        Text(
          'Ido 🎸  &  Shira 🦊',
          style: TextStyle(
            fontSize: 26,
            fontWeight: FontWeight.w700,
            color: Color(0xFFF5F1F8),
          ),
        ),
        SizedBox(height: 6),
        Text(
          'Pick a game for tonight.',
          style: TextStyle(fontSize: 15, color: Color(0xFFB8AFC2)),
        ),
      ],
    );
  }

  Widget _buildGameCard({
    required String title,
    required String subtitle,
    required String emoji,
    required Color color,
    required VoidCallback onTap,
    required int delayMs,
  }) {
    return TweenAnimationBuilder<double>(
      tween: Tween(begin: 0, end: 1),
      duration: Duration(milliseconds: 420 + delayMs),
      curve: Curves.easeOutCubic,
      builder: (context, value, child) {
        return Opacity(
          opacity: value,
          child: Transform.translate(
            offset: Offset(0, (1 - value) * 24),
            child: child,
          ),
        );
      },
      child: Material(
        color: const Color(0xFFFFEFF6),
        borderRadius: BorderRadius.circular(20),
        child: InkWell(
          borderRadius: BorderRadius.circular(20),
          onTap: onTap,
          child: Container(
            padding: const EdgeInsets.all(20),
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: color.withValues(alpha: 0.25), width: 2),
              boxShadow: [
                BoxShadow(color: color.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 4)),
              ],
            ),
            child: Row(
              children: [
                Container(
                  width: 52,
                  height: 52,
                  alignment: Alignment.center,
                  decoration: BoxDecoration(
                    color: color.withValues(alpha: 0.12),
                    shape: BoxShape.circle,
                  ),
                  child: Text(emoji, style: const TextStyle(fontSize: 26)),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          fontSize: 19,
                          fontWeight: FontWeight.w700,
                          color: color,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        subtitle,
                        style: const TextStyle(fontSize: 13.5, color: Color(0xFF999999)),
                      ),
                    ],
                  ),
                ),
                Icon(Icons.chevron_right_rounded, color: color),
              ],
            ),
          ),
        ),
      ),
    );
  }
}
