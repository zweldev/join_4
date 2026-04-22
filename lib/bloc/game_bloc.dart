import 'package:flutter_bloc/flutter_bloc.dart';
import '../models/player.dart';
import '../models/game_state.dart';
import '../models/room.dart';
import '../services/websocket_service.dart';
import 'game_event.dart';
import 'game_state.dart';

class GameBloc extends Bloc<GameEvent, GameBlocState> {
  final WebSocketService _wsService;

  GameBloc({WebSocketService? wsService})
    : _wsService = wsService ?? WebSocketService(),
      super(GameBlocState()) {
    _wsService.addHandler(_handleServerMessage);

    on<ConnectToServer>(_onConnectToServer);
    on<CreateRoom>(_onCreateRoom);
    on<JoinRoom>(_onJoinRoom);
    on<PlayerReady>(_onPlayerReady);
    on<MakeMove>(_onMakeMove);
    on<RestartGame>(_onRestartGame);
    on<LeaveRoom>(_onLeaveRoom);
    on<RoomCreated>(_onRoomCreated);
    on<PlayerJoined>(_onPlayerJoined);
    on<OpponentJoined>(_onOpponentJoined);
    on<PlayerReadyUpdate>(_onPlayerReadyUpdate);
    on<GameStarted>(_onGameStarted);
    on<MoveMade>(_onMoveMade);
    on<GameOver>(_onGameOver);
    on<GameRestarted>(_onGameRestarted);
    on<PlayerLeft>(_onPlayerLeft);
    on<RoomClosed>(_onRoomClosed);
    on<ErrorReceived>(_onErrorReceived);
    on<Reconnected>(_onReconnected);
    on<Disconnected>(_onDisconnected);
  }

  void _handleServerMessage(Map<String, dynamic> message) {
    final event = message['event'] as String?;

    switch (event) {
      case 'room_created':
        add(
          RoomCreated(
            message['roomId'] as String,
            Player.fromJson(message['player'] as Map<String, dynamic>),
          ),
        );
        break;

      case 'player_joined':
        add(
          PlayerJoined(
            message['roomId'] as String?,
            Player.fromJson(message['player'] as Map<String, dynamic>),
            (message['players'] as List<dynamic>)
                .map((p) => Player.fromJson(p as Map<String, dynamic>))
                .toList(),
          ),
        );
        break;

      case 'opponent_joined':
        add(
          OpponentJoined(
            Player.fromJson(message['player'] as Map<String, dynamic>),
            (message['players'] as List<dynamic>)
                .map((p) => Player.fromJson(p as Map<String, dynamic>))
                .toList(),
          ),
        );
        break;

      case 'player_ready':
        final playerId = message['playerId'] as String?;
        if (playerId != null) {
          add(
            PlayerReadyUpdate(
              playerId,
              (message['players'] as List<dynamic>)
                  .map((p) => Player.fromJson(p as Map<String, dynamic>))
                  .toList(),
            ),
          );
        }
        break;

      case 'game_started':
        add(
          GameStarted(
            (message['board'] as List<dynamic>)
                .map(
                  (row) =>
                      (row as List<dynamic>).map((c) => c as String?).toList(),
                )
                .toList(),
            message['currentTurn'] as String,
            (message['players'] as List<dynamic>)
                .map((p) => Player.fromJson(p as Map<String, dynamic>))
                .toList(),
          ),
        );
        break;

      case 'move_made':
        add(
          MoveMade(
            message['playerId'] as String,
            message['column'] as int,
            message['row'] as int,
            (message['board'] as List<dynamic>)
                .map(
                  (row) =>
                      (row as List<dynamic>).map((c) => c as String?).toList(),
                )
                .toList(),
            message['currentTurn'] as String,
          ),
        );
        break;

      case 'game_over':
        final scoresRaw = message['scores'] as Map<String, dynamic>?;
        final scores =
            scoresRaw?.map((key, value) => MapEntry(key, value as int)) ?? {};
        add(
          GameOver(
            winnerId: message['winnerId'] as String?,
            winnerName: message['winnerName'] as String?,
            isDraw: message['isDraw'] as bool? ?? false,
            winningPattern: (message['winningPattern'] as List<dynamic>?)
                ?.map((p) => (p as List<dynamic>).map((e) => e as int).toList())
                .toList(),
            board: (message['board'] as List<dynamic>)
                .map(
                  (row) =>
                      (row as List<dynamic>).map((c) => c as String?).toList(),
                )
                .toList(),
            scores: scores,
            reason: message['reason'] as String?,
          ),
        );
        break;

      case 'game_restarted':
        add(
          GameRestarted(
            (message['board'] as List<dynamic>)
                .map(
                  (row) =>
                      (row as List<dynamic>).map((c) => c as String?).toList(),
                )
                .toList(),
            (message['players'] as List<dynamic>)
                .map((p) => Player.fromJson(p as Map<String, dynamic>))
                .toList(),
          ),
        );
        break;

      case 'player_left':
        add(
          PlayerLeft(
            Player.fromJson(message['remainingPlayer'] as Map<String, dynamic>),
          ),
        );
        break;

      case 'room_closed':
        add(const RoomClosed());
        break;

      case 'reconnected':
        add(
          Reconnected(Room.fromJson(message['room'] as Map<String, dynamic>)),
        );
        break;

      case 'error':
        add(ErrorReceived(message['message'] as String? ?? 'Unknown error'));
        break;
    }
  }

