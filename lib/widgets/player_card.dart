import 'package:flutter/material.dart';
import '../bloc/game_state.dart';
import '../models/player.dart';
import '../theme/app_theme.dart';

class PlayerCard extends StatelessWidget {
  final Player player;
  final bool isCurrentPlayer;
  final int score;

  const PlayerCard({
    super.key,
    required this.player,
    required this.isCurrentPlayer,
    required this.score,
  });

  Color get _playerColor =>
      player.symbol == 'X' ? AppColors.playerX : AppColors.playerO;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      curve: Curves.easeOutCubic,
      padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 12),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? _playerColor.withValues(alpha: 0.12)
            : AppColors.surface.withValues(alpha: 0.6),
        borderRadius: BorderRadius.circular(16),
        border: Border.all(
          color: isCurrentPlayer
              ? _playerColor.withValues(alpha: 0.7)
              : Colors.white.withValues(alpha: 0.06),
          width: isCurrentPlayer ? 2 : 1,
        ),
        boxShadow: isCurrentPlayer
            ? [
                BoxShadow(
                  color: _playerColor.withValues(alpha: 0.25),
                  blurRadius: 12,
                  offset: const Offset(0, 4),
                ),
              ]
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 44,
            height: 44,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              gradient: RadialGradient(
                colors: [
                  player.symbol == 'X'
                      ? AppColors.playerXLight
                      : AppColors.playerOLight,
                  _playerColor,
                ],
              ),
              boxShadow: [
                BoxShadow(
                  color: _playerColor.withValues(alpha: 0.4),
                  blurRadius: 8,
                ),
              ],
            ),
            child: Center(
              child: Text(
                player.symbol,
                style: theme.textTheme.titleMedium?.copyWith(
                  color: Colors.white,
                  fontWeight: FontWeight.w800,
                ),
              ),
            ),
          ),
          const SizedBox(width: 12),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(
                  player.name,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: theme.textTheme.titleSmall?.copyWith(
                    fontWeight:
                        isCurrentPlayer ? FontWeight.w700 : FontWeight.w500,
                  ),
                ),
                Text(
                  '$score wins',
                  style: theme.textTheme.bodySmall?.copyWith(
                    color: AppColors.textSecondary,
                  ),
                ),
              ],
            ),
          ),
          if (player.isReady)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
              decoration: BoxDecoration(
                color: AppColors.success.withValues(alpha: 0.2),
                borderRadius: BorderRadius.circular(20),
                border: Border.all(color: AppColors.success.withValues(alpha: 0.5)),
              ),
              child: Text(
                'Ready',
                style: theme.textTheme.labelSmall?.copyWith(
                  color: AppColors.success,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
        ],
      ),
    );
  }
}

class ScoreBoard extends StatelessWidget {
  final GameBlocState state;

  const ScoreBoard({super.key, required this.state});

  @override
  Widget build(BuildContext context) {
    final playerX = state.players.isNotEmpty ? state.players[0] : null;
    final playerO = state.players.length > 1 ? state.players[1] : null;

    return Row(
      children: [
        if (playerX != null)
          Expanded(
            child: PlayerCard(
              player: playerX,
              isCurrentPlayer: state.currentPlayer?.id == playerX.id,
              score: state.scores[playerX.id] ?? 0,
            ),
          ),
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 10),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 14, vertical: 8),
            decoration: BoxDecoration(
              gradient: LinearGradient(
                colors: [
                  AppColors.surfaceElevated,
                  AppColors.surface,
                ],
              ),
              borderRadius: BorderRadius.circular(24),
              border: Border.all(color: Colors.white.withValues(alpha: 0.08)),
            ),
            child: Text(
              'VS',
              style: Theme.of(context).textTheme.labelLarge?.copyWith(
                    fontWeight: FontWeight.w800,
                    color: AppColors.textSecondary,
                    letterSpacing: 1.2,
                  ),
            ),
          ),
        ),
        if (playerO != null)
          Expanded(
            child: PlayerCard(
              player: playerO,
              isCurrentPlayer: state.currentPlayer?.id == playerO.id,
              score: state.scores[playerO.id] ?? 0,
            ),
          ),
      ],
    );
  }
}
