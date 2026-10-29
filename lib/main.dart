import 'package:flutter/material.dart';
import 'package:itkalem_sign/core/theme/app_theme.dart';
import 'package:itkalem_sign/features/splash/SplashScreen.dart';
import 'package:shared_preferences/shared_preferences.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  final prefs = await SharedPreferences.getInstance();
  final isDark = prefs.getBool('isDarkMode') ?? false;

  runApp(MyApp(initialDark: isDark));
}

class MyApp extends StatefulWidget {
  final bool initialDark;
  const MyApp({super.key, required this.initialDark});

  @override
  State<MyApp> createState() => MyAppState();

  static MyAppState of(BuildContext context) =>
      context.findAncestorStateOfType<MyAppState>()!;
}

class MyAppState extends State<MyApp> {
  late ThemeMode _themeMode;

  @override
  void initState() {
    super.initState();
    _themeMode = widget.initialDark ? ThemeMode.dark : ThemeMode.light;
  }

  void changeTheme(bool isDark) async {
    setState(() {
      _themeMode = isDark ? ThemeMode.dark : ThemeMode.light;
    });
    final prefs = await SharedPreferences.getInstance();
    await prefs.setBool('isDarkMode', isDark);
  }

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'ITKALEM SIGN',
      theme: lightTheme,
      darkTheme: darkTheme,
      themeMode: _themeMode,
      home: const SplashScreen(),
    );
  }
}