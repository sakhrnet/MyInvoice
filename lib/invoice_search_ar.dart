import 'package:flutter/material.dart';
import 'dart:io'; // لاستيراد مكتبة dart:io
import 'package:open_file/open_file.dart'; // لاستيراد مكتبة open_file
import 'db_helper.dart';
import 'package:path_provider/path_provider.dart'; // لاستيراد مكتبة path_provider

class InvoiceSearchPageAr extends StatefulWidget {
  @override
  _InvoiceSearchPageArState createState() => _InvoiceSearchPageArState();
}

class _InvoiceSearchPageArState extends State<InvoiceSearchPageAr> {
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController invoiceNumberController = TextEditingController();
  String selectedInvoiceType = 'الكل';
  List<Map<String, dynamic>> searchResults = [];

  final List<String> invoiceTypes = [
    'الكل',
    'عرض سعر',
    'نقدية',
    'أجلة',
    'مرتجع'
  ];

  @override
  void initState() {
    super.initState();
    _fetchArabicInvoices();
  }

  Future<void> _fetchArabicInvoices() async {
    try {
      final results =
          await DBHelper.fetchArabicInvoices(); // استدعاء الطريقة كـ static
      print('Fetched Arabic Invoices: $results'); // طباعة النتائج للتحقق
      setState(() {
        searchResults = results;
      });
    } catch (e) {
      print('Error fetching invoices: $e'); // طباعة الخطأ إذا حدث
    }
  }

  void searchInvoices() async {
    try {
      final results = await DBHelper.searchInvoices(
        customerName: customerNameController.text,
        invoiceNumber: invoiceNumberController.text,
        invoiceType: selectedInvoiceType,
      );

      setState(() {
        searchResults = results;
      });
    } catch (e) {
      print('Error searching invoices: $e');
    }
  }

  void clearResults() {
    setState(() {
      searchResults.clear();
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

  Future<void> deleteInvoice(int invoiceId) async {
    try {
      await DBHelper.deleteInvoice(invoiceId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('تم حذف الفاتورة بنجاح')),
      );
      searchInvoices();
    } catch (e) {
      print('Error deleting invoice: $e');
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('بحث عن الفواتير'),
      ),
      body: Directionality(
        textDirection: TextDirection.rtl, // جعل الاتجاه يمينًا
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // حقول البحث
              TextField(
                controller: customerNameController,
                decoration: const InputDecoration(
                  labelText: 'اسم العميل',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: invoiceNumberController,
                decoration: const InputDecoration(
                  labelText: 'رقم الفاتورة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                value: selectedInvoiceType,
                items: invoiceTypes
                    .map((type) => DropdownMenuItem(
                          value: type,
                          child: Text(type),
                        ))
                    .toList(),
                onChanged: (value) {
                  setState(() {
                    selectedInvoiceType = value!;
                  });
                },
                decoration: const InputDecoration(
                  labelText: 'نوع الفاتورة',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // أزرار البحث ومسح النتائج
              Row(
                children: [
                  ElevatedButton(
                    onPressed: searchInvoices,
                    child: const Text('بحث'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: clearResults,
                    child: const Text('مسح النتائج'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // عرض النتائج
              Expanded(
                child: searchResults.isEmpty
                    ? const Center(child: Text('لا توجد نتائج'))
                    : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final invoice = searchResults[index];
                          return Card(
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  Text(
                                    'رقم الفاتورة: ${invoice['number']}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  Text(
                                    'نوع الفاتورة: ${invoice['type']}',
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                'العميل: ${invoice['customer']} \nالتاريخ: ${invoice['date']} - الإجمالي: ${invoice['total']} ${invoice['currency']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'عرض') {
                                    openInvoicePdf(invoice['number']);
                                  } else if (value == 'حذف') {
                                    deleteInvoice(invoice['id']);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'عرض',
                                    child: Text('عرض الفاتورة'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'حذف',
                                    child: Text('حذف الفاتورة'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // زر الإغلاق
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('إغلاق'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
