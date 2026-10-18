import 'package:flutter/material.dart';

import '../models/splurt_game_result.dart';
import '../services/scoreboard_service.dart';

const _kMonthNames = [
  'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
  'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec',
];

String _formatDateTime(DateTime dt) {
  final hour24 = dt.hour;
  final hour12 = hour24 % 12 == 0 ? 12 : hour24 % 12;
  final period = hour24 < 12 ? 'AM' : 'PM';
  final minute = dt.minute.toString().padLeft(2, '0');
  return '${_kMonthNames[dt.month - 1]} ${dt.day}, ${dt.year} · $hour12:$minute $period';
}

class ScoreboardScreen extends StatefulWidget {
  const ScoreboardScreen({super.key});

  @override
  State<ScoreboardScreen> createState() => _ScoreboardScreenState();
}

class _ScoreboardScreenState extends State<ScoreboardScreen> {
  static const _idoColor = Color(0xFF5B8DEF);
  static const _shiraColor = Color(0xFFFF8A3D);

  final ScoreboardService _service = ScoreboardService();
  late Future<List<SplurtGameResult>> _resultsFuture;

  @override
  void initState() {
    super.initState();
    _resultsFuture = _service.loadResults();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Scoreboard 🏆')),
      body: SafeArea(
        child: FutureBuilder<List<SplurtGameResult>>(
          future: _resultsFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState != ConnectionState.done) {
              return const Center(child: CircularProgressIndicator());
            }
            final results = snapshot.data ?? [];
            if (results.isEmpty) {
              return _buildEmptyState();
            }
            return _buildSummaryAndList(results);
          },
        ),
      ),
    );
  }

  Widget _buildEmptyState() {
    return const Center(
      child: Padding(
        padding: EdgeInsets.all(32),
        child: Text(
          'No Splurt games played yet.\nPlay a round to see scores here!',
          textAlign: TextAlign.center,
          style: TextStyle(color: Color(0xFFB8AFC2), fontSize: 15),
        ),
      ),
    );
  }

  Widget _buildSummaryAndList(List<SplurtGameResult> results) {
    final idoWins = results.where((r) => r.idoScore > r.shiraScore).length;
    final shiraWins = results.where((r) => r.shiraScore > r.idoScore).length;

    return ListView(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 24),
      children: [
        Row(
          mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: [
            _buildWinChip('Ido 🎸', idoWins, _idoColor),
            _buildWinChip('Shira 🦊', shiraWins, _shiraColor),
          ],
        ),
        const SizedBox(height: 20),
        Text(
          '${results.length} game${results.length == 1 ? '' : 's'} played',
          style: const TextStyle(color: Color(0xFFB8AFC2), fontSize: 13),
        ),
        const SizedBox(height: 10),
        ...results.map(_buildResultTile),
      ],
    );
  }

  Widget _buildWinChip(String label, int wins, Color color) {
    return Column(
      children: [
        Text('$wins', style: TextStyle(color: color, fontSize: 28, fontWeight: FontWeight.w800)),
        const SizedBox(height: 2),
        Text('$label wins', style: const TextStyle(color: Color(0xFFB8AFC2), fontSize: 12)),
      ],
    );
  }

  Widget _buildResultTile(SplurtGameResult result) {
    final idoWon = result.idoScore > result.shiraScore;
    final tie = result.idoScore == result.shiraScore;

    return Container(
      margin: const EdgeInsets.only(bottom: 10),
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        color: const Color(0xFF1E1A24),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: const Color(0xFF332D3D), width: 1),
      ),
      child: Row(
        children: [
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  _formatDateTime(result.playedAt),
                  style: const TextStyle(color: Color(0xFFB8AFC2), fontSize: 12),
                ),
                const SizedBox(height: 6),
                Text(
                  tie
                      ? "It's a tie"
                      : (idoWon ? 'Ido 🎸 won' : 'Shira 🦊 won'),
                  style: const TextStyle(color: Color(0xFFF5F1F8), fontWeight: FontWeight.w700, fontSize: 15),
                ),
              ],
            ),
          ),
          Text(
            'Ido ${result.idoScore}',
            style: const TextStyle(color: _idoColor, fontWeight: FontWeight.w700),
          ),
          const SizedBox(width: 10),
          Text(
            'Shira ${result.shiraScore}',
            style: const TextStyle(color: _shiraColor, fontWeight: FontWeight.w700),
          ),
        ],
      ),
    );
  }
}
