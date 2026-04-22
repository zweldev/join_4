import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'bloc/game_bloc.dart';
import 'screens/lobby_screen.dart';

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
      theme: ThemeData.dark().copyWith(
        scaffoldBackgroundColor: const Color(0xFF161D27),
        appBarTheme: const AppBarTheme(
          backgroundColor: Color(0xFF161D27),
          elevation: 0,
        ),
        colorScheme: const ColorScheme.dark(
          primary: Color(0xFF25B18F),
          secondary: Color(0xFFF26B70),
        ),
      ),
        home: const LobbyScreen(),
      ),
    );
  }
}
