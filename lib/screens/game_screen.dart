import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../bloc/game_bloc.dart';
import '../bloc/game_event.dart';
import '../bloc/game_state.dart';
import '../theme/app_theme.dart';
import '../widgets/game_board.dart';
import '../widgets/player_card.dart';
import 'lobby_screen.dart';

class GameScreen extends StatefulWidget {
  const GameScreen({super.key});

  @override
  State<GameScreen> createState() => _GameScreenState();
}

class _GameScreenState extends State<GameScreen> {
  bool _hasNavigatedToLobby = false;

  @override
  Widget build(BuildContext context) {
    return BlocConsumer<GameBloc, GameBlocState>(
      listenWhen: (prev, curr) =>
          prev.status != curr.status || prev.errorMessage != curr.errorMessage,
      listener: (context, state) {
        if (state.errorMessage != null) {
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(SnackBar(content: Text(state.errorMessage!)));
        }
        if (!_hasNavigatedToLobby &&
            (state.status == GameStatus.lobby ||
                state.status == GameStatus.disconnected)) {
          _hasNavigatedToLobby = true;
          Navigator.of(context).pushAndRemoveUntil(
            MaterialPageRoute(builder: (_) => const LobbyScreen()),
            (route) => false,
          );
        }
      },
      builder: (context, state) {
        return PopScope(
          canPop: false,
          onPopInvokedWithResult: (didPop, result) {
            if (!didPop) _showLeaveDialog(context);
          },
          child: Scaffold(
            extendBodyBehindAppBar: true,
            appBar: AppBar(
              title: Text(
                state.roomId != null ? 'Room ${state.roomId}' : 'Connect 4',
              ),
              automaticallyImplyLeading: false,
              actions: [
                IconButton(
                  tooltip: 'Leave room',
                  icon: const Icon(Icons.logout_rounded),
                  onPressed: () => _showLeaveDialog(context),
                ),
              ],
            ),
            body: AppGradientBackground(
              child: SafeArea(
                child: Padding(
                  padding: const EdgeInsets.fromLTRB(16, 8, 16, 16),
                  child: Column(
                    children: [
                      ScoreBoard(state: state),
                      const SizedBox(height: 16),
                      if (state.status == GameStatus.waiting)
                        Expanded(child: _buildWaitingState(context, state)),
                      if (state.status == GameStatus.ready)
                        Expanded(child: _buildReadyState(context, state)),
                      if (state.status == GameStatus.playing)
                        Expanded(child: _buildGameBoard(context, state)),
                      if (state.status == GameStatus.finished)
                        Expanded(child: _buildGameOver(context, state)),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  Widget _buildWaitingState(BuildContext context, GameBlocState state) {
    final theme = Theme.of(context);

    return Center(
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 28, vertical: 32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            const SizedBox(
              width: 40,
              height: 40,
              child: CircularProgressIndicator(
                strokeWidth: 3,
                color: AppColors.accent,
              ),
            ),
            const SizedBox(height: 24),
            Text(
              'Waiting for opponent',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              'Share this code so they can join',
              style: theme.textTheme.bodyMedium?.copyWith(
                color: AppColors.textSecondary,
              ),
            ),
            const SizedBox(height: 24),
            _RoomCodeChip(roomId: state.roomId ?? ''),
          ],
        ),
      ),
    );
  }

  Widget _buildReadyState(BuildContext context, GameBlocState state) {
    final theme = Theme.of(context);
    final isPlayerReady = state.currentPlayer?.isReady ?? false;
    final bothReady = state.bothPlayersReady;

    return Center(
      child: AppCard(
        padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 36),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Icon(
              bothReady
                  ? Icons.rocket_launch_rounded
                  : Icons.sports_esports_rounded,
              size: 48,
              color: bothReady ? AppColors.warning : AppColors.accent,
            ),
            const SizedBox(height: 20),
            Text(
              bothReady ? 'Starting game…' : 'Ready up!',
              style: theme.textTheme.headlineSmall?.copyWith(
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            if (!bothReady)
              isPlayerReady
                  ? Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const SizedBox(
                          width: 18,
                          height: 18,
                          child: CircularProgressIndicator(
                            strokeWidth: 2,
                            color: AppColors.accent,
                          ),
                        ),
                        const SizedBox(width: 10),
                        Text(
                          'Waiting for another player',
                          style: theme.textTheme.bodySmall?.copyWith(
                            color: AppColors.textSecondary,
                          ),
                        ),
                      ],
                    )
                  : Text(
                      'Both players must tap ready',
                      style: theme.textTheme.bodyMedium?.copyWith(
                        color: AppColors.textSecondary,
                      ),
                    ),
            const SizedBox(height: 28),
            if (!bothReady)
              ElevatedButton(
                onPressed: isPlayerReady
                    ? null
                    : () => context.read<GameBloc>().add(const PlayerReady()),
                style: ElevatedButton.styleFrom(
                  backgroundColor: isPlayerReady
                      ? AppColors.success
                      : AppColors.accent,
                  disabledBackgroundColor: AppColors.success.withValues(
                    alpha: 0.35,
                  ),
                ),
                child: Text(isPlayerReady ? 'You\'re ready ✓' : 'I\'m ready'),
              ),
            if (bothReady)
              const SizedBox(
                width: 36,
                height: 36,
                child: CircularProgressIndicator(
                  strokeWidth: 3,
                  color: AppColors.accent,
                ),
              ),
          ],
        ),
      ),
    );
  }

  Widget _buildGameBoard(BuildContext context, GameBlocState state) {
    return Column(
      children: [
        _TurnBanner(state: state),
        const SizedBox(height: 12),
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
    final theme = Theme.of(context);
    final isWinner = state.gameState.winnerId == state.currentPlayer?.id;
    final isDraw = state.gameState.isDraw;

    final Color accentColor;
    final IconData icon;
    String message;

    if (isDraw) {
      message = "It's a draw";
      accentColor = AppColors.textSecondary;
      icon = Icons.handshake_rounded;
    } else if (isWinner) {
      message = 'You won!';
      accentColor = AppColors.success;
      icon = Icons.emoji_events_rounded;
    } else {
      message = '${state.opponent?.name ?? 'Opponent'} won';
      accentColor = AppColors.error;
      icon = Icons.sentiment_dissatisfied_rounded;
    }

    return Column(
      children: [
        GameBoard(
          board: state.gameState.board,
          winningPattern: state.gameState.winningPattern,
          isMyTurn: false,
          isGameOver: true,
          onColumnTap: (_) {},
        ),
        const SizedBox(height: 20),
        Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            color: accentColor.withValues(alpha: 0.12),
            borderRadius: BorderRadius.circular(16),
            border: Border.all(color: accentColor.withValues(alpha: 0.4)),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Icon(icon, color: accentColor, size: 28),
              const SizedBox(width: 12),
              Text(
                message,
                style: theme.textTheme.headlineSmall?.copyWith(
                  fontWeight: FontWeight.w800,
                  color: accentColor,
                ),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        ElevatedButton(
          onPressed: () => context.read<GameBloc>().add(const RestartGame()),
          child: const Text('Play again'),
        ),
      ],
    );
  }

  void _showLeaveDialog(BuildContext context) {
    showDialog(
      context: context,
      builder: (ctx) => AlertDialog(
        title: const Text('Leave room?'),
        content: const Text(
          'You will return to the lobby and disconnect from this match.',
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.of(ctx).pop(),
            child: const Text('Stay'),
          ),
          ElevatedButton(
            onPressed: () {
              Navigator.of(ctx).pop();
              context.read<GameBloc>().add(const LeaveRoom());
            },
            style: ElevatedButton.styleFrom(backgroundColor: AppColors.error),
            child: const Text('Leave'),
          ),
        ],
      ),
    );
  }
}

class _TurnBanner extends StatelessWidget {
  const _TurnBanner({required this.state});

  final GameBlocState state;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final myTurn = state.isMyTurn;
    final color = myTurn ? AppColors.success : AppColors.textSecondary;

    return AnimatedContainer(
      duration: const Duration(milliseconds: 250),
      padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 12),
      decoration: BoxDecoration(
        color: color.withValues(alpha: myTurn ? 0.15 : 0.08),
        borderRadius: BorderRadius.circular(14),
        border: Border.all(color: color.withValues(alpha: myTurn ? 0.5 : 0.2)),
      ),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Container(
            width: 10,
            height: 10,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              color: myTurn ? AppColors.success : AppColors.textSecondary,
              boxShadow: myTurn
                  ? [
                      BoxShadow(
                        color: AppColors.success.withValues(alpha: 0.6),
                        blurRadius: 8,
                      ),
                    ]
                  : null,
            ),
          ),
          const SizedBox(width: 10),
          Text(
            myTurn
                ? 'Your turn — tap a column'
                : "${state.opponent?.name ?? 'Opponent'}'s turn",
            style: theme.textTheme.titleSmall?.copyWith(
              fontWeight: FontWeight.w600,
              color: myTurn ? AppColors.textPrimary : AppColors.textSecondary,
            ),
          ),
        ],
      ),
    );
  }
}

class _RoomCodeChip extends StatelessWidget {
  const _RoomCodeChip({required this.roomId});

  final String roomId;

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);

    return Material(
      color: AppColors.backgroundBottom.withValues(alpha: 0.5),
      borderRadius: BorderRadius.circular(14),
      child: InkWell(
        onTap: () {
          Clipboard.setData(ClipboardData(text: roomId));
          ScaffoldMessenger.of(
            context,
          ).showSnackBar(const SnackBar(content: Text('Room ID copied')));
        },
        borderRadius: BorderRadius.circular(14),
        child: Container(
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 16),
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(14),
            border: Border.all(
              color: AppColors.accent.withValues(alpha: 0.35),
              width: 1.5,
            ),
          ),
          child: Row(
            mainAxisSize: MainAxisSize.min,
            children: [
              Text(
                roomId,
                style: theme.textTheme.headlineMedium?.copyWith(
                  fontWeight: FontWeight.w800,
                  letterSpacing: 6,
                  color: AppColors.accent,
                ),
              ),
              const SizedBox(width: 12),
              Icon(
                Icons.copy_rounded,
                size: 22,
                color: AppColors.accent.withValues(alpha: 0.8),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
