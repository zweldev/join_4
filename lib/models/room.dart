import 'player.dart';
import 'game_state.dart';

enum RoomStatus { waiting, ready, playing, finished }

class Room {
  final String id;
  final List<Player> players;
  final GameState gameState;
  final RoomStatus status;

  Room({
    required this.id,
    List<Player>? players,
    GameState? gameState,
    this.status = RoomStatus.waiting,
  }) : players = players ?? [],
       gameState = gameState ?? GameState();

  factory Room.fromJson(Map<String, dynamic> json) {
    final statusStr = json['status'] as String? ?? 'waiting';
    RoomStatus status;
    switch (statusStr) {
      case 'ready':
        status = RoomStatus.ready;
        break;
      case 'playing':
        status = RoomStatus.playing;
        break;
      case 'finished':
        status = RoomStatus.finished;
        break;
      default:
        status = RoomStatus.waiting;
    }

    return Room(
      id: json['id'] as String,
      players:
          (json['players'] as List<dynamic>?)
              ?.map((p) => Player.fromJson(p as Map<String, dynamic>))
              .toList() ??
          [],
      gameState: json['gameState'] != null
          ? GameState.fromJson(json['gameState'] as Map<String, dynamic>)
          : null,
      status: status,
    );
  }

  Map<String, dynamic> toJson() => {
    'id': id,
    'players': players.map((p) => p.toJson()).toList(),
    'gameState': gameState.toJson(),
    'status': status.name,
  };

  Room copyWith({
    String? id,
    List<Player>? players,
    GameState? gameState,
    RoomStatus? status,
  }) => Room(
    id: id ?? this.id,
    players: players ?? this.players,
    gameState: gameState ?? this.gameState,
    status: status ?? this.status,
  );

  Player? get playerX => players.isNotEmpty ? players[0] : null;
  Player? get playerO => players.length > 1 ? players[1] : null;
  bool get isFull => players.length >= 2;
  int get playerCount => players.length;
}
