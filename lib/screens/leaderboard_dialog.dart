import 'package:flutter/material.dart';

import '../logic/schulte_game.dart';
import '../models/grid_size.dart';
import '../models/score_record.dart';
import '../services/score_storage.dart';
import '../theme/app_theme.dart';

/// A pop-up with one tab per grid size, listing the 10 best times.
class LeaderboardDialog extends StatefulWidget {
  final GridSize initialSize;

  const LeaderboardDialog({super.key, required this.initialSize});

  static Future<void> show(BuildContext context,
      {GridSize initialSize = GridSize.fourByFour}) {
    return showDialog(
      context: context,
      builder: (_) => LeaderboardDialog(initialSize: initialSize),
    );
  }

  @override
  State<LeaderboardDialog> createState() => _LeaderboardDialogState();
}

class _LeaderboardDialogState extends State<LeaderboardDialog> {
  late GridSize _selected = widget.initialSize;
  List<ScoreRecord> _scores = [];

  @override
  void initState() {
    super.initState();
    _load();
  }

  Future<void> _load() async {
    final scores = await ScoreStorage.loadScores(_selected);
    if (!mounted) return;
    setState(() => _scores = scores);
  }

  Future<void> _confirmClear() async {
    final yes = await showDialog<bool>(
      context: context,
      builder: (c) => AlertDialog(
        title: const Text('Clear Leaderboard'),
        content: const Text(
            'Are you sure you want to clear all records for this grid size?'),
        actions: [
          TextButton(
              onPressed: () => Navigator.pop(c, false),
              child: const Text('Cancel')),
          TextButton(
              onPressed: () => Navigator.pop(c, true),
              child: const Text('Clear')),
        ],
      ),
    );
    if (yes == true) {
      await ScoreStorage.clearScores(_selected);
      _load();
    }
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Dialog(
      backgroundColor: colors.surface,
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
      child: ConstrainedBox(
        constraints: const BoxConstraints(maxWidth: 400, maxHeight: 560),
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Row(
                children: [
                  Icon(Icons.leaderboard, color: colors.accent),
                  const SizedBox(width: 8),
                  Text(
                    'Leaderboard',
                    style: TextStyle(
                      fontSize: 20,
                      fontWeight: FontWeight.bold,
                      color: colors.textPrimary,
                    ),
                  ),
                  const Spacer(),
                  IconButton(
                    icon: const Icon(Icons.close),
                    tooltip: 'Close',
                    onPressed: () => Navigator.pop(context),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              // Tabs for 4x4 / 5x5 / 6x6
              SegmentedButton<GridSize>(
                showSelectedIcon: false,
                segments: [
                  for (final s in GridSize.values)
                    ButtonSegment(value: s, label: Text(s.label)),
                ],
                selected: {_selected},
                onSelectionChanged: (set) {
                  setState(() => _selected = set.first);
                  _load();
                },
              ),
              const SizedBox(height: 16),
              Flexible(
                child: _scores.isEmpty
                    ? Padding(
                        padding: const EdgeInsets.all(24),
                        child: Text(
                          'No records yet.\nComplete a training to set your first record!',
                          textAlign: TextAlign.center,
                          style: TextStyle(color: colors.textSecondary),
                        ),
                      )
                    : ListView.builder(
                        shrinkWrap: true,
                        itemCount: _scores.length,
                        itemBuilder: (context, i) =>
                            _buildRow(colors, i, _scores[i]),
                      ),
              ),
              const SizedBox(height: 12),
              if (_scores.isNotEmpty)
                TextButton.icon(
                  onPressed: _confirmClear,
                  icon: const Icon(Icons.delete_outline),
                  label: const Text('Clear Leaderboard'),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildRow(AppColors colors, int index, ScoreRecord record) {
    final date = record.playedAt;
    final dateText = '${date.year}-${date.month.toString().padLeft(2, '0')}-'
        '${date.day.toString().padLeft(2, '0')}';
    final isFirst = index == 0;

    return Container(
      margin: const EdgeInsets.only(bottom: 8),
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
      decoration: BoxDecoration(
        color: colors.card,
        borderRadius: BorderRadius.circular(10),
        border: Border.all(
          color: isFirst ? Colors.amber : colors.border.withAlpha(100),
          width: isFirst ? 2 : 1,
        ),
      ),
      child: Row(
        children: [
          SizedBox(
            width: 32,
            child: isFirst
                ? const Icon(Icons.emoji_events, color: Colors.amber)
                : Text('#${index + 1}',
                    style: TextStyle(color: colors.textSecondary)),
          ),
          const SizedBox(width: 12),
          Text(
            SchulteGame.formatTime(record.timeMs),
            style: TextStyle(
              fontSize: 16,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: colors.textPrimary,
            ),
          ),
          const Spacer(),
          Text(dateText,
              style: TextStyle(fontSize: 12, color: colors.textSecondary)),
        ],
      ),
    );
  }
}
