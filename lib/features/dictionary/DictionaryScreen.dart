import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:itkalem_sign/features/dictionary/WordListScreen.dart';

class DictionaryScreen extends StatefulWidget {
  const DictionaryScreen({super.key});

  @override
  State<DictionaryScreen> createState() => _DictionaryScreenState();
}

class _DictionaryScreenState extends State<DictionaryScreen> {
  final GlobalKey<NavigatorState> _navigatorKey = GlobalKey<NavigatorState>();

  @override
  Widget build(BuildContext context) {
    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) async {
        if (didPop) return;

        final NavigatorState? navigator = _navigatorKey.currentState;
        if (navigator != null && navigator.canPop()) {
          navigator.pop();
        }
      },
      child: Navigator(
        key: _navigatorKey,
        onGenerateRoute: (RouteSettings settings) {
          return MaterialPageRoute(
            builder: (context) => _DictionaryHome(),
          );
        },
      ),
    );
  }
}

class _DictionaryHome extends StatefulWidget {
  @override
  State<_DictionaryHome> createState() => _DictionaryHomeState();
}

class _DictionaryHomeState extends State<_DictionaryHome> {
  List<dynamic> _categories = [];
  bool _isLoading = true;

  final Map<String, Map<String, String>> _categoryData = {
    'COMMON': {'name': 'كلمات شائعة', 'desc': 'أهم كلمات اليومية'},
    'FAMILY': {'name': 'العائلة', 'desc': 'الأقارب والوالدين'},
    'GREETINGS': {'name': 'التحيات', 'desc': 'السلام والترحيب'},
    'NUMBERS': {'name': 'الأرقام', 'desc': 'الحساب والعد'},
    'FOOD': {'name': 'الطعام', 'desc': 'وجبات ومشروبات'},
    'EMOTIONS': {'name': 'المشاعر', 'desc': 'التعبير عن النفس'},
  };

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    setState(() => _isLoading = true);
    try {
      final response = await http.get(
        Uri.parse('https://itkalemsign.runasp.net/api/dictionary/categories'),
        headers: {"Accept": "application/json"},
      );

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        setState(() {
          _categories = decodedData['data'] as List<dynamic>;
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF4A90E2);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 30, 20, 10),
                child: Text(
                  'قاموس الإشارة',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                    fontSize: 34,
                    fontWeight: FontWeight.bold,
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 20),
                child: Text(
                  'اختر التصنيف لتعلم الكلمات المناسبة',
                  style: TextStyle(
                    color: Theme.of(context).textTheme.bodyMedium?.color,
                    fontSize: 16,
                  ),
                ),
              ),
              const SizedBox(height: 20),
              Expanded(
                child: _isLoading
                    ? Center(child: CircularProgressIndicator(color: primaryBlue))
                    : _buildGrid(primaryBlue),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildGrid(Color primaryBlue) {
    if (_categories.isEmpty) {
      return const Center(child: Text('لا توجد أقسام متاحة حالياً'));
    }

    return GridView.builder(
      padding: const EdgeInsets.fromLTRB(16, 0, 16, 110),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 12,
        mainAxisSpacing: 12,
        childAspectRatio: 0.82,
      ),
      itemCount: _categories.length,
      itemBuilder: (context, index) {
        final key = _categories[index].toString();
        final name = _categoryData[key]?['name'] ?? key;
        final desc = _categoryData[key]?['desc'] ?? 'تعلم لغة الإشارة';

        return InkWell(
          onTap: () {
            Navigator.of(context).push(
              MaterialPageRoute(
                builder: (context) => WordListScreen(categoryKey: key, categoryName: name),
              ),
            );
          },
          borderRadius: BorderRadius.circular(25),
          child: Container(
            padding: const EdgeInsets.all(12),
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(25),
              border: Border.all(color: Colors.white.withOpacity(0.05), width: 1.5),
              boxShadow: [
                BoxShadow(
                  color: Colors.black.withOpacity(0.04),
                  blurRadius: 10,
                  offset: const Offset(0, 4),
                )
              ],
            ),
            child: Column(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: primaryBlue.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(18),
                  ),
                  child: Icon(Icons.menu_book_rounded, color: primaryBlue, size: 30),
                ),
                const SizedBox(height: 12),
                Text(
                  name,
                  textAlign: TextAlign.center,
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 17,
                    color: Theme.of(context).textTheme.bodyLarge?.color,
                  ),
                ),
                const SizedBox(height: 4),
                Text(
                  desc,
                  textAlign: TextAlign.center,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: TextStyle(
                    fontSize: 12,
                    color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.5),
                  ),
                ),
              ],
            ),
          ),
        );
      },
    );
  }
}