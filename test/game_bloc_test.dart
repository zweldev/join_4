import 'package:flutter_test/flutter_test.dart';
import 'package:join4/bloc/game_bloc.dart';
import 'package:join4/bloc/game_event.dart';
import 'package:join4/bloc/game_state.dart';
import 'package:join4/models/player.dart';

void main() {
  // These tests exercise the GameBloc event handlers without opening an
  // actual WebSocket. The singleton WebSocketService is used, but since we
  // never dispatch `ConnectToServer`, no channel is ever opened, and `send`
  // is guarded by an `_isConnected` check so outgoing messages are dropped
  // silently (which is exactly what we want for these regression tests).

  group('GameBloc - leave/rejoin flow (regression for crash on leave)', () {
    late GameBloc bloc;

    setUp(() {
      bloc = GameBloc();
    });

    tearDown(() async {
      await bloc.close();
    });

    test(
      'RoomCreated populates the players list with the creator so the '
      'GameScreen listener does not treat it as "empty room / leave"',
      () async {
        final creator = Player(id: 'p1', name: 'Alice', symbol: 'X');

        bloc.add(RoomCreated('ROOM123', creator));
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.status, GameStatus.waiting);
        expect(bloc.state.roomId, 'ROOM123');
        expect(bloc.state.currentPlayer?.id, 'p1');
        expect(
          bloc.state.players.map((p) => p.id).toList(),
          ['p1'],
          reason:
              'Creator must be present in the players list so `players.isEmpty` '
              'is never true while status is `waiting`.',
        );
      },
    );

    test(
      'LeaveRoom resets the state to a clean lobby so the player can '
      'create/join a new room afterwards',
      () async {
        // Put the bloc into an in-game state first.
        final me = Player(id: 'p1', name: 'Alice', symbol: 'X');
        final opponent = Player(id: 'p2', name: 'Bob', symbol: 'O');
        bloc.add(PlayerJoined('ROOM123', me, [me, opponent]));
        await Future<void>.delayed(Duration.zero);
        expect(bloc.state.status, GameStatus.ready);
        expect(bloc.state.roomId, 'ROOM123');

        // Now leave the room.
        bloc.add(const LeaveRoom());
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.status, GameStatus.lobby);
        expect(bloc.state.roomId, isNull);
        expect(bloc.state.currentPlayer, isNull);
        expect(bloc.state.players, isEmpty);
        expect(bloc.state.errorMessage, 'You left the room');

        // Simulate the server accepting a new CreateRoom request.
        final newMe = Player(id: 'p3', name: 'Alice', symbol: 'X');
        bloc.add(RoomCreated('ROOM999', newMe));
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.status, GameStatus.waiting);
        expect(bloc.state.roomId, 'ROOM999');
        expect(bloc.state.currentPlayer?.id, 'p3');
        expect(
          bloc.state.players.map((p) => p.id).toList(),
          ['p3'],
          reason:
              'After leaving and creating a new room, the players list must '
              'contain the creator. Otherwise the old GameScreen listener '
              'condition `waiting && players.isEmpty` would incorrectly '
              'bounce the user back to the lobby, causing the "crash".',
        );
      },
    );

    test(
      'LeaveRoom is a no-op when there is no active room, but still '
      'resets state to lobby so the user can create/join a new room',
      () async {
        // Bloc starts in disconnected state; no roomId / currentPlayer.
        expect(bloc.state.roomId, isNull);
        expect(bloc.state.currentPlayer, isNull);

        bloc.add(const LeaveRoom());
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.status, GameStatus.lobby);
      },
    );

    test(
      'PlayerLeft (opponent leaves) redirects the remaining player back to '
      'the lobby with an informational error message',
      () async {
        final me = Player(id: 'p1', name: 'Alice', symbol: 'X');
        final opponent = Player(id: 'p2', name: 'Bob', symbol: 'O');
        bloc.add(PlayerJoined('ROOM123', me, [me, opponent]));
        await Future<void>.delayed(Duration.zero);

        bloc.add(PlayerLeft(me));
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.status, GameStatus.lobby);
        expect(bloc.state.roomId, isNull);
        expect(bloc.state.currentPlayer, isNull);
        expect(bloc.state.players, isEmpty);
        expect(
          bloc.state.errorMessage,
          'Your opponent left the room',
          reason:
              'The remaining player should be informed that the opponent left '
              'so the UI can show a snackbar before navigating to the lobby.',
        );
      },
    );

    test(
      'LeaveRoom followed by a stale PlayerLeft event does not overwrite the '
      'local leave message',
      () async {
        final me = Player(id: 'p1', name: 'Alice', symbol: 'X');
        final opponent = Player(id: 'p2', name: 'Bob', symbol: 'O');
        bloc.add(PlayerJoined('ROOM123', me, [me, opponent]));
        await Future<void>.delayed(Duration.zero);

        bloc.add(const LeaveRoom());
        await Future<void>.delayed(Duration.zero);

        bloc.add(PlayerLeft(opponent));
        await Future<void>.delayed(Duration.zero);

        expect(bloc.state.status, GameStatus.lobby);
        expect(bloc.state.errorMessage, 'You left the room');
      },
    );
  });
}
