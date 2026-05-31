import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/game_bloc.dart';
import 'screens/lobby_screen.dart';
import 'theme/app_theme.dart';

void main() {
  runApp(const Connect4App());
}

class Connect4App extends StatelessWidget {
  const Connect4App({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocProvider(
      create: (_) => GameBloc(),
      child: MaterialApp(
        title: 'Connect 4',
        debugShowCheckedModeBanner: false,
        theme: AppTheme.dark,
        home: const LobbyScreen(),
      ),
    );
  }
}
