import 'package:flutter/material.dart';
import '../theme/app_theme.dart';

class GameBoard extends StatelessWidget {
  final List<List<String?>> board;
  final List<List<int>>? winningPattern;
  final bool isMyTurn;
  final bool isGameOver;
  final Function(int column) onColumnTap;

  const GameBoard({
    super.key,
    required this.board,
    this.winningPattern,
    required this.isMyTurn,
    required this.isGameOver,
    required this.onColumnTap,
  });

  bool _isWinningCell(int row, int col) {
    if (winningPattern == null) return false;
    return winningPattern!.any((pos) => pos[0] == row && pos[1] == col);
  }

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Center(
        child: AspectRatio(
          aspectRatio: 7 / 6,
          child: Container(
            decoration: BoxDecoration(
              borderRadius: BorderRadius.circular(20),
              gradient: const LinearGradient(
                begin: Alignment.topLeft,
                end: Alignment.bottomRight,
                colors: [AppColors.boardFrame, AppColors.boardFrameDark],
              ),
              boxShadow: [
                BoxShadow(
                  color: AppColors.boardFrame.withValues(alpha: 0.45),
                  blurRadius: 28,
                  spreadRadius: -4,
                  offset: const Offset(0, 12),
                ),
                BoxShadow(
                  color: Colors.black.withValues(alpha: 0.5),
                  blurRadius: 24,
                  offset: const Offset(0, 16),
                ),
              ],
            ),
            padding: const EdgeInsets.all(10),
            child: Row(
              children: List.generate(7, (col) {
                return Expanded(
                  child: GestureDetector(
                    onTap: isGameOver || !isMyTurn ? null : () => onColumnTap(col),
                    behavior: HitTestBehavior.opaque,
                    child: Column(
                      children: List.generate(6, (row) {
                        final cell = board[row][col];
                        final isWinning = _isWinningCell(row, col);
                        return Expanded(
                          child: Padding(
                            padding: const EdgeInsets.all(4),
                            child: _DiscCell(
                              symbol: cell,
                              isWinning: isWinning,
                            ),
                          ),
                        );
                      }),
                    ),
                  ),
                );
              }),
            ),
          ),
        ),
      ),
    );
  }
}

class _DiscCell extends StatelessWidget {
  const _DiscCell({required this.symbol, required this.isWinning});

  final String? symbol;
  final bool isWinning;

  @override
  Widget build(BuildContext context) {
    if (symbol == null) {
      return DecoratedBox(
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.slotEmpty,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withValues(alpha: 0.6),
              blurRadius: 4,
              offset: const Offset(0, 2),
            ),
          ],
        ),
      );
    }

    final isX = symbol == 'X';
    final base = isX ? AppColors.playerX : AppColors.playerO;
    final highlight = isX ? AppColors.playerXLight : AppColors.playerOLight;

    return DecoratedBox(
      decoration: BoxDecoration(
        shape: BoxShape.circle,
        gradient: RadialGradient(
          center: const Alignment(-0.35, -0.4),
          radius: 0.95,
          colors: [highlight, base, base.withValues(alpha: 0.92)],
          stops: const [0.0, 0.45, 1.0],
        ),
        border: isWinning
            ? Border.all(color: Colors.white, width: 3)
            : null,
        boxShadow: [
          BoxShadow(
            color: base.withValues(alpha: 0.5),
            blurRadius: isWinning ? 14 : 8,
            spreadRadius: isWinning ? 1 : 0,
          ),
          BoxShadow(
            color: Colors.black.withValues(alpha: 0.35),
            blurRadius: 4,
            offset: const Offset(0, 3),
          ),
        ],
      ),
    );
  }
}
