import 'package:flutter/material.dart';
import '../bloc/game_state.dart';
import '../models/player.dart';

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

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: isCurrentPlayer
            ? Colors.blue.withOpacity(0.2)
            : Colors.grey.withOpacity(0.1),
        borderRadius: BorderRadius.circular(12),
        border: isCurrentPlayer
            ? Border.all(color: Colors.blue, width: 2)
            : null,
      ),
      child: Row(
        children: [
          Container(
            width: 40,
            height: 40,
            decoration: BoxDecoration(
              color: player.symbol == 'X' ? Colors.red : Colors.yellow,
              shape: BoxShape.circle,
            ),
            child: Center(
              child: Text(
                player.symbol,
                style: const TextStyle(
                  color: Colors.white,
                  fontWeight: FontWeight.bold,
                  fontSize: 18,
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
                  style: TextStyle(
                    fontWeight: isCurrentPlayer
                        ? FontWeight.bold
                        : FontWeight.normal,
                    fontSize: 16,
                  ),
                ),
                Text(
                  'Score: $score',
                  style: TextStyle(color: Colors.grey[600], fontSize: 12),
                ),
              ],
            ),
          ),
          if (player.isReady)
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
              decoration: BoxDecoration(
                color: Colors.green,
                borderRadius: BorderRadius.circular(12),
              ),
              child: const Text(
                'Ready',
                style: TextStyle(
                  color: Colors.white,
                  fontSize: 12,
                  fontWeight: FontWeight.bold,
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
        const SizedBox(width: 8),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
          decoration: BoxDecoration(
            color: Colors.grey[800],
            borderRadius: BorderRadius.circular(20),
          ),
          child: const Text(
            'VS',
            style: TextStyle(color: Colors.white, fontWeight: FontWeight.bold),
          ),
        ),
        const SizedBox(width: 8),
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
