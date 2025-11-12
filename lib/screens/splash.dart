import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';

class Splash extends StatefulWidget {
  const Splash({super.key});

  @override
  State<Splash> createState() => _SplashState();
}

class _SplashState extends State<Splash> {
  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _checkFirstOpen();
  }

  void _checkFirstOpen() async {
    final prefs = await SharedPreferences.getInstance();
    final isFirstOpen = prefs.getBool('isFirstOpen') ?? true;

    await Future.delayed(const Duration(seconds: 1));

    if (mounted) {
      if (isFirstOpen) {
        Navigator.pushReplacementNamed(context, '/get-started');
      } else {
        Navigator.pushReplacementNamed(context, '/authenticate');
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: const Color(0xFFF7F9FB),
      body: Center(
        child: Container(
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: Colors.blue.shade50,
          ),
          padding: const EdgeInsets.all(18),
          child: Transform.rotate(
            angle: 3 * 3.1415926535897932 / 2, // 270 degrees in radians
            child: const Icon(
              Icons.vpn_key_rounded,
              size: 128,
              color: Colors.blueAccent,
            ),
          ),
        ),
      ),
    );
  }
}
