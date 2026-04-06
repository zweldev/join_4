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
      child: Container(
        decoration: BoxDecoration(
          color: Colors.blue.shade800,
          borderRadius: BorderRadius.circular(16),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.3),
              blurRadius: 10,
              offset: const Offset(0, 5),
            ),
          ],
        ),
        padding: const EdgeInsets.all(8),
        child: Column(
          children: [
            Expanded(
              child: Row(
                children: List.generate(7, (col) {
                  return Expanded(
                    child: GestureDetector(
                      onTap: isGameOver || !isMyTurn
                          ? null
                          : () => onColumnTap(col),
                      child: Container(
                        margin: const EdgeInsets.all(2),
                        decoration: BoxDecoration(
                          color: Colors.blue.shade600,
                          borderRadius: BorderRadius.circular(8),
                        ),
                        child: const Center(
                          child: Icon(
                            Icons.arrow_drop_down,
                            color: Colors.white54,
                          ),
                        ),
                      ),
                    ),
                  );
                }),
              ),
            ),
            Expanded(
              flex: 5,
              child: Column(
                children: List.generate(6, (row) {
                  return Expanded(
                    child: Row(
                      children: List.generate(7, (col) {
                        final cell = board[row][col];
                        final isWinning = _isWinningCell(row, col);

                        return Expanded(
                          child: Container(
                            margin: const EdgeInsets.all(3),
                            decoration: BoxDecoration(
                              color: Colors.white,
                              shape: BoxShape.circle,
                              boxShadow: isWinning
                                  ? [
                                      BoxShadow(
                                        color: Colors.yellow.withOpacity(0.8),
                                        blurRadius: 10,
                                        spreadRadius: 2,
                                      ),
                                    ]
                                  : null,
                            ),
                            child: cell == null
                                ? null
                                : Center(
                                    child: Container(
                                      width: double.infinity,
                                      height: double.infinity,
                                      margin: const EdgeInsets.all(4),
                                      decoration: BoxDecoration(
                                        color: cell == 'X'
                                            ? Colors.red
                                            : Colors.yellow,
                                        shape: BoxShape.circle,
                                        border: isWinning
                                            ? Border.all(
                                                color: Colors.green,
                                                width: 3,
                                              )
                                            : null,
                                      ),
                                    ),
                                  ),
                          ),
                        );
                      }),
                    ),
                  );
                }),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
