import 'package:flutter/material.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen>
    with SingleTickerProviderStateMixin {

  late AnimationController _controller;

  @override
  void initState() {
    super.initState();

    _controller = AnimationController(
      vsync: this,
      duration: const Duration(seconds: 2),
    )..repeat();

    Future.delayed(const Duration(seconds: 3), () {
      Navigator.pushReplacementNamed(context, '/home');
    });
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF352F52),
      body: Center(
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [

            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: const [
                Icon(Icons.music_note, color: Colors.white, size: 80),
                SizedBox(height: 10),
                Icon(Icons.video_call, color: Colors.white, size: 80),
              ],
            ),

            const SizedBox(height: 30),

            const Text(
              "Loading",
              style: TextStyle(color: Colors.white),
            ),

            const SizedBox(height: 20),

            SizedBox(
              width: 200,
              child: LinearProgressIndicator(
                valueColor:
                    AlwaysStoppedAnimation<Color>(Colors.white),
                backgroundColor: Colors.white30,
              ),
            ),
          ],
        ),
      ),
    );
  }
}
