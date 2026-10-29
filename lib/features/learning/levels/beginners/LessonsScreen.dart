import 'dart:convert';
import 'package:flutter/material.dart';
import 'package:http/http.dart' as http;
import 'package:itkalem_sign/features/learning/levels/beginners/VideoPlayerScreen.dart';

class LessonsScreen extends StatefulWidget {
  final VoidCallback onBack;
  final String courseId;
  final String courseName;

  const LessonsScreen({
    super.key,
    required this.onBack,
    required this.courseId,
    required this.courseName
  });

  @override
  State<LessonsScreen> createState() => _LessonsScreenState();
}

class _LessonsScreenState extends State<LessonsScreen> {
  List<dynamic> _lessons = [];
  bool _isLoading = true;
  final String baseUrl = "https://itkalemsign.runasp.net";
  final Color primaryBlue = const Color(0xFF4A90E2);

  @override
  void initState() {
    super.initState();
    _fetchLessons();
  }

  Future<void> _fetchLessons() async {
    final url = Uri.parse('$baseUrl/api/Lessons?courseId=${widget.courseId}');

    print("now in url : $url");

    try {
      final response = await http.get(url);
      print("server:(Status Code): ${response.statusCode}");
      print("data on response ${response.body}");

      if (response.statusCode == 200) {
        final dynamic responseData = jsonDecode(response.body);

        setState(() {
          if (responseData is List) {
            _lessons = responseData;
          } else if (responseData is Map && responseData.containsKey('data')) {
            _lessons = responseData['data'] ?? [];
          }
          _isLoading = false;
        });
      } else {
        setState(() => _isLoading = false);
      }
    } catch (e) {
      print("error: $e");
      setState(() => _isLoading = false);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
            icon: Icon(
                Icons.arrow_back_ios,
                color: Theme.of(context).textTheme.bodyLarge?.color,
                size: 20
            ),
            onPressed: widget.onBack
        ),
        title: Text(
          widget.courseName,
          style: const TextStyle(fontWeight: FontWeight.bold),
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: _isLoading
            ? Center(child: CircularProgressIndicator(color: primaryBlue))
            : _lessons.isEmpty
            ? const Center(child: Text("لا توجد دروس حالياً"))
            : ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: _lessons.length,
          itemBuilder: (context, index) {
            final lesson = _lessons[index];
            return _buildLessonCard(
                context,
                index + 1,
                lesson['name'] ?? '',
                lesson['imageUrl'],
                lesson['videoUrl'] ?? ''
            );
          },
        ),
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, int lessonNum, String title, String? imgPath, String videoUrl) {
    String? fullImgUrl = (imgPath != null && imgPath.isNotEmpty)
        ? (imgPath.startsWith('http') ? imgPath : '$baseUrl$imgPath')
        : null;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
          color: Theme.of(context).cardColor,
          borderRadius: BorderRadius.circular(20),
          border: Border.all(color: Colors.white.withOpacity(0.05))
      ),
      child: Row(
        children: [
          Container(
            height: 70,
            width: 70,
            decoration: BoxDecoration(
                color: primaryBlue.withOpacity(0.1),
                borderRadius: BorderRadius.circular(15)
            ),
            child: ClipRRect(
              borderRadius: BorderRadius.circular(15),
              child: fullImgUrl != null
                  ? Image.network(
                  fullImgUrl,
                  fit: BoxFit.cover,
                  errorBuilder: (c, e, s) => Icon(Icons.videocam, color: primaryBlue)
              )
                  : Icon(Icons.videocam, color: primaryBlue),
            ),
          ),
          const SizedBox(width: 15),
          Expanded(
              child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                        "درس $lessonNum",
                        style: TextStyle(color: primaryBlue, fontSize: 12, fontWeight: FontWeight.bold)
                    ),
                    Text(
                        title,
                        style: const TextStyle(fontSize: 16, fontWeight: FontWeight.bold)
                    )
                  ]
              )
          ),
          IconButton(
            icon: Icon(Icons.play_circle_fill, color: primaryBlue, size: 40),
            onPressed: () {
              if (videoUrl.isNotEmpty) {
                String finalVideoUrl = videoUrl.startsWith('http') ? videoUrl : '$baseUrl$videoUrl';
                Navigator.push(
                    context,
                    MaterialPageRoute(
                        builder: (context) => VideoPlayerScreen(
                            videoUrl: finalVideoUrl,
                            title: title,
                            onBack: () => Navigator.pop(context)
                        )
                    )
                );
              }
            },
          ),
        ],
      ),
    );
  }
}