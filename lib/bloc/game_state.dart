import 'package:equatable/equatable.dart';
import '../models/player.dart';
import '../models/game_state.dart';

enum GameStatus {
  disconnected,
  connecting,
  lobby,
  waiting,
  ready,
  playing,
  finished,
  error,
}

class GameBlocState extends Equatable {
  final GameStatus status;
  final String? roomId;
  final Player? currentPlayer;
  final List<Player> players;
  final GameState gameState;
  final String? errorMessage;
  final Map<String, int> scores;

  GameBlocState({
    this.status = GameStatus.disconnected,
    this.roomId,
    this.currentPlayer,
    this.players = const [],
    GameState? gameState,
    this.errorMessage,
    this.scores = const {},
  }) : gameState = gameState ?? GameState();

  GameBlocState copyWith({
    GameStatus? status,
    String? roomId,
    Player? currentPlayer,
    List<Player>? players,
    GameState? gameState,
    String? errorMessage,
    Map<String, int>? scores,
  }) {
    return GameBlocState(
      status: status ?? this.status,
      roomId: roomId ?? this.roomId,
      currentPlayer: currentPlayer ?? this.currentPlayer,
      players: players ?? this.players,
      gameState: gameState ?? this.gameState,
      errorMessage: errorMessage,
      scores: scores ?? this.scores,
    );
  }

  Player? get opponent {
    if (currentPlayer == null || players.isEmpty) return null;
    return players.where((p) => p.id != currentPlayer!.id).firstOrNull;
  }

  bool get isMyTurn => gameState.currentTurn == currentPlayer?.id;

  bool get bothPlayersReady {
    if (players.length < 2) return false;
    return players.every((p) => p.isReady);
  }

  @override
  List<Object?> get props => [
    status,
    roomId,
    currentPlayer,
    players,
    gameState,
    errorMessage,
    scores,
  ];
}
