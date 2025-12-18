import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

import 'audio/equalizer_state.dart';
import 'splash_screen.dart';
import 'videopage/video_page.dart';
import 'audiopage/audio_page.dart';
import 'searchpage/search_page.dart';
import 'historypage/history_page.dart';
import 'profilepage/profile.dart';

void main() {
  runApp(
    ChangeNotifierProvider(
      create: (_) => EqualizerState(),
      child: const MyApp(),
    ),
  );
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      initialRoute: '/',
      routes: {
        '/': (context) => const SplashScreen(),
        '/home': (context) => const MyHomePage(title: 'ViAuo'),
      },
      title: 'ViAuo',
      theme: ThemeData(
        scaffoldBackgroundColor: const Color.fromARGB(255, 54, 45, 94),
      ),
    );
  }
}
