import 'package:flutter/material.dart';

import '../logic/schulte_game.dart';
import '../models/grid_size.dart';
import '../services/score_storage.dart';
import '../theme/app_theme.dart';
import 'game_screen.dart';
import 'leaderboard_dialog.dart';

/// Lets the player pick a grid size and shows the best time for each.
class StartScreen extends StatefulWidget {
  const StartScreen({super.key});

  @override
  State<StartScreen> createState() => _StartScreenState();
}

class _StartScreenState extends State<StartScreen> {
  final Map<GridSize, int?> _bestTimes = {};

  @override
  void initState() {
    super.initState();
    _loadBestTimes();
  }

  Future<void> _loadBestTimes() async {
    for (final size in GridSize.values) {
      final best = await ScoreStorage.bestTime(size);
      if (!mounted) return;
      setState(() => _bestTimes[size] = best);
    }
  }

  Future<void> _startGame(GridSize size) async {
    await Navigator.push(
      context,
      MaterialPageRoute(builder: (_) => GameScreen(size: size)),
    );
    // Refresh best times when the player comes back.
    _loadBestTimes();
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Schulte Grid'),
        actions: [
          IconButton(
            icon: const Icon(Icons.leaderboard),
            tooltip: 'Leaderboard',
            onPressed: () async {
              await LeaderboardDialog.show(context);
              _loadBestTimes();
            },
          ),
        ],
      ),
      body: SafeArea(
        child: Center(
          child: SingleChildScrollView(
            padding: const EdgeInsets.all(24),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.stretch,
              children: [
                Row(
                  children: [
                    Container(
                      width: 80,
                      height: 80,
                      decoration: BoxDecoration(
                        color: colors.card,
                        borderRadius: BorderRadius.circular(16),
                        border: Border.all(color: colors.border, width: 2),
                      ),
                      child: Icon(Icons.grid_on, size: 40, color: colors.accent),
                    ),
                    const SizedBox(width: 16),
                    Expanded(
                      child: Column(
                        crossAxisAlignment: CrossAxisAlignment.start,
                        children: [
                          Text(
                            'Schulte Grid',
                            style: Theme.of(context)
                                .textTheme
                                .headlineMedium
                                ?.copyWith(
                                  color: colors.textPrimary,
                                  fontWeight: FontWeight.bold,
                                ),
                          ),
                          const SizedBox(height: 8),
                          Text(
                            'Train your focus! Tap numbers 1 to N in order as fast as you can.',
                            style: TextStyle(color: colors.textSecondary),
                          ),
                        ],
                      ),
                    ),
                  ],
                ),
                const SizedBox(height: 32),
                for (final size in GridSize.values)
                  Padding(
                    padding: const EdgeInsets.only(bottom: 16),
                    child: _buildSizeCard(colors, size),
                  ),
                const SizedBox(height: 8),
                Text(
                  'Choose a grid size to start. Tap numbers from 1 to N in '
                  'ascending order. The timer starts when you tap 1.',
                  textAlign: TextAlign.center,
                  style: TextStyle(color: colors.textSecondary),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildSizeCard(AppColors colors, GridSize size) {
    final best = _bestTimes[size];

    return Container(
      padding: const EdgeInsets.all(20),
      decoration: BoxDecoration(
        color: colors.surface,
        borderRadius: BorderRadius.circular(16),
        border: Border.all(color: colors.border, width: 1.5),
      ),
      child: Row(
        children: [
          Container(
            width: 56,
            height: 56,
            alignment: Alignment.center,
            decoration: BoxDecoration(
              color: colors.accent.withAlpha(30),
              borderRadius: BorderRadius.circular(12),
            ),
            child: Text(
              size.label,
              style: TextStyle(
                color: colors.accent,
                fontWeight: FontWeight.bold,
                fontSize: 18,
              ),
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  '${size.label} Grid (${size.total} numbers)',
                  style: TextStyle(
                    color: colors.textPrimary,
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  best != null
                      ? 'Best: ${SchulteGame.formatTime(best)}'
                      : 'No record yet',
                  style: TextStyle(
                    color: best != null ? colors.accent : colors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          ElevatedButton.icon(
            onPressed: () => _startGame(size),
            icon: const Icon(Icons.play_arrow),
            label: const Text('Play'),
          ),
        ],
      ),
    );
  }
}