  void _onConnectToServer(
    ConnectToServer event,
    Emitter<GameBlocState> emit,
  ) async {
    // If the WebSocket is already connected, do not re-emit the
    // `connecting -> lobby` transition. That transition can re-trigger
    // navigation listeners on screens that are still in the widget tree
    // during a route transition (e.g. GameScreen right after LeaveRoom),
    // causing a navigation loop where the lobby gets pushed multiple times.
    if (_wsService.isConnected) {
      if (state.status != GameStatus.lobby) {
        emit(state.copyWith(status: GameStatus.lobby));
      }
      return;
    }

    emit(state.copyWith(status: GameStatus.connecting));
    try {
      await _wsService.connect(event.serverUrl);
      emit(state.copyWith(status: GameStatus.lobby));
    } catch (e) {
      emit(
        state.copyWith(
          status: GameStatus.error,
          errorMessage: 'Failed to connect: $e',
        ),
      );
    }
  }

  void _onCreateRoom(CreateRoom event, Emitter<GameBlocState> emit) {
    _wsService.send({'event': 'create_room', 'name': event.playerName});
  }

  void _onJoinRoom(JoinRoom event, Emitter<GameBlocState> emit) {
    _wsService.send({
      'event': 'join_room',
      'roomId': event.roomId,
      'name': event.playerName,
    });
  }

  void _onPlayerReady(PlayerReady event, Emitter<GameBlocState> emit) {
    if (state.roomId == null || state.currentPlayer == null) return;
    _wsService.send({
      'event': 'player_ready',
      'roomId': state.roomId,
      'playerId': state.currentPlayer!.id,
    });
  }

  void _onMakeMove(MakeMove event, Emitter<GameBlocState> emit) {
    if (state.roomId == null || state.currentPlayer == null) return;
    if (!state.isMyTurn) return;

    _wsService.send({
      'event': 'make_move',
      'roomId': state.roomId,
      'playerId': state.currentPlayer!.id,
      'column': event.column,
    });
  }

  void _onRestartGame(RestartGame event, Emitter<GameBlocState> emit) {
    if (state.roomId == null || state.currentPlayer == null) return;
    _wsService.send({
      'event': 'restart_game',
      'roomId': state.roomId,
      'playerId': state.currentPlayer!.id,
    });
  }

  void _onLeaveRoom(LeaveRoom event, Emitter<GameBlocState> emit) {
    if (state.roomId != null && state.currentPlayer != null) {
      _wsService.send({
        'event': 'leave_room',
        'roomId': state.roomId,
        'playerId': state.currentPlayer!.id,
      });
    }
    // Always reset to a clean lobby state so the player can create/join
    // a new room after leaving.
    emit(GameBlocState(status: GameStatus.lobby));
  }

