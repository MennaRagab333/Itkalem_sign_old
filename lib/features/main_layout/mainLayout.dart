import 'package:flutter/material.dart';
import 'package:itkalem_sign/features/dictionary/DictionaryScreen.dart';
import 'package:itkalem_sign/features/learning/levels/beginners/BeginnerLevelScreen.dart';
import 'package:itkalem_sign/features/settings/SettingScreen.dart';
import 'package:itkalem_sign/features/translation/TranslationScreen.dart';
import '../home/home_screen.dart';

class MainScreen extends StatefulWidget {
  final String userName;
  final String userEmail;
  final String userPhone;

  const MainScreen({
    super.key,
    this.userName = "User",
    this.userEmail = "",
    this.userPhone = "",
  });

  @override
  State<MainScreen> createState() => _MainScreenState();
}

class _MainScreenState extends State<MainScreen> {
  int _selectedIndex = 0;

  void _onFeatureNavigation(int index) {
    setState(() {
      _selectedIndex = index;
    });
  }

  @override
  Widget build(BuildContext context) {
    final List<Widget> pages = [
      HomeScreen(
        userName: widget.userName,
        onFeatureTap: _onFeatureNavigation,
      ),
      const Translationscreen(),
      BeginnerScreen(
        onBack: () => setState(() => _selectedIndex = 0),
      ),
      const DictionaryScreen(),
      SettingsScreen(
        userName: widget.userName,
        userEmail: widget.userEmail,
        userPhone: widget.userPhone,
      ),
    ];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      extendBody: true,
      body: IndexedStack(
        index: _selectedIndex,
        children: pages,
      ),
      bottomNavigationBar: SafeArea(
        child: Padding(
          padding: const EdgeInsets.fromLTRB(20, 0, 20, 15),
          child: Container(
            height: 65,
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(25),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.3),
                  blurRadius: 15,
                  offset: const Offset(0, 8),
                ),
              ],
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(25),
              child: BottomNavigationBar(
                currentIndex: _selectedIndex,
                onTap: (index) => setState(() => _selectedIndex = index),
                type: BottomNavigationBarType.fixed,
                backgroundColor: Colors.transparent,
                elevation: 0,
                selectedItemColor: const Color(0xFF4A90E2),
                unselectedItemColor: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.3),
                showSelectedLabels: true,
                showUnselectedLabels: false,
                items: const [
                  BottomNavigationBarItem(icon: Icon(Icons.home_rounded), label: 'الرئيسية'),
                  BottomNavigationBarItem(icon: Icon(Icons.translate_rounded), label: 'ترجمة'),
                  BottomNavigationBarItem(icon: Icon(Icons.school_rounded), label: 'تعلم'),
                  BottomNavigationBarItem(icon: Icon(Icons.menu_book_rounded), label: 'قاموس'),
                  BottomNavigationBarItem(icon: Icon(Icons.settings_rounded), label: 'إعدادات'),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }
}