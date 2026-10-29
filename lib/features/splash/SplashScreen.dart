import 'dart:async';
import 'package:flutter/material.dart';
import 'package:shared_preferences/shared_preferences.dart';
import '../auth/login/LoginScreen.dart';
import '../main_layout/mainLayout.dart';

class SplashScreen extends StatefulWidget {
  const SplashScreen({super.key});

  @override
  State<SplashScreen> createState() => _SplashScreenState();
}

class _SplashScreenState extends State<SplashScreen> {
  @override
  void initState() {
    super.initState();
    _navigate();
  }

  Future<void> _navigate() async {
    await Future.delayed(const Duration(seconds: 5));

    final prefs = await SharedPreferences.getInstance();
    bool isLoggedIn = prefs.getBool('isLoggedIn') ?? false;

    if (!mounted) return;

    if (isLoggedIn) {
      String userName = prefs.getString('userName') ?? "User";
      String userEmail = prefs.getString('userEmail') ?? "";
      String userPhone = prefs.getString('userPhone') ?? "";

      Navigator.pushReplacement(
        context,
        MaterialPageRoute(
          builder: (_) => MainScreen(
            userName: userName,
            userEmail: userEmail,
            userPhone: userPhone,
          ),
        ),
      );
    } else {
      Navigator.pushReplacement(
        context,
        MaterialPageRoute(builder: (_) => const LoginScreen()),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    bool isDark = Theme.of(context).brightness == Brightness.dark;

    return Scaffold(
      body: Container(
        width: double.infinity,
        height: double.infinity,
        decoration: BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.2,
            colors: isDark
                ? [const Color(0xFF0D1B2E), const Color(0xFF050A10)]
                : [const Color(0xFFE3EDF7), const Color(0xFFF5F7FA)],
          ),
        ),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Container(
              decoration: BoxDecoration(
                shape: BoxShape.circle,
                boxShadow: [
                  BoxShadow(
                    color: Colors.blue.withOpacity(0.2),
                    blurRadius: 50,
                    spreadRadius: 20,
                  ),
                ],
              ),
              child: CircleAvatar(
                radius: 70,
                backgroundColor: Theme.of(context).scaffoldBackgroundColor,
                child: ClipOval(
                  child: Image.asset(
                    'assets/images/img_4.png',
                    width: 140,
                    height: 140,
                    fit: BoxFit.cover,
                  ),
                ),
              ),
            ),
            const SizedBox(height: 50),
            RichText(
              text: TextSpan(
                style: const TextStyle(
                  fontSize: 28,
                  fontWeight: FontWeight.bold,
                  letterSpacing: 4,
                ),
                children: [
                  TextSpan(
                    text: 'ITKALEM ',
                    style: TextStyle(
                      color: isDark ? Colors.white : const Color(0xFF1A1D23),
                    ),
                  ),
                  const TextSpan(
                    text: 'SIGN',
                    style: TextStyle(color: Color(0xFF4A90E2)),
                  ),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}