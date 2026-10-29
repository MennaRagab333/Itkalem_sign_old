// import 'dart:convert';
// import 'dart:async';
// import 'package:flutter/material.dart';
// import 'package:http/http.dart' as http;
// import 'package:itkalem_sign/features/learning/levels/beginners/BeginnerLevelScreen.dart';
//
// class LearningScreen extends StatefulWidget {
//   const LearningScreen({super.key});
//
//   @override
//   State<LearningScreen> createState() => _LearningScreenState();
// }
//
// class _LearningScreenState extends State<LearningScreen> {
//   Widget? _activeSubPage;
//   bool _isLoading = true;
//   List<dynamic> _levels = [];
//   final String baseUrl = "https://itkalemsign.runasp.net";
//   final Color primaryBlue = const Color(0xFF4A90E2);
//
//   @override
//   void initState() {
//     super.initState();
//     _fetchLevels();
//   }
//
//   Future<void> _fetchLevels() async {
//     try {
//       final response = await http.get(Uri.parse('$baseUrl/api/Levels')).timeout(const Duration(seconds: 10));
//       if (response.statusCode == 200) {
//         final Map<String, dynamic> responseData = jsonDecode(response.body);
//         setState(() {
//           _levels = responseData['data'] ?? [];
//           _isLoading = false;
//         });
//       }
//     } catch (e) {
//       setState(() => _isLoading = false);
//     }
//   }
//
//   void _closeSubPage() {
//     setState(() => _activeSubPage = null);
//   }
//
//   String? _formatImageUrl(String? path) {
//     if (path == null || path.isEmpty) return null;
//     if (path.startsWith('http')) return path;
//     String cleanPath = path.startsWith('/') ? path : '/$path';
//     return "$baseUrl$cleanPath";
//   }
//
//   @override
//   Widget build(BuildContext context) {
//     if (_activeSubPage != null) {
//       return PopScope(
//         canPop: false,
//         onPopInvokedWithResult: (didPop, result) {
//           if (!didPop) _closeSubPage();
//         },
//         child: _activeSubPage!,
//       );
//     }
//
//     return Scaffold(
//       backgroundColor: Theme.of(context).scaffoldBackgroundColor,
//       appBar: AppBar(
//         automaticallyImplyLeading: false,
//         backgroundColor: Colors.transparent,
//         elevation: 0,
//         centerTitle: true,
//         title: Text(
//           'مستويات التعلم',
//           style: TextStyle(
//             color: Theme.of(context).textTheme.bodyLarge?.color,
//             fontWeight: FontWeight.bold,
//             fontSize: 22,
//           ),
//         ),
//       ),
//       body: _isLoading
//           ? Center(child: CircularProgressIndicator(color: primaryBlue))
//           : ListView.builder(
//         padding: const EdgeInsets.fromLTRB(16, 10, 16, 110),
//         itemCount: _levels.length,
//         itemBuilder: (context, index) {
//           final data = _levels[index];
//           return Padding(
//             padding: const EdgeInsets.symmetric(vertical: 8),
//             child: _buildLevelCard(
//               context,
//               title: data['name'] ?? "مستوى غير مسمى",
//               subtitle: data['description'] ?? "تعلم إشارات هذا القسم",
//               imageUrl: _formatImageUrl(data['imageUrl']),
//               onTap: () {
//                 setState(() {
//                   _activeSubPage = BeginnerScreen(
//                     levelId: data['id'],
//                     onBack: _closeSubPage,
//                   );
//                 });
//               },
//             ),
//           );
//         },
//       ),
//     );
//   }
//
//   Widget _buildLevelCard(BuildContext context,
//       {required String title,
//         required String subtitle,
//         String? imageUrl,
//         required VoidCallback onTap}) {
//     return Container(
//       height: 115,
//       decoration: BoxDecoration(
//         color: Theme.of(context).cardColor,
//         borderRadius: BorderRadius.circular(20),
//         border: Border.all(color: Colors.white.withOpacity(0.05), width: 1),
//       ),
//       child: InkWell(
//         onTap: onTap,
//         borderRadius: BorderRadius.circular(20),
//         child: Padding(
//           padding: const EdgeInsets.symmetric(horizontal: 20.0),
//           child: Row(
//             children: [
//               Container(
//                 height: 60,
//                 width: 60,
//                 decoration: BoxDecoration(
//                   color: primaryBlue.withOpacity(0.1),
//                   borderRadius: BorderRadius.circular(15),
//                 ),
//                 child: ClipRRect(
//                   borderRadius: BorderRadius.circular(15),
//                   child: (imageUrl != null)
//                       ? Image.network(
//                     imageUrl,
//                     fit: BoxFit.cover,
//                     errorBuilder: (context, error, stackTrace) =>
//                         Icon(Icons.school_rounded, color: primaryBlue, size: 30),
//                   )
//                       : Icon(Icons.school_rounded, color: primaryBlue, size: 30),
//                 ),
//               ),
//               const SizedBox(width: 16),
//               Expanded(
//                 child: Column(
//                   mainAxisAlignment: MainAxisAlignment.center,
//                   crossAxisAlignment: CrossAxisAlignment.start,
//                   children: [
//                     Text("المستوى",
//                         style: TextStyle(
//                             color: primaryBlue,
//                             fontSize: 12,
//                             fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 2),
//                     Text(title,
//                         style: TextStyle(
//                             color: Theme.of(context).textTheme.bodyLarge?.color,
//                             fontSize: 17,
//                             fontWeight: FontWeight.bold)),
//                     const SizedBox(height: 2),
//                     Text(subtitle,
//                         maxLines: 1,
//                         overflow: TextOverflow.ellipsis,
//                         style: TextStyle(
//                             color: Theme.of(context)
//                                 .textTheme
//                                 .bodyMedium
//                                 ?.color
//                                 ?.withOpacity(0.6),
//                             fontSize: 12)),
//                   ],
//                 ),
//               ),
//               Icon(Icons.arrow_forward_ios_rounded,
//                   color: primaryBlue.withOpacity(0.3), size: 16),
//             ],
//           ),
//         ),
//       ),
//     );
//   }
// }