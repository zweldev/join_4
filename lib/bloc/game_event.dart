import 'package:equatable/equatable.dart';
import '../models/player.dart';
import '../models/room.dart';

abstract class GameEvent extends Equatable {
  const GameEvent();

  @override
  List<Object?> get props => [];
}

class ConnectToServer extends GameEvent {
  final String serverUrl;

  const ConnectToServer(this.serverUrl);

  @override
  List<Object?> get props => [serverUrl];
}

class CreateRoom extends GameEvent {
  final String playerName;

  const CreateRoom(this.playerName);

  @override
  List<Object?> get props => [playerName];
}

class JoinRoom extends GameEvent {
  final String roomId;
  final String playerName;

  const JoinRoom(this.roomId, this.playerName);

  @override
  List<Object?> get props => [roomId, playerName];
}

class PlayerReady extends GameEvent {
  const PlayerReady();
}

class MakeMove extends GameEvent {
  final int column;

  const MakeMove(this.column);

  @override
  List<Object?> get props => [column];
}

class RestartGame extends GameEvent {
  const RestartGame();
}

class LeaveRoom extends GameEvent {
  const LeaveRoom();
}

class RoomCreated extends GameEvent {
  final String roomId;
  final Player player;

  const RoomCreated(this.roomId, this.player);

  @override
  List<Object?> get props => [roomId, player];
}

class PlayerJoined extends GameEvent {
  final String? roomId;
  final Player player;
  final List<Player> players;

  const PlayerJoined(this.roomId, this.player, this.players);

  @override
  List<Object?> get props => [roomId, player, players];
}

class OpponentJoined extends GameEvent {
  final Player player;
  final List<Player> players;

  const OpponentJoined(this.player, this.players);

  @override
  List<Object?> get props => [player, players];
}

class PlayerReadyUpdate extends GameEvent {
  final String playerId;
  final List<Player> players;

  const PlayerReadyUpdate(this.playerId, this.players);

  @override
  List<Object?> get props => [playerId, players];
}

class GameStarted extends GameEvent {
  final List<List<String?>> board;
  final String currentTurn;
  final List<Player> players;

  const GameStarted(this.board, this.currentTurn, this.players);

  @override
  List<Object?> get props => [board, currentTurn, players];
}

class MoveMade extends GameEvent {
  final String playerId;
  final int column;
  final int row;
  final List<List<String?>> board;
  final String currentTurn;

  const MoveMade(
    this.playerId,
    this.column,
    this.row,
    this.board,
    this.currentTurn,
  );

  @override
  List<Object?> get props => [playerId, column, row, board, currentTurn];
}

class GameOver extends GameEvent {
  final String? winnerId;
  final String? winnerName;
  final bool isDraw;
  final List<List<int>>? winningPattern;
  final List<List<String?>> board;
  final Map<String, int> scores;
  final String? reason;

  const GameOver({
    this.winnerId,
    this.winnerName,
    this.isDraw = false,
    this.winningPattern,
    required this.board,
    required this.scores,
    this.reason,
  });

  @override
  List<Object?> get props => [
    winnerId,
    winnerName,
    isDraw,
    winningPattern,
    board,
    scores,
    reason,
  ];
}

class GameRestarted extends GameEvent {
  final List<List<String?>> board;
  final List<Player> players;

  const GameRestarted(this.board, this.players);

  @override
  List<Object?> get props => [board, players];
}

class PlayerLeft extends GameEvent {
  final Player remainingPlayer;

  const PlayerLeft(this.remainingPlayer);

  @override
  List<Object?> get props => [remainingPlayer];
}

class RoomClosed extends GameEvent {
  const RoomClosed();
}

class ErrorReceived extends GameEvent {
  final String message;

  const ErrorReceived(this.message);

  @override
  List<Object?> get props => [message];
}

class Reconnected extends GameEvent {
  final Room room;

  const Reconnected(this.room);

  @override
  List<Object?> get props => [room];
}

class Disconnected extends GameEvent {
  const Disconnected();
}
