import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:itkalem_sign/features/dictionary/WordDetailsScreen.dart';

class WordListScreen extends StatefulWidget {
  final String categoryKey;
  final String categoryName;

  const WordListScreen({super.key, required this.categoryKey, required this.categoryName});

  @override
  State<WordListScreen> createState() => _WordListScreenState();
}

class _WordListScreenState extends State<WordListScreen> {
  List<dynamic> _words = [];
  bool _isLoading = true;
  String _errorMessage = '';
  final String baseUrl = "https://itkalemsign.runasp.net";

  @override
  void initState() {
    super.initState();
    _fetchWords();
  }

  Future<void> _fetchWords() async {
    try {
      final url = Uri.parse('$baseUrl/api/dictionary').replace(
        queryParameters: {
          'category': widget.categoryKey,
          'pageSize': '100',
        },
      );

      final response = await http.get(url, headers: {"Accept": "application/json"});

      if (response.statusCode == 200) {
        final Map<String, dynamic> decodedData = jsonDecode(response.body);
        setState(() {
          _words = decodedData['data'] ?? [];
          _isLoading = false;
        });
      } else {
        setState(() {
          _errorMessage = 'حدث خطأ: ${response.statusCode}';
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() {
        _errorMessage = 'خطأ في الاتصال بالسيرفر';
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    final Color primaryBlue = const Color(0xFF4A90E2);

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        title: Text(
          widget.categoryName,
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 20),
        ),
        centerTitle: true,
        elevation: 0,
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).textTheme.bodyLarge?.color,
        iconTheme: IconThemeData(color: primaryBlue),
        leading: IconButton(
          icon: const Icon(Icons.arrow_back_ios, size: 20),
          onPressed: () => Navigator.of(context).pop(),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryBlue))
            : _buildContent(primaryBlue),
      ),
    );
  }

  Widget _buildContent(Color primaryBlue) {
    if (_errorMessage.isNotEmpty) {
      return Center(child: Text(_errorMessage));
    }

    if (_words.isEmpty) {
      return const Center(child: Text('لا توجد كلمات متاحة حالياً'));
    }

    return GridView.builder(
      padding: const EdgeInsets.all(16),
      gridDelegate: const SliverGridDelegateWithFixedCrossAxisCount(
        crossAxisCount: 2,
        crossAxisSpacing: 15,
        mainAxisSpacing: 15,
        childAspectRatio: 0.8,
      ),
      itemCount: _words.length,
      itemBuilder: (context, index) {
        final word = _words[index];

        String rawImgPath = (word['thumbnailUrl'] ?? '').toString();
        String fullImgUrl = "";
        if (rawImgPath.isNotEmpty) {
          fullImgUrl = rawImgPath.startsWith('http') ? rawImgPath : "$baseUrl$rawImgPath";
        }

        return InkWell(
          onTap: () {
            Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => WordDetailsScreen(wordData: word),
              ),
            );
          },
          borderRadius: BorderRadius.circular(20),
          child: Container(
            decoration: BoxDecoration(
              color: Theme.of(context).cardColor,
              borderRadius: BorderRadius.circular(20),
              border: Border.all(color: Colors.white.withOpacity(0.1), width: 1),
            ),
            child: Column(
              children: [
                Expanded(
                  child: ClipRRect(
                    borderRadius: const BorderRadius.vertical(top: Radius.circular(20)),
                    child: Container(
                      color: primaryBlue.withOpacity(0.05),
                      width: double.infinity,
                      child: fullImgUrl.isNotEmpty
                          ? Image.network(
                        fullImgUrl,
                        fit: BoxFit.cover,
                        errorBuilder: (context, error, stackTrace) =>
                            Icon(Icons.broken_image, size: 40, color: primaryBlue),
                      )
                          : Icon(Icons.image_not_supported, size: 40, color: primaryBlue),
                    ),
                  ),
                ),
                Padding(
                  padding: const EdgeInsets.all(12.0),
                  child: Text(
                    word['word'] ?? '',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                    ),
                    textAlign: TextAlign.center,
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