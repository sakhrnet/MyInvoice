import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'edit_invoice_ar.dart';
import 'package:path_provider/path_provider.dart'; // لاستيراد مكتبة path_provider
import 'dart:io'; // لاستيراد مكتبة dart:io
import 'package:open_file/open_file.dart'; // لاستيراد مكتبة open_file

class ViewInvoicesPage extends StatefulWidget {
  const ViewInvoicesPage({super.key});

  @override
  State<ViewInvoicesPage> createState() => _ViewInvoicesPageState();
}

class _ViewInvoicesPageState extends State<ViewInvoicesPage> {
  late Future<List<Map<String, dynamic>>> _invoicesFuture;

  @override
  void initState() {
    super.initState();
    _invoicesFuture = fetchArabicInvoicesForView();
  }

  Future<List<Map<String, dynamic>>> fetchArabicInvoicesForView() async {
    final db = await DBHelper.database;
    final results = await db.query(
      'invoices',
      where: 'type IN (?, ?, ?, ?)',
      whereArgs: ['عرض سعر', 'فاتورة نقدية', 'فاتورة آجلة', 'فاتورة مرتجع'],
      orderBy: 'id DESC',
    );
    return results;
  }

  Future<void> _deleteInvoice(int id) async {
    final db = await DBHelper.database;
    await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
    setState(() {
      _invoicesFuture = fetchArabicInvoicesForView();
    });
  }

  Future<void> openInvoicePdf(String invoiceNumber) async {
    try {
      print('Trying to open invoice: $invoiceNumber');

      // طلب صلاحيات التخزين

      // تحديد المسار الكامل للملف
      final Directory appDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDir.path}/invoice_$invoiceNumber.pdf';

      // التحقق مما إذا كان الملف موجودًا
      final file = File(filePath);
      if (await file.exists()) {
        // فتح الملف باستخدام مكتبة open_file
        await OpenFile.open(filePath);
      } else {
        // عرض رسالة إذا كان الملف غير موجود
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('الملف غير موجود')),
        );
      }
    } catch (e) {
      print('Error opening PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('حدث خطأ أثناء فتح الملف: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('قائمة الفواتير')),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _invoicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(child: Text('حدث خطأ أثناء تحميل الفواتير'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('لا توجد فواتير محفوظة'));
            }

            final invoices = snapshot.data!;
            return ListView.builder(
              itemCount: invoices.length,
              itemBuilder: (context, index) {
                final invoice = invoices[index];
                return Card(
                  elevation: 3,
                  margin:
                      const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Padding(
                    padding: const EdgeInsets.symmetric(
                        vertical: 12, horizontal: 16),
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Row(
                          children: [
                            CircleAvatar(
                              radius: 30,
                              backgroundColor: Colors.blue.shade100,
                              child: Padding(
                                padding:
                                    const EdgeInsets.symmetric(horizontal: 6),
                                child: Text(
                                  invoice['number'].toString(),
                                  style: const TextStyle(
                                    color: Colors.blue,
                                    fontWeight: FontWeight.bold,
                                    fontSize: 16,
                                  ),
                                  textAlign: TextAlign.center,
                                ),
                              ),
                            ),
                            const SizedBox(width: 12),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    invoice['type'] ?? '',
                                    style: const TextStyle(
                                      fontWeight: FontWeight.bold,
                                      fontSize: 15,
                                      color: Colors.black87,
                                    ),
                                  ),
                                  Text(
                                    invoice['date'] ?? '',
                                    style: TextStyle(
                                      color: Colors.grey.shade600,
                                      fontSize: 13,
                                    ),
                                  ),
                                ],
                              ),
                            ),
                            Row(
                              mainAxisSize: MainAxisSize.min,
                              children: [
                                IconButton(
                                  icon: const Icon(Icons.picture_as_pdf,
                                      color: Colors.red),
                                  tooltip: 'عرض PDF',
                                  onPressed: () {
                                    openInvoicePdf(
                                        invoice['number'].toString());
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  tooltip: 'حذف الفاتورة',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('تأكيد الحذف'),
                                        content: const Text(
                                            'هل أنت متأكد أنك تريد حذف هذه الفاتورة؟'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('إلغاء'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('حذف',
                                                style: TextStyle(
                                                    color: Colors.red)),
                                          ),
                                        ],
                                      ),
                                    );
                                    if (confirm == true) {
                                      await _deleteInvoice(invoice['id']);
                                    }
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.edit,
                                      color: Colors.blue),
                                  tooltip: 'تعديل',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditInvoicePageAr(
                                          invoiceData: invoice,
                                        ),
                                      ),
                                    );
                                  },
                                ),
                              ],
                            ),
                          ],
                        ),
                        const Divider(height: 18),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.person,
                                  size: 18, color: Colors.grey),
                              const SizedBox(width: 6),
                              Expanded(
                                child: Text(
                                  invoice['customer'] ?? '',
                                  style: const TextStyle(fontSize: 15),
                                ),
                              ),
                            ],
                          ),
                        ),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 2),
                          child: Row(
                            children: [
                              const Icon(Icons.attach_money,
                                  size: 18, color: Colors.green),
                              const SizedBox(width: 6),
                              Text(
                                '${invoice['total']} ${invoice['currency']}',
                                style: const TextStyle(
                                  fontSize: 15,
                                  fontWeight: FontWeight.bold,
                                  color: Colors.green,
                                ),
                              ),
                            ],
                          ),
                        ),
                      ],
                    ),
                  ),
                );
              },
            );
          },
        ),
      ),
    );
  }
}
