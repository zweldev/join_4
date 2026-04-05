import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../widgets/game_board.dart';
import '../widgets/player_card.dart';
import 'lobby_screen.dart';

class GameScreen extends StatelessWidget {
  const GameScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameBlocState>(
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        if (state.status == GameStatus.lobby ||
            state.status == GameStatus.waiting && state.players.isEmpty) {
          Navigator.of(context).pushReplacement(
            MaterialPageRoute(builder: (_) => const LobbyScreen()),
          );
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) {
              _showLeaveDialog(context);
            }
          },
          child: Scaffold(
            appBar: AppBar(
              title: Text('Room: ${state.roomId ?? ""}'),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  icon: const Icon(Icons.exit_to_app),
                  onPressed: () => _showLeaveDialog(context),
                ),
              ],
            ),
            body: SafeArea(
              child: Padding(
                padding: const EdgeInsets.all(16),
                child: Column(
                  children: [
                    ScoreBoard(state: state),
                    const SizedBox(height: 16),
                    if (state.status == GameStatus.waiting)
                      _buildWaitingState(context, state),
                    if (state.status == GameStatus.ready)
                      _buildReadyState(context, state),
                    if (state.status == GameStatus.playing)
                      Expanded(child: _buildGameBoard(context, state)),
                    if (state.status == GameStatus.finished)
                      Expanded(child: _buildGameOver(context, state)),
                  ],
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaitingState(BuildContext context, GameBlocState state) {
    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const CircularProgressIndicator(),
            const SizedBox(height: 24),
            Text(
              'Waiting for opponent...',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 16),
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                color: Colors.grey[200],
                borderRadius: BorderRadius.circular(12),
              ),
              child: Column(
                children: [
                  const Text('Share this room ID with your friend:'),
                  const SizedBox(height: 8),
                  SelectableText(
                    state.roomId ?? '',
                    style: const TextStyle(
                      fontSize: 32,
                      fontWeight: FontWeight.bold,
                      letterSpacing: 4,
                    ),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyState(BuildContext context, GameBlocState state) {
    final isPlayerReady = state.currentPlayer?.isReady ?? false;
    final bothReady = state.bothPlayersReady;

    return Expanded(
      child: Center(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Text(
              bothReady ? 'Starting...' : 'Ready up!',
              style: Theme.of(context).textTheme.headlineSmall,
            ),
            const SizedBox(height: 24),
            if (!bothReady)
              ElevatedButton(
                onPressed: () {
                  context.read<GameBloc>().add(const PlayerReady());
                },
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(
                    horizontal: 48,
                    vertical: 16,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                ),
                child: Text(
                  isPlayerReady ? 'Ready ✓' : 'Ready!',
                  style: const TextStyle(fontSize: 20),
                ),
              ),
            if (bothReady) const CircularProgressIndicator(),
          ],
        ),
      ),
    );
  }

  Widget _buildGameBoard(BuildContext context, GameBlocState state) {
    return Column(
      children: [
        Container(
          padding: const EdgeInsets.all(12),
          decoration: BoxDecoration(
            color: state.isMyTurn
                ? Colors.green.withOpacity(0.2)
                : Colors.grey.withOpacity(0.1),
            borderRadius: BorderRadius.circular(12),
          ),
          child: Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Icon(
                state.isMyTurn ? Icons.circle : Icons.hourglass_empty,
                color: state.isMyTurn ? Colors.green : Colors.grey,
              ),
              const SizedBox(width: 8),
              Text(
                state.isMyTurn
                    ? 'Your turn!'
                    : '${state.opponent?.name ?? "Opponent"}\'s turn',
                style: TextStyle(
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                  color: state.isMyTurn ? Colors.green : Colors.grey,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 16),
        GameBoard(
          board: state.gameState.board,
          winningPattern: state.gameState.winningPattern,
          isMyTurn: state.isMyTurn,
          isGameOver: false,
          onColumnTap: (column) {
            context.read<GameBloc>().add(MakeMove(column));
          },
        ),
      ],
    );
  }

  Widget _buildGameOver(BuildContext context, GameBlocState state) {
    final isWinner = state.gameState.winnerId == state.currentPlayer?.id;
    final isDraw = state.gameState.isDraw;

    String message;
    if (isDraw) {
      message = "It's a Draw!";
    } else if (isWinner) {
      message = 'You Won! 🎉';
    } else {
      message =
          '${state.gameState.winnerId != null ? state.opponent?.name : "Opponent"} Won!';
    }

    return Column(
      mainAxisAlignment: MainAxisAlignment.center,
      children: [
        GameBoard(
          board: state.gameState.board,
          winningPattern: state.gameState.winningPattern,
          isMyTurn: false,
          isGameOver: true,
          onColumnTap: (_) {},
        ),
        const SizedBox(height: 24),
        Text(
          message,
          style: Theme.of(context).textTheme.headlineMedium?.copyWith(
            fontWeight: FontWeight.bold,
            color: isDraw
                ? Colors.grey
                : isWinner
                ? Colors.green
                : Colors.red,
          ),
        ),
        const SizedBox(height: 24),
        ElevatedButton(
          onPressed: () {
            context.read<GameBloc>().add(const RestartGame());
          },
          style: ElevatedButton.styleFrom(
            padding: const EdgeInsets.symmetric(horizontal: 48, vertical: 16),
            shape: RoundedRectangleBorder(
              borderRadius: BorderRadius.circular(12),
            ),
          ),
          child: const Text('Play Again', style: TextStyle(fontSize: 18)),
        ),
      ],
    );
  }

  void _showLeaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave Room?'),
        content: const Text('Are you sure you want to leave this room?'),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Cancel'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<GameBloc>().add(const LeaveRoom());
            },
            style: ElevatedButton.styleFrom(backgroundColor: Colors.red),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}
