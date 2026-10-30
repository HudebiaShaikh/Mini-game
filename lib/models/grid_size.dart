/// The three grid sizes the player can choose.
enum GridSize {
  fourByFour(4),
  fiveByFive(5),
  sixBySix(6);

  /// Number of rows (and columns).
  final int dimension;
  const GridSize(this.dimension);

  /// How many numbers are on the grid, e.g. 5x5 = 25.
  int get total => dimension * dimension;

  /// Short label shown on screen, e.g. "5x5".
  String get label => '${dimension}x$dimension';

  /// Name used when saving scores, e.g. "schulte_grid_5x5".
  String get storageKey => 'schulte_grid_$label';
}
