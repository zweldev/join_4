import 'package:flutter/material.dart';

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
              color: const Color(0xFF324050),
              borderRadius: BorderRadius.circular(24),
            ),
            padding: const EdgeInsets.all(8),
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

                        Color cellColor = const Color(0xFF11161D);
                        if (cell == 'X') {
                          cellColor = const Color(0xFFF26B70);
                        } else if (cell == 'O') {
                          cellColor = const Color(0xFF25B18F);
                        }

                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(6),
                            decoration: BoxDecoration(
                              color: cellColor,
                              shape: BoxShape.circle,
                              border: isWinning
                                  ? Border.all(
                                      color: Colors.white,
                                      width: 4,
                                    )
                                  : null,
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
