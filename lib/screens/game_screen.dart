import 'dart:async';

import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

import '../logic/schulte_game.dart';
import '../models/grid_size.dart';
import '../services/score_storage.dart';
import '../theme/app_theme.dart';
import 'leaderboard_dialog.dart';

/// The game board: timer, progress and the grid of numbers.
class GameScreen extends StatefulWidget {
  final GridSize size;

  const GameScreen({super.key, required this.size});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> with WidgetsBindingObserver {
  late SchulteGame _game;

  /// Redraws the screen about 60 times a second so the timer moves.
  Timer? _ticker;

  @override
  void initState() {
    super.initState();
    _game = SchulteGame(widget.size);
    // Lets us know when the app goes to the background.
    WidgetsBinding.instance.addObserver(this);
  }

  @override
  void dispose() {
    _ticker?.cancel();
    WidgetsBinding.instance.removeObserver(this);
    super.dispose();
  }

  @override
  void didChangeAppLifecycleState(AppLifecycleState state) {
    if (state == AppLifecycleState.paused ||
        state == AppLifecycleState.inactive) {
      setState(() => _game.pause());
    } else if (state == AppLifecycleState.resumed) {
      setState(() => _game.resume());
    }
  }

  void _newGame() {
    _ticker?.cancel();
    setState(() => _game = SchulteGame(widget.size));
  }

  void _onCellTap(int row, int col) {
    final result = _game.tap(row, col);

    switch (result) {
      case TapResult.wrong:
        HapticFeedback.lightImpact();
        setState(() {});
        // Remove the red flash after 300 ms.
        Future.delayed(const Duration(milliseconds: 300), () {
          if (mounted && _game.wrongRow == row && _game.wrongCol == col) {
            setState(() => _game.clearWrongTap());
          }
        });
      case TapResult.correct:
        if (_ticker == null || !_ticker!.isActive) {
          _ticker = Timer.periodic(
            const Duration(milliseconds: 16),
            (_) => setState(() {}),
          );
        }
        setState(() {});
      case TapResult.finished:
        _ticker?.cancel();
        setState(() {});
        _finishGame();
      case TapResult.ignored:
        break;
    }
  }

  Future<void> _finishGame() async {
    final time = _game.elapsedMs;
    // Save first, so we know if it is a new best before showing the dialog.
    final isNewBest = await ScoreStorage.addScore(widget.size, time);
    if (!mounted) return;
    _showResults(time, isNewBest);
  }

  void _showResults(int timeMs, bool isNewBest) {
    final colors = AppColors.of(context);

    showDialog(
      context: context,
      barrierDismissible: false,
      builder: (dialogContext) => Dialog(
        backgroundColor: colors.surface,
        shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(16)),
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(Icons.emoji_events, size: 48, color: colors.accent),
              const SizedBox(height: 16),
              Text(
                'Completed!',
                style: TextStyle(
                  fontSize: 24,
                  fontWeight: FontWeight.bold,
                  color: colors.textPrimary,
                ),
              ),
              const SizedBox(height: 24),
              Container(
                width: double.infinity,
                padding: const EdgeInsets.all(20),
                decoration: BoxDecoration(
                  color: colors.card,
                  borderRadius: BorderRadius.circular(12),
                  border: Border.all(color: colors.border),
                ),
                child: Column(
                  children: [
                    Text(
                      '${widget.size.label} Grid (${widget.size.total} numbers)',
                      style: TextStyle(color: colors.textSecondary),
                    ),
                    const SizedBox(height: 8),
                    Text(
                      SchulteGame.formatTime(timeMs),
                      style: TextStyle(
                        fontSize: 36,
                        fontWeight: FontWeight.bold,
                        fontFamily: 'monospace',
                        color: colors.accent,
                      ),
                    ),
                    if (isNewBest) ...[
                      const SizedBox(height: 8),
                      Container(
                        padding: const EdgeInsets.symmetric(
                            horizontal: 12, vertical: 4),
                        decoration: BoxDecoration(
                          color: colors.accent.withAlpha(40),
                          borderRadius: BorderRadius.circular(12),
                        ),
                        child: Text(
                          'New Personal Best!',
                          style: TextStyle(
                            color: colors.accent,
                            fontWeight: FontWeight.bold,
                          ),
                        ),
                      ),
                    ],
                  ],
                ),
              ),
              const SizedBox(height: 24),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceEvenly,
                children: [
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      Navigator.pop(context);
                    },
                    child: Text('Quit',
                        style: TextStyle(color: colors.textSecondary)),
                  ),
                  TextButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      LeaderboardDialog.show(context, initialSize: widget.size);
                    },
                    child: Text('Leaderboard',
                        style: TextStyle(color: colors.accent)),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.pop(dialogContext);
                      _newGame();
                    },
                    child: const Text('New Game'),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: Text('Schulte Grid - ${widget.size.label}'),
        actions: [
          IconButton(
            icon: const Icon(Icons.refresh),
            tooltip: 'Restart',
            onPressed: _newGame,
          ),
        ],
      ),
      body: SafeArea(
        child: LayoutBuilder(
          builder: (context, constraints) {
            final isLandscape = constraints.maxWidth > constraints.maxHeight;
            const padding = 16.0;

            if (isLandscape) {
              // Grid on the left, timer and progress on the right.
              const panelWidth = 220.0;
              final gridSize = (constraints.maxWidth - panelWidth - padding * 3)
                  .clamp(0.0, constraints.maxHeight - padding * 2)
                  .toDouble();
              return Padding(
                padding: const EdgeInsets.all(padding),
                child: Row(
                  children: [
                    Expanded(child: Center(child: _buildGrid(colors, gridSize))),
                    SizedBox(
                      width: panelWidth,
                      child: Column(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          _buildTimer(colors),
                          const SizedBox(height: 24),
                          _buildProgress(colors),
                        ],
                      ),
                    ),
                  ],
                ),
              );
            }

            // Portrait: timer and progress on top, grid below.
            final gridSize = (constraints.maxWidth - padding * 2)
                .clamp(0.0, constraints.maxHeight - 180)
                .toDouble();
            return Column(
              children: [
                const SizedBox(height: 16),
                _buildTimer(colors),
                const SizedBox(height: 12),
                _buildProgress(colors),
                const SizedBox(height: 16),
                Expanded(child: Center(child: _buildGrid(colors, gridSize))),
              ],
            );
          },
        ),
      ),
    );
  }

  Widget _buildTimer(AppColors colors) {
    String hint = '';
    if (_game.status == GameStatus.idle) hint = 'Tap 1 to start the timer';
    if (_game.status == GameStatus.paused) hint = 'Paused';

    return Column(
      children: [
        // FittedBox shrinks the text if it does not fit, so it never wraps.
        FittedBox(
          fit: BoxFit.scaleDown,
          child: Text(
            SchulteGame.formatTime(_game.elapsedMs),
            style: TextStyle(
              fontSize: 48,
              fontWeight: FontWeight.bold,
              fontFamily: 'monospace',
              color: colors.textPrimary,
              letterSpacing: 2,
            ),
          ),
        ),
        const SizedBox(height: 4),
        Text(hint, style: TextStyle(fontSize: 14, color: colors.textSecondary)),
      ],
    );
  }

  Widget _buildProgress(AppColors colors) {
    final done = _game.status == GameStatus.completed;

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 32),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text('Next: ',
                  style: TextStyle(fontSize: 16, color: colors.textSecondary)),
              Text(
                done ? '-' : '${_game.nextNumber}',
                style: TextStyle(
                  fontSize: 20,
                  fontWeight: FontWeight.bold,
                  color: colors.accent,
                ),
              ),
            ],
          ),
          const SizedBox(height: 8),
          LinearProgressIndicator(
            value: _game.progress,
            backgroundColor: colors.border.withAlpha(80),
            color: colors.accent,
            minHeight: 4,
            borderRadius: BorderRadius.circular(4),
          ),
        ],
      ),
    );
  }

  Widget _buildGrid(AppColors colors, double maxSize) {
    final dim = widget.size.dimension;
    const gap = 4.0;
    final cellSize = (maxSize - gap * (dim - 1)) / dim;

    return SizedBox(
      width: maxSize,
      height: maxSize,
      child: Column(
        children: [
          for (int row = 0; row < dim; row++)
            Padding(
              padding: EdgeInsets.only(bottom: row < dim - 1 ? gap : 0),
              child: Row(
                children: [
                  for (int col = 0; col < dim; col++)
                    Padding(
                      padding: EdgeInsets.only(right: col < dim - 1 ? gap : 0),
                      child: _buildCell(colors, row, col, cellSize),
                    ),
                ],
              ),
            ),
        ],
      ),
    );
  }

  Widget _buildCell(AppColors colors, int row, int col, double size) {
    final number = _game.grid[row][col];
    final isWrong = _game.wrongRow == row && _game.wrongCol == col;
    final isTapped = number < _game.nextNumber;

    Color background = colors.surface;
    Color border = colors.border;
    Color text = colors.textPrimary;
    if (isTapped) {
      background = colors.accent.withAlpha(40);
      border = colors.accent.withAlpha(100);
      text = colors.accent.withAlpha(120);
    }
    if (isWrong) {
      background = Colors.red.withAlpha(180);
      border = Colors.red;
      text = Colors.white;
    }

    return GestureDetector(
      onTap: () => _onCellTap(row, col),
      child: Container(
        width: size,
        height: size,
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: background,
          borderRadius: BorderRadius.circular(8),
          border: Border.all(color: border, width: isTapped || isWrong ? 2 : 1.5),
          boxShadow: [
            BoxShadow(
              color: colors.shadow.withAlpha(60),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
        child: Text(
          '$number',
          style: TextStyle(
            fontSize: size * 0.4,
            fontWeight: FontWeight.bold,
            color: text,
          ),
        ),
      ),
    );
  }
}
