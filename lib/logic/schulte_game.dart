import 'dart:math';

import '../models/grid_size.dart';

/// The four states a game can be in.
enum GameStatus { idle, running, paused, completed }

/// What happened when the player tapped a cell.
enum TapResult { correct, wrong, finished, ignored }

/// The rules of the Schulte Grid game, written in plain Dart.
///
/// This class has no Flutter code in it, so it is easy to test.
class SchulteGame {
  final GridSize size;
  late List<List<int>> grid;
  int nextNumber = 1;
  GameStatus status = GameStatus.idle;

  /// Position of the last wrong tap (null when there is none).
  int? wrongRow;
  int? wrongCol;

  /// Dart's built-in stopwatch measures the time. Stopping it while the
  /// app is in the background means paused time is not counted.
  final Stopwatch _stopwatch = Stopwatch();

  SchulteGame(this.size, {Random? random}) {
    grid = generateGrid(size, random ?? Random());
  }

  /// Elapsed time in milliseconds.
  int get elapsedMs => _stopwatch.elapsedMilliseconds;

  /// Fraction of numbers found so far (0.0 to 1.0), for the progress bar.
  double get progress => (nextNumber - 1) / size.total;

  /// Creates a shuffled grid using the Fisher-Yates shuffle.
  static List<List<int>> generateGrid(GridSize size, Random random) {
    final numbers = List<int>.generate(size.total, (i) => i + 1);
    for (int i = numbers.length - 1; i > 0; i--) {
      final j = random.nextInt(i + 1);
      final temp = numbers[i];
      numbers[i] = numbers[j];
      numbers[j] = temp;
    }
    // Cut the list into rows.
    final rows = <List<int>>[];
    for (int r = 0; r < size.dimension; r++) {
      rows.add(numbers.sublist(r * size.dimension, (r + 1) * size.dimension));
    }
    return rows;
  }

  /// Handles a tap on the cell at [row], [col].
  TapResult tap(int row, int col) {
    if (status == GameStatus.completed || status == GameStatus.paused) {
      return TapResult.ignored;
    }

    if (grid[row][col] != nextNumber) {
      wrongRow = row;
      wrongCol = col;
      return TapResult.wrong;
    }

    clearWrongTap();

    // The timer starts when the player taps 1.
    if (status == GameStatus.idle) {
      status = GameStatus.running;
      _stopwatch.start();
    }

    nextNumber++;

    // The timer stops when the last number is tapped.
    if (nextNumber > size.total) {
      _stopwatch.stop();
      status = GameStatus.completed;
      return TapResult.finished;
    }
    return TapResult.correct;
  }

  void clearWrongTap() {
    wrongRow = null;
    wrongCol = null;
  }

  /// Called when the app goes to the background.
  void pause() {
    if (status != GameStatus.running) return;
    _stopwatch.stop();
    status = GameStatus.paused;
  }

  /// Called when the app comes back to the front.
  void resume() {
    if (status != GameStatus.paused) return;
    _stopwatch.start();
    status = GameStatus.running;
  }

  /// Formats milliseconds as MM:SS.hh, e.g. 00:19.58.
  static String formatTime(int ms) {
    final minutes = ms ~/ 60000;
    final seconds = (ms % 60000) ~/ 1000;
    final hundredths = (ms % 1000) ~/ 10;
    return '${minutes.toString().padLeft(2, '0')}:'
        '${seconds.toString().padLeft(2, '0')}.'
        '${hundredths.toString().padLeft(2, '0')}';
  }
}
