import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:itkalem_sign/features/learning/CoursesScreen.dart';

class BeginnerScreen extends StatefulWidget {
  final VoidCallback onBack;

  const BeginnerScreen({super.key, required this.onBack});

  @override
  State<BeginnerScreen> createState() => _BeginnerScreenState();
}

class _BeginnerScreenState extends State<BeginnerScreen> {
  final String staticLevelId = "fdac2793-3c00-4419-9487-1933d2b16841";

  List<dynamic> categories = [];
  bool _isLoading = true;
  final String baseUrl = "https://itkalemsign.runasp.net";
  final Color primaryBlue = const Color(0xFF4A90E2);
  final Color lightBlue = const Color(0xFF81B4ED);
  Widget? _activeSubPage;

  @override
  void initState() {
    super.initState();
    _fetchCategories();
  }

  Future<void> _fetchCategories() async {
    final url = Uri.parse('$baseUrl/api/categories?levelId=$staticLevelId');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final Map<String, dynamic> responseData = jsonDecode(response.body);
        setState(() {
          categories = responseData['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  void _closeSubPage() {
    setState(() => _activeSubPage = null);
  }

  @override
  Widget build(BuildContext context) {
    if (_activeSubPage != null) return _activeSubPage!;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        automaticallyImplyLeading: false,
        title: Text(
          'المستويات',
          style: TextStyle(
              color: Theme.of(context).textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold
          ),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.ltr,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryBlue))
            : categories.isEmpty
            ? const Center(child: Text("لا توجد تصنيفات متاحة حالياً"))
            : ListView.builder(
          padding: const EdgeInsets.all(20),
          itemCount: categories.length,
          itemBuilder: (context, index) {
            final item = categories[index];
            String? imgUrl;
            if (item['imageUrl'] != null && item['imageUrl'].toString().isNotEmpty) {
              imgUrl = item['imageUrl'].toString().startsWith('http')
                  ? item['imageUrl']
                  : "$baseUrl${item['imageUrl']}";
            }

            String fullName = item['name'] ?? '';
            List<String> nameParts = fullName.split(' ');
            String firstWord = nameParts.isNotEmpty ? nameParts[0] : '';
            String remainingName = nameParts.length > 1 ? nameParts.sublist(1).join(' ') : '';

            return Padding(
              padding: const EdgeInsets.only(bottom: 16),
              child: _buildItem(
                context,
                imageUrl: imgUrl,
                firstWord: firstWord,
                restOfTitle: remainingName,
                onTap: () {
                  setState(() {
                    _activeSubPage = CoursesScreen(
                      categoryId: item['id'],
                      levelId: staticLevelId,
                      categoryName: item['name'] ?? '',
                      onBack: _closeSubPage,
                    );
                  });
                },
              ),
            );
          },
        ),
      ),
    );
  }

  Widget _buildItem(BuildContext context, {
    String? imageUrl,
    required String firstWord,
    required String restOfTitle,
    required VoidCallback onTap
  }) {
    return InkWell(
      onTap: onTap,
      borderRadius: BorderRadius.circular(26),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 20),
        decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(26),
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.03),
              blurRadius: 10,
              offset: const Offset(0, 4),
            )
          ],
          border: Border.all(color: Colors.white.withOpacity(0.05)),
        ),
        child: Row(
          children: [
            Container(
              width: 70, height: 70,
              decoration: BoxDecoration(
                  color: primaryBlue.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(20)
              ),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(20),
                child: imageUrl != null
                    ? Image.network(imageUrl, fit: BoxFit.cover, errorBuilder: (context, error, stackTrace) => Icon(Icons.category, color: primaryBlue))
                    : Icon(Icons.category, color: primaryBlue),
              ),
            ),
            const SizedBox(width: 18),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(
                    "المستوى",
                    style: TextStyle(
                        color: lightBlue,
                        fontSize: 12,
                        fontWeight: FontWeight.w600,
                        letterSpacing: 0.5
                    ),
                  ),
                  const SizedBox(height: 2),
                  Text(
                    firstWord,
                    style: TextStyle(
                        color: Theme.of(context).textTheme.bodyLarge?.color,
                        fontSize: 20,
                        fontWeight: FontWeight.w800
                    ),
                  ),
                  if (restOfTitle.isNotEmpty)
                    Text(
                      restOfTitle,
                      style: TextStyle(
                          color: Colors.grey.withOpacity(0.8),
                          fontSize: 14,
                          fontWeight: FontWeight.w500
                      ),
                    ),
                ],
              ),
            ),
            Icon(Icons.arrow_forward_ios, color: primaryBlue.withOpacity(0.4), size: 18),
          ],
        ),
      ),
    );
  }
}