  void _onRoomCreated(RoomCreated event, Emitter<GameBlocState> emit) {
    emit(
      state.copyWith(
        status: GameStatus.waiting,
        roomId: event.roomId,
        currentPlayer: event.player,
        players: [event.player],
      ),
    );
  }

  void _onPlayerJoined(PlayerJoined event, Emitter<GameBlocState> emit) {
    emit(
      state.copyWith(
        status: GameStatus.ready,
        roomId: event.roomId,
        currentPlayer: event.player,
        players: event.players,
      ),
    );
  }

  void _onOpponentJoined(OpponentJoined event, Emitter<GameBlocState> emit) {
    emit(state.copyWith(status: GameStatus.ready, players: event.players));
  }

  void _onPlayerReadyUpdate(
    PlayerReadyUpdate event,
    Emitter<GameBlocState> emit,
  ) {
    final updatedPlayers = state.players.map((p) {
      if (p.id == event.playerId) {
        return p.copyWith(isReady: true);
      }
      return p;
    }).toList();

    emit(state.copyWith(players: updatedPlayers));
  }

  void _onGameStarted(GameStarted event, Emitter<GameBlocState> emit) {
    final updatedPlayers = event.players.map((p) {
      return p.copyWith(isReady: true);
    }).toList();

    emit(
      state.copyWith(
        status: GameStatus.playing,
        players: updatedPlayers,
        gameState: GameState(
          board: event.board,
          currentTurn: event.currentTurn,
        ),
      ),
    );
  }

  void _onMoveMade(MoveMade event, Emitter<GameBlocState> emit) {
    emit(
      state.copyWith(
        gameState: GameState(
          board: event.board,
          currentTurn: event.currentTurn,
        ),
      ),
    );
  }

  void _onGameOver(GameOver event, Emitter<GameBlocState> emit) {
    emit(
      state.copyWith(
        status: GameStatus.finished,
        gameState: GameState(
          board: event.board,
          winnerId: event.winnerId,
          winningPattern: event.winningPattern,
          isDraw: event.isDraw,
        ),
        scores: event.scores,
      ),
    );
  }

  void _onGameRestarted(GameRestarted event, Emitter<GameBlocState> emit) {
    final updatedPlayers = event.players.map((p) {
      return p.copyWith(isReady: false);
    }).toList();

    emit(
      state.copyWith(
        status: GameStatus.ready,
        players: updatedPlayers,
        gameState: GameState(board: event.board),
      ),
    );
  }

  void _onPlayerLeft(PlayerLeft event, Emitter<GameBlocState> emit) {
    // When the opponent leaves, redirect the remaining player back to the
    // lobby as well (instead of leaving them stuck in a "waiting" state
    // with no-one to play against). An info message is surfaced via
    // `errorMessage` so the GameScreen listener can show a snackbar before
    // navigating.
    emit(
      GameBlocState(
        status: GameStatus.lobby,
        errorMessage: 'Your opponent left the room',
      ),
    );
  }

  void _onRoomClosed(RoomClosed event, Emitter<GameBlocState> emit) {
    emit(GameBlocState(status: GameStatus.lobby));
  }

  void _onErrorReceived(ErrorReceived event, Emitter<GameBlocState> emit) {
    emit(state.copyWith(errorMessage: event.message));
  }

  void _onReconnected(Reconnected event, Emitter<GameBlocState> emit) {
    emit(
      state.copyWith(
        status: _mapRoomStatus(event.room.status),
        roomId: event.room.id,
        players: event.room.players,
        gameState: event.room.gameState,
      ),
    );
  }

  void _onDisconnected(Disconnected event, Emitter<GameBlocState> emit) {
    emit(GameBlocState(status: GameStatus.disconnected));
  }

  GameStatus _mapRoomStatus(RoomStatus status) {
    switch (status) {
      case RoomStatus.waiting:
        return GameStatus.waiting;
      case RoomStatus.ready:
        return GameStatus.ready;
      case RoomStatus.playing:
        return GameStatus.playing;
      case RoomStatus.finished:
        return GameStatus.finished;
    }
  }

  @override
  Future<void> close() {
    _wsService.removeHandler(_handleServerMessage);
    _wsService.disconnect();
    return super.close();
  }
}
