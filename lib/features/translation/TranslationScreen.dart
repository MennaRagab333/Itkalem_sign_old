import 'package:flutter/material.dart';
import 'package:itkalem_sign/core/theme/app_theme.dart';
import 'package:itkalem_sign/features/translation/SignToTextPage.dart';
import 'package:itkalem_sign/features/translation/TextToSignPage.dart';

class Translationscreen extends StatelessWidget {
  const Translationscreen({super.key});

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      initialIndex: 1,
      child: Scaffold(
        appBar: AppBar(
          // السطر ده هو اللي بيشيل سهم الرجوع
          automaticallyImplyLeading: false,
          backgroundColor: Theme.of(context).scaffoldBackgroundColor,
          elevation: 0,
          bottom: TabBar(
            indicatorColor: Theme.of(context).primaryColor,
            labelColor: Theme.of(context).primaryColor,
            unselectedLabelColor: Theme.of(context).textTheme.bodyMedium?.color,
            tabs: const [
              Tab(text: "الإشارة إلى نص"),
              Tab(text: "النص إلى إشارة"),
            ],
          ),
        ),
        body: const TabBarView(
          children: [
            SignToTextPage(),
            TextToSignPage(),
          ],
        ),
      ),
    );
  }
}