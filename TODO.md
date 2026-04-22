# Bug Fix: Player Leave Crashes Screen

## Steps
- [x] Fix `lib/screens/game_screen.dart` listener condition (main bug)
- [x] Fix `lib/bloc/game_bloc.dart` `_onRoomCreated` to populate players list
- [x] Fix `lib/bloc/game_bloc.dart` `_onLeaveRoom` to always reset state
- [x] Fix `lib/screens/lobby_screen.dart` to avoid redundant reconnect
- [x] Verify with `flutter analyze` (only pre-existing deprecation warnings remain)
- [x] Add regression tests in `test/game_bloc_test.dart` — **all 4 tests pass**
