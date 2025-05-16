import 'package:flutter/material.dart';
import 'dashboard_ar.dart';
import 'dashboard_en.dart';

class LanguageSelectionPage extends StatelessWidget {
  const LanguageSelectionPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Colors.white,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          // الشعار في المنتصف
          Padding(
            padding: const EdgeInsets.only(top: 60.0),
            child: Center(
              child: Column(
                children: [
                  Image.asset(
                    'assets/images/logo.png', // ضع مسار الشعار هنا
                    height: 55, // أصغر من السابق
                  ),
                  const SizedBox(height: 30),
                  const Text(
                    'اختر اللغة / Choose Language',
                    style: TextStyle(fontSize: 20, fontWeight: FontWeight.bold),
                  ),
                ],
              ),
            ),
          ),
          // أزرار اختيار اللغة
          Padding(
            padding: const EdgeInsets.all(24.0),
            child: Column(
              children: [
                ElevatedButton.icon(
                  icon: const Icon(Icons.language),
                  label: const Text('العربية', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const ArabicDashboardPage()),
                    );
                  },
                ),
                const SizedBox(height: 20),
                ElevatedButton.icon(
                  icon: const Icon(Icons.language),
                  label: const Text('English', style: TextStyle(fontSize: 18)),
                  style: ElevatedButton.styleFrom(
                    minimumSize: const Size(double.infinity, 50),
                  ),
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (context) => const EnglishDashboardPage()),
                    );
                  },
                ),
              ],
            ),
          ),
          // الفوتر في الأسفل
          Padding(
            padding: const EdgeInsets.only(bottom: 20.0),
            child: const Text(
              'برمجة وتطوير صخر نت تكنولوجي 2025',
              style: TextStyle(fontSize: 14, fontWeight: FontWeight.w500),
            ),
          ),
        ],
      ),
    );
  }
}
