import 'package:flutter/material.dart';
import 'videopage/video_player_page.dart';
import 'audiopage/audio_page.dart';
import 'searchpage/search_page.dart';
import 'historypage/history_page.dart';
import 'splash_screen.dart';
import 'profilepage/profile.dart';

void main() {
  runApp(const MyApp());
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

class MyHomePage extends StatefulWidget {
  const MyHomePage({super.key, required this.title});

  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  int _currentIndex = 0;

  final List<Widget> _pages = [
    const VideoPlayerPage(
  videoPath: 'assets/videos/sample2.mp4',
  isAsset: true,
),

    const AudioPage(),
    const SearchPage(),
    const HistoryPage(),
  ];

  final List<PreferredSizeWidget Function(BuildContext)> _appBars = [
    (context) => AppBar(
      backgroundColor: const Color.fromARGB(255, 34, 27, 68),
      title: const Text("Video", style: TextStyle(color: Colors.white)),
      centerTitle: true,
      leading: IconButton(
        icon: const Icon(Icons.person_2_outlined),
        color: Colors.white,
        onPressed: () {
          Navigator.push(
            context,
            MaterialPageRoute(builder: (_) => const ProfilePage()),
          );
        },
      ),
      actions: const [Icon(Icons.more_vert, color: Colors.white)],
      bottom: const TabBar(
        indicatorColor: Colors.blue,
        labelColor: Colors.blue,
        unselectedLabelColor: Colors.grey,
        tabs: [
          Tab(text: "Video"),
          Tab(text: "Playlist"),
        ],
      ),
    ),

    (context) => AppBar(
      backgroundColor: const Color.fromARGB(255, 34, 27, 68),
      title: const Text("Audio", style: TextStyle(color: Colors.white)),
      centerTitle: true,
      leading: const Icon(Icons.audiotrack, color: Colors.white),
    ),

    (context) => AppBar(
      backgroundColor: const Color.fromARGB(255, 34, 27, 68),
      title: const Text("Telusuri", style: TextStyle(color: Colors.white)),
      centerTitle: true,
      actions: const [Icon(Icons.search, color: Colors.white)],
    ),

    (context) => AppBar(
      backgroundColor: const Color.fromARGB(255, 34, 27, 68),
      title: const Text("Riwayat", style: TextStyle(color: Colors.white)),
      centerTitle: true,
    ),
  ];

  @override
  Widget build(BuildContext context) {
    final isVideo = _currentIndex == 0;

    Widget scaffold = Scaffold(
      appBar: _appBars[_currentIndex](context),
      body: _pages[_currentIndex],
      bottomNavigationBar: BottomNavigationBar(
        currentIndex: _currentIndex,
        type: BottomNavigationBarType.fixed,
        backgroundColor: const Color.fromARGB(255, 34, 27, 68),
        selectedItemColor: const Color(0xFF3713EC),
        unselectedItemColor: Colors.grey,
        onTap: (index) {
          setState(() {
            _currentIndex = index;
          });
        },
        items: const [
          BottomNavigationBarItem(icon: Icon(Icons.video_call), label: 'Video'),
          BottomNavigationBarItem(icon: Icon(Icons.audiotrack), label: 'Audio'),
          BottomNavigationBarItem(icon: Icon(Icons.search), label: 'Telusuri'),
          BottomNavigationBarItem(icon: Icon(Icons.history), label: 'Riwayat'),
        ],
      ),
    );

    if (isVideo) {
      return DefaultTabController(length: 2, child: scaffold);
    }

    return scaffold;
  }
}
