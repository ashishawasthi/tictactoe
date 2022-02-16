import 'package:flutter/material.dart';
import 'package:flutter_game_sample/src/achievements/achievements_screen.dart';
import 'package:flutter_game_sample/src/achievements/player_progress.dart';
import 'package:flutter_game_sample/src/achievements/score.dart';
import 'package:flutter_game_sample/src/level_selection/level_selection_screen.dart';
import 'package:flutter_game_sample/src/level_selection/levels.dart';
import 'package:flutter_game_sample/src/main_menu/main_menu_screen.dart';
import 'package:flutter_game_sample/src/play_session/play_session_screen.dart';
import 'package:flutter_game_sample/src/settings/settings.dart';
import 'package:flutter_game_sample/src/settings/settings_screen.dart';
import 'package:flutter_game_sample/src/win_game/win_game_screen.dart';
import 'package:go_router/go_router.dart';
import 'package:logging/logging.dart' hide Level;
import 'package:provider/provider.dart';

void main() {
  Logger.root.onRecord.listen((record) {
    debugPrint('${record.level.name}: ${record.time}: ${record.message}');
  });

  debugPrint('Starting app');
  runApp(
    MyApp(
      playerProgressPersistentStore: MemoryOnlyPlayerProgressPersistentStore(),
    ),
  );
}

class MyApp extends StatelessWidget {
  static final _router = GoRouter(
    routes: [
      GoRoute(
          path: '/',
          builder: (context, state) => const MainMenuScreen(),
          routes: [
            GoRoute(
                path: 'play',
                builder: (context, state) => const LevelSelectionScreen(),
                routes: [
                  GoRoute(
                    path: 'session',
                    builder: (context, state) {
                      if (state.extra == null || state.extra is! Level) {
                        // TODO: redirect somewhere else?
                        throw ArgumentError.value(state.extra);
                      }
                      final level = state.extra! as Level;
                      return PlaySessionScreen(level);
                    },
                  ),
                  GoRoute(
                    path: 'won',
                    builder: (context, state) =>
                        WinGameScreen(score: state.extra! as Score),
                  )
                ]),
            GoRoute(
              path: 'settings',
              builder: (context, state) => const SettingsScreen(),
            ),
            GoRoute(
              path: 'achievements',
              builder: (context, state) => const AchievementsScreen(),
            ),
          ]),
    ],
  );

  final PlayerProgressPersistentStore playerProgressPersistentStore;

  const MyApp({required this.playerProgressPersistentStore, Key? key})
      : super(key: key);

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) {
            var progress = PlayerProgress(playerProgressPersistentStore);
            progress.getLatestFromStore();
            return progress;
          },
        ),
        ChangeNotifierProvider(
          create: (context) => Settings(),
        ),
      ],
      child: MaterialApp.router(
        title: 'Flutter Demo',
        theme: ThemeData(
          useMaterial3: true,
          primarySwatch: Colors.red,
        ),
        routeInformationParser: _router.routeInformationParser,
        routerDelegate: _router.routerDelegate,
      ),
    );
  }
}