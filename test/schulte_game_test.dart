import 'dart:math';

import 'package:flutter_test/flutter_test.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'package:minigames/logic/schulte_game.dart';
import 'package:minigames/models/grid_size.dart';
import 'package:minigames/services/score_storage.dart';

/// Finds where [n] is on the grid.
(int, int) findCell(SchulteGame game, int n) {
  for (int r = 0; r < game.grid.length; r++) {
    final c = game.grid[r].indexOf(n);
    if (c != -1) return (r, c);
  }
  throw StateError('$n not found');
}

void main() {
  group('Grid generation', () {
    for (final size in GridSize.values) {
      test('${size.label} grid contains 1..N exactly once', () {
        final grid = SchulteGame.generateGrid(size, Random());
        expect(grid.length, size.dimension);
        final all = grid.expand((row) => row).toList()..sort();
        expect(all, List.generate(size.total, (i) => i + 1));
      });
    }

    test('different games get different grids', () {
      final grids = {
        for (int i = 0; i < 20; i++)
          SchulteGame.generateGrid(GridSize.fiveByFive, Random()).toString()
      };
      expect(grids.length, greaterThan(1));
    });
  });

  test('formatTime shows MM:SS.hh', () {
    expect(SchulteGame.formatTime(0), '00:00.00');
    expect(SchulteGame.formatTime(19580), '00:19.58');
    expect(SchulteGame.formatTime(61234), '01:01.23');
  });

  group('Game rules', () {
    test('starts idle and runs after tapping 1', () {
      final game = SchulteGame(GridSize.fourByFour);
      expect(game.status, GameStatus.idle);
      final (r, c) = findCell(game, 1);
      expect(game.tap(r, c), TapResult.correct);
      expect(game.status, GameStatus.running);
      expect(game.nextNumber, 2);
    });

    test('wrong tap is marked and does not move on', () {
      final game = SchulteGame(GridSize.fourByFour);
      final (r, c) = findCell(game, 5);
      expect(game.tap(r, c), TapResult.wrong);
      expect(game.nextNumber, 1);
      expect((game.wrongRow, game.wrongCol), (r, c));
    });

    test('pause and resume', () {
      final game = SchulteGame(GridSize.fourByFour);
      final (r, c) = findCell(game, 1);
      game.tap(r, c);
      game.pause();
      expect(game.status, GameStatus.paused);
      game.resume();
      expect(game.status, GameStatus.running);
    });

    test('tapping every number finishes the game', () {
      final game = SchulteGame(GridSize.fourByFour);
      TapResult last = TapResult.ignored;
      for (int n = 1; n <= 16; n++) {
        final (r, c) = findCell(game, n);
        last = game.tap(r, c);
      }
      expect(last, TapResult.finished);
      expect(game.status, GameStatus.completed);
    });
  });

  group('Score storage', () {
    setUp(() => SharedPreferences.setMockInitialValues({}));

    test('first score is a new best and is saved', () async {
      expect(await ScoreStorage.addScore(GridSize.fourByFour, 12000), isTrue);
      expect(await ScoreStorage.bestTime(GridSize.fourByFour), 12000);
    });

    test('keeps only the 10 fastest, sorted', () async {
      for (int i = 12; i >= 1; i--) {
        await ScoreStorage.addScore(GridSize.fiveByFive, i * 1000);
      }
      final scores = await ScoreStorage.loadScores(GridSize.fiveByFive);
      expect(scores.length, 10);
      expect(scores.first.timeMs, 1000);
      expect(scores.last.timeMs, 10000);
    });

    test('slower time is not a new best', () async {
      await ScoreStorage.addScore(GridSize.sixBySix, 20000);
      expect(await ScoreStorage.addScore(GridSize.sixBySix, 25000), isFalse);
    });
  });
}
