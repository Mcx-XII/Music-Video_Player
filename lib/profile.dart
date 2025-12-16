import 'package:flutter/material.dart';

class ProfilePage extends StatelessWidget {
  const ProfilePage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFF352F52),
      appBar: AppBar(
        backgroundColor: const Color.fromARGB(255, 34, 27, 68),
        title: const Text("Profile", style: TextStyle(color: Colors.white)),
        iconTheme: const IconThemeData(color: Colors.white),
      ),
      body: const Center(
        child: Text(
          'Halaman Profile',
          style: TextStyle(fontSize: 20, color: Colors.white),
        ),
      ),
    );
  }
}
