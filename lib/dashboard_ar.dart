import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'create_invoice_ar.dart';
import 'invoice_search_ar.dart';
import 'view_invoices_page.dart';
import 'about_ar.dart';

class ArabicDashboardPage extends StatelessWidget {
  const ArabicDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('لوحة التحكم'),
        automaticallyImplyLeading: false,
        centerTitle: true,
      ),
      body: Padding(
        padding: const EdgeInsets.all(20.0),
        child: GridView.count(
          crossAxisCount: 2,
          mainAxisSpacing: 20,
          crossAxisSpacing: 20,
          children: [
            _buildButton(context, 'إنشاء فاتورة', Icons.receipt_long, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateInvoicePageAr()),
              );
            }),
            _buildButton(context, 'بحث عن الفواتير', Icons.search, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvoiceSearchPageAr(),
                ),
              );
            }),
            _buildButton(context, 'عرض كل الفواتير', Icons.analytics, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewInvoicesPage(),
                ),
              );
            }),
            _buildButton(context, 'رفع ترويسة JPG', Icons.upload, () async {
              final picker = ImagePicker();
              final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);

              if (pickedFile != null) {
                final appDir = await getApplicationDocumentsDirectory();
                final savedImage = File('${appDir.path}/header.jpg');
                await File(pickedFile.path).copy(savedImage.path);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('تم رفع الترويسة بنجاح')),
                );
              }
            }),
            _buildButton(context, 'عرض الترويسة الحالية', Icons.image,
                () async {
              final appDir = await getApplicationDocumentsDirectory();
              final headerFile = File('${appDir.path}/header.jpg');

              if (await headerFile.exists()) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('الترويسة الحالية'),
                    content: Image.file(headerFile),
                    actions: [
                      TextButton(
                        child: const Text('إغلاق'),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('لا توجد ترويسة حالية')),
                );
              }
            }),
            _buildButton(context, 'عن التطبيق', Icons.settings, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutPageAr(),
                ),
              );
            }),
            _buildButton(context, 'عودة إلى اختيار اللغة', Icons.logout, () {
              Navigator.pop(context); // العودة لاختيار اللغة
            }),
          ],
        ),
      ),
    );
  }

  Widget _buildButton(BuildContext context, String title, IconData icon,
      VoidCallback onPressed) {
    return ElevatedButton(
      onPressed: onPressed,
      style: ElevatedButton.styleFrom(padding: const EdgeInsets.all(12)),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Icon(icon, size: 40),
          const SizedBox(height: 10),
          Text(title,
              textAlign: TextAlign.center,
              style: const TextStyle(fontSize: 16)),
        ],
      ),
    );
  }
}
