import 'package:flutter/material.dart';

class NumbersScreen extends StatelessWidget {
  final VoidCallback onBack;

  const NumbersScreen({super.key, required this.onBack});

  @override
  Widget build(BuildContext context) {
    final List<String> arabicNumbers = ['١', '٢', '٣', '٤', '٥', '٦', '٧', '٨', '٩', '١٠'];

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        elevation: 0,
        centerTitle: true,
        leading: IconButton(
          icon: Icon(Icons.arrow_back_ios,
              color: Theme.of(context).textTheme.bodyLarge?.color,
              size: 20),
          onPressed: () => Navigator.pop(context),
        ),
        title: Text(
            'الأرقام',
            style: TextStyle(
                color: Theme.of(context).textTheme.bodyLarge?.color,
                fontWeight: FontWeight.bold
            )
        ),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl,
        child: ListView.builder(
          padding: const EdgeInsets.all(16),
          itemCount: arabicNumbers.length + 1,
          itemBuilder: (context, index) {
            if (index == arabicNumbers.length) return const SizedBox(height: 120);
            return _buildLessonCard(context, index + 1, arabicNumbers[index]);
          },
        ),
      ),
    );
  }

  Widget _buildLessonCard(BuildContext context, int lessonNum, String number) {
    bool isLocked = lessonNum > 3;
    bool isCompleted = lessonNum <= 2;
    Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    return Container(
      margin: const EdgeInsets.only(bottom: 16),
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
        border: Border.all(color: Colors.white.withOpacity(0.05)),
      ),
      child: Row(
        children: [
          Container(
            height: 75,
            width: 75,
            decoration: BoxDecoration(
              color: isCompleted
                  ? const Color(0xFF1B8D81).withOpacity(0.2)
                  : textColor.withOpacity(0.05),
              borderRadius: BorderRadius.circular(15),
              border: Border.all(
                  color: isCompleted ? const Color(0xFF1B8D81) : Colors.transparent,
                  width: 2
              ),
            ),
            child: Center(
                child: Text(
                    number,
                    style: TextStyle(
                        fontSize: 32,
                        fontWeight: FontWeight.bold,
                        color: isLocked ? textColor.withOpacity(0.24) : textColor
                    )
                )
            ),
          ),
          const SizedBox(width: 16),
          Expanded(
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                const Text(
                    "الدرس",
                    style: TextStyle(
                        color: Color(0xFF4A90E2),
                        fontSize: 12,
                        fontWeight: FontWeight.bold
                    )
                ),
                const SizedBox(height: 4),
                Text(
                    "تعلم رقم ($number)",
                    style: TextStyle(
                        color: textColor,
                        fontSize: 18,
                        fontWeight: FontWeight.bold
                    )
                ),
              ],
            ),
          ),
          _buildStatusIcon(context, isLocked, isCompleted),
        ],
      ),
    );
  }

  Widget _buildStatusIcon(BuildContext context, bool isLocked, bool isCompleted) {
    Color textColor = Theme.of(context).textTheme.bodyLarge?.color ?? Colors.white;

    if (isLocked) return Icon(Icons.lock_outline_rounded, color: textColor.withOpacity(0.24), size: 24);
    if (isCompleted) return const CircleAvatar(radius: 12, backgroundColor: Color(0xFF1B8D81), child: Icon(Icons.check, color: Colors.white, size: 16));
    return const Icon(Icons.play_circle_fill_rounded, color: Color(0xFF4A90E2), size: 30);
  }
}