import 'package:flutter/material.dart';

import '../theme/app_theme.dart';
import '../widgets/game_card.dart';
import 'start_screen.dart';

/// The first screen: a grid of game cards.
class HomeScreen extends StatelessWidget {
  final bool isDark;
  final VoidCallback onToggleTheme;

  const HomeScreen({
    super.key,
    required this.isDark,
    required this.onToggleTheme,
  });

  @override
  Widget build(BuildContext context) {
    final colors = AppColors.of(context);

    return Scaffold(
      appBar: AppBar(
        title: const Text('Mini Games'),
        actions: [
          IconButton(
            icon: Icon(isDark ? Icons.light_mode : Icons.dark_mode),
            tooltip: isDark ? 'Light mode' : 'Dark mode',
            onPressed: onToggleTheme,
          ),
        ],
      ),
      body: LayoutBuilder(
        builder: (context, constraints) {
          // Fit as many 160px-wide cards per row as the screen allows (1 to 4).
          final columns = (constraints.maxWidth / 180).floor().clamp(1, 4);

          return ListView(
            padding: const EdgeInsets.all(16),
            children: [
              Row(
                children: [
                  Icon(Icons.touch_app, size: 20, color: colors.accent),
                  const SizedBox(width: 8),
                  Text(
                    'Reaction',
                    style: TextStyle(
                      color: colors.textPrimary,
                      fontWeight: FontWeight.w600,
                      fontSize: 16,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              GridView.count(
                crossAxisCount: columns,
                shrinkWrap: true,
                physics: const NeverScrollableScrollPhysics(),
                mainAxisSpacing: 16,
                crossAxisSpacing: 16,
                childAspectRatio: 0.9,
                children: [
                  GameCard(
                    icon: Icons.grid_4x4,
                    title: 'Schulte Grid',
                    description:
                        'Train your focus! Tap numbers 1 to N in order as fast as you can.',
                    onTap: () => Navigator.push(
                      context,
                      MaterialPageRoute(builder: (_) => const StartScreen()),
                    ),
                  ),
                ],
              ),
            ],
          );
        },
      ),
    );
  }
}
