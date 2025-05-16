import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';
import 'create_invoice_en.dart';
import 'invoice_search_en.dart';
import 'view_invoices_page_en.dart';
import 'about_en.dart'; // استيراد صفحة البحث

class EnglishDashboardPage extends StatelessWidget {
  const EnglishDashboardPage({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Dashboard'),
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
            _buildButton(context, 'Create Invoice', Icons.receipt_long, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                    builder: (context) => const CreateInvoicePageEn()),
              );
            }),
            _buildButton(context, 'Search Invoices', Icons.search, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => InvoiceSearchPageEn(),
                ),
              );
            }),
            _buildButton(context, 'View all invoices', Icons.analytics, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ViewInvoicesPageEn(),
                ),
              );
            }),
            _buildButton(context, 'Upload JPG header', Icons.upload, () async {
              final picker = ImagePicker();
              final pickedFile =
                  await picker.pickImage(source: ImageSource.gallery);

              if (pickedFile != null) {
                final appDir = await getApplicationDocumentsDirectory();
                final savedImage = File('${appDir.path}/header.jpg');
                await File(pickedFile.path).copy(savedImage.path);

                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('Header uploaded successfully')),
                );
              }
            }),
            _buildButton(context, 'Show current header', Icons.image, () async {
              final appDir = await getApplicationDocumentsDirectory();
              final headerFile = File('${appDir.path}/header.jpg');

              if (await headerFile.exists()) {
                showDialog(
                  context: context,
                  builder: (_) => AlertDialog(
                    title: const Text('Current header'),
                    content: Image.file(headerFile),
                    actions: [
                      TextButton(
                        child: const Text('Close'),
                        onPressed: () => Navigator.of(context).pop(),
                      )
                    ],
                  ),
                );
              } else {
                ScaffoldMessenger.of(context).showSnackBar(
                  const SnackBar(content: Text('No current header')),
                );
              }
            }),
            _buildButton(context, 'About us', Icons.settings, () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const AboutPageEn(),
                ),
              );
            }),
            _buildButton(context, 'Back to Language Selection', Icons.logout,
                () {
              Navigator.pop(context); // Back to language selection
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
