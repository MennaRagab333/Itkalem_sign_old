import 'package:flutter/material.dart';

class HomeScreen extends StatelessWidget {
  final String userName;
  final Function(int) onFeatureTap;

  const HomeScreen({
    super.key,
    required this.userName,
    required this.onFeatureTap,
  });

  @override
  Widget build(BuildContext context) {
    String firstName = userName.split(' ').first;

    return Scaffold(
      backgroundColor: Theme.of(context).scaffoldBackgroundColor,
      body: SafeArea(
        child: Directionality(
          textDirection: TextDirection.rtl,
          child: SingleChildScrollView(
            child: Padding(
              // الحفاظ على البادينج الخارجي للصفحة كما هو
              padding: const EdgeInsets.fromLTRB(25, 20, 25, 0),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.stretch,
                children: [
                  _buildHeader(context, firstName),
                  const SizedBox(height: 30),
                  Text(
                    'مرحباً بك!',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyLarge?.color,
                      fontSize: 28,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                  const SizedBox(height: 5),
                  Text(
                    'لنكتشف كيفية استخدام مميزات التطبيق.',
                    style: TextStyle(
                      color: Theme.of(context).textTheme.bodyMedium?.color,
                      fontSize: 15,
                    ),
                  ),
                  const SizedBox(height: 25),
                  _buildFeatureCard(
                    context,
                    'الترجمة الذكية',
                    'ترجمة الإشارات إلى نص أو صوت باستخدام الكاميرا.',
                    Icons.camera_alt,
                    Colors.blue,
                        () => onFeatureTap(1),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context,
                    'التعلم التفاعلي',
                    'أتقن لغة الإشارة من خلال مستويات ودروس منظمة.',
                    Icons.school,
                    Colors.purple,
                        () => onFeatureTap(2),
                  ),
                  const SizedBox(height: 16),
                  _buildFeatureCard(
                    context,
                    'قاموس الإشارات',
                    'استكشف مكتبة شاملة للإشارات ومعانيها.',
                    Icons.menu_book,
                    Colors.green,
                        () => onFeatureTap(3),
                  ),
                  // مساحة فارغة في آخر الصفحة للتمرير المريح
                  const SizedBox(height: 30),
                ],
              ),
            ),
          ),
        ),
      ),
    );
  }

  Widget _buildHeader(BuildContext context, String name) {
    return Container(
      padding: const EdgeInsets.all(15),
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        children: [
          Container(
            padding: const EdgeInsets.all(10),
            decoration: const BoxDecoration(
              color: Color(0xFF4A90E2),
              shape: BoxShape.circle,
            ),
            child: const Icon(Icons.front_hand, color: Colors.white),
          ),
          const SizedBox(width: 15),
          Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(
                'ITKALEM SIGN',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyMedium?.color?.withOpacity(0.6),
                  fontSize: 12,
                ),
              ),
              Text(
                'أهلاً بك يا $name',
                style: TextStyle(
                  color: Theme.of(context).textTheme.bodyLarge?.color,
                  fontSize: 18,
                  fontWeight: FontWeight.bold,
                ),
              ),
            ],
          ),
        ],
      ),
    );
  }

  Widget _buildFeatureCard(BuildContext context, String title, String desc,
      IconData icon, Color color, VoidCallback onTap) {
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).cardColor,
        borderRadius: BorderRadius.circular(25),
      ),
      child: Material(
        color: Colors.transparent,
        child: InkWell(
          borderRadius: BorderRadius.circular(25),
          onTap: onTap,
          child: Padding(
            // تم التعديل هنا: زيادة البادينج السفلي جوه الكارت
            padding: const EdgeInsets.fromLTRB(20, 20, 20, 28), // 28 بدلاً من 20
            child: Row(
              crossAxisAlignment: CrossAxisAlignment.center,
              children: [
                Container(
                  padding: const EdgeInsets.all(12),
                  decoration: BoxDecoration(
                    color: color.withOpacity(0.15),
                    borderRadius: BorderRadius.circular(15),
                  ),
                  child: Icon(icon, color: color, size: 28),
                ),
                const SizedBox(width: 15),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        title,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyLarge?.color,
                          fontSize: 18,
                          fontWeight: FontWeight.bold,
                        ),
                      ),
                      const SizedBox(height: 5),
                      Text(
                        desc,
                        style: TextStyle(
                          color: Theme.of(context).textTheme.bodyMedium?.color,
                          fontSize: 13,
                          height: 1.3,
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
          ),
        ),
      ),
    );
  }
}