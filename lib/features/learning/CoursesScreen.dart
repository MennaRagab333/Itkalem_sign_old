import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:itkalem_sign/features/learning/levels/beginners/LessonsScreen.dart';

class CoursesScreen extends StatefulWidget {
  final dynamic categoryId;
  final dynamic levelId;
  final String categoryName;
  final VoidCallback onBack;

  const CoursesScreen({
    super.key,
    required this.categoryId,
    required this.levelId,
    required this.categoryName,
    required this.onBack,
  });

  @override
  State<CoursesScreen> createState() => _CoursesScreenState();
}

class _CoursesScreenState extends State<CoursesScreen> {
  List<dynamic> _courses = [];
  bool _isLoading = true;
  final String baseUrl = "https://itkalemsign.runasp.net";

  @override
  void initState() {
    super.initState();
    _fetchCourses();
  }

  String _formatTitle(String title) {
    List<String> words = title.trim().split(' ');
    if (words.length <= 1) return title;
    return words.sublist(1).join(' ');
  }

  Future<void> _fetchCourses() async {
    final url = Uri.parse('$baseUrl/api/Courses?categoryId=${widget.categoryId}');
    try {
      final response = await http.get(url);
      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);
        setState(() {
          List<dynamic> dataList = [];
          if (responseData is List) {
            dataList = responseData;
          } else if (responseData is Map && responseData['data'] != null) {
            dataList = responseData['data'];
          }

          _courses = dataList.where((course) {
            return course['categoryId'].toString() == widget.categoryId.toString() &&
                course['levelId'].toString() == widget.levelId.toString();
          }).toList();
          _isLoading = false;
        });
      }
    } catch (e) {
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    final theme = Theme.of(context);
    final primaryColor = theme.primaryColor;

    return PopScope(
      canPop: false,
      onPopInvokedWithResult: (didPop, result) {
        if (didPop) return;
        widget.onBack();
      },
      child: Scaffold(
        backgroundColor: theme.scaffoldBackgroundColor,
        appBar: AppBar(
          backgroundColor: Colors.transparent,
          elevation: 0,
          centerTitle: true,
          leading: IconButton(
            icon: Icon(Icons.arrow_back_ios, color: theme.textTheme.bodyLarge?.color, size: 20),
            onPressed: () {
              widget.onBack();
            },
          ),
          title: Text(
            _formatTitle(widget.categoryName),
            style: TextStyle(
              color: theme.textTheme.bodyLarge?.color,
              fontWeight: FontWeight.bold,
              fontSize: 20,
            ),
          ),
        ),
        body: Directionality(
          textDirection: TextDirection.rtl,
          child: _isLoading
              ? Center(child: CircularProgressIndicator(color: primaryColor))
              : _courses.isEmpty
              ? const Center(child: Text("لا توجد كورسات متاحة حالياً"))
              : ListView.builder(
            padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 10),
            itemCount: _courses.length,
            itemBuilder: (context, index) {
              return _buildHorizontalCourseCard(_courses[index], primaryColor);
            },
          ),
        ),
      ),
    );
  }

  Widget _buildHorizontalCourseCard(dynamic course, Color primaryColor) {
    String? rawImagePath = course['imageUrl'] ?? course['imagePath'];
    String fullImageUrl = "";
    if (rawImagePath != null && rawImagePath.isNotEmpty) {
      fullImageUrl = rawImagePath.startsWith('http') ? rawImagePath : "$baseUrl$rawImagePath";
    }

    return Container(
      height: 100,
      margin: const EdgeInsets.only(bottom: 14),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(18),
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(0.04),
            blurRadius: 10,
            offset: const Offset(0, 4),
          ),
        ],
      ),
      child: InkWell(
        borderRadius: BorderRadius.circular(18),
        onTap: () {
          Navigator.push(
            context,
            MaterialPageRoute(
              builder: (context) => LessonsScreen(
                courseId: course['id'].toString(),
                courseName: course['name'] ?? '',
                onBack: () => Navigator.pop(context),
              ),
            ),
          );
        },
        child: Row(
          children: [
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 16),
              child: Icon(Icons.arrow_back_ios, size: 14, color: Colors.grey),
            ),
            const Spacer(),
            Padding(
              padding: const EdgeInsets.symmetric(vertical: 16),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Text(
                    course['name'] ?? '',
                    maxLines: 1,
                    overflow: TextOverflow.ellipsis,
                    style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 17),
                  ),
                  const SizedBox(height: 6),
                  Text(
                    "بدء الدرس الآن",
                    style: TextStyle(color: Colors.grey[600], fontSize: 13),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.all(10.0),
              child: ClipRRect(
                borderRadius: BorderRadius.circular(14),
                child: Container(
                  width: 100,
                  height: 90,
                  color: primaryColor.withOpacity(0.05),
                  child: fullImageUrl.isNotEmpty
                      ? Image.network(
                    fullImageUrl,
                    fit: BoxFit.cover,
                    errorBuilder: (context, error, stackTrace) =>
                        Icon(Icons.image, color: primaryColor.withOpacity(0.3)),
                  )
                      : Icon(Icons.image, color: primaryColor.withOpacity(0.3)),
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}