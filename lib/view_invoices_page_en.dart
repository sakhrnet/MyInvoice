import 'package:flutter/material.dart';
import 'db_helper.dart';
import 'edit_invoice_en.dart';
import 'package:path_provider/path_provider.dart';
import 'dart:io';
import 'package:open_file/open_file.dart';

class ViewInvoicesPageEn extends StatefulWidget {
  const ViewInvoicesPageEn({super.key});

  @override
  State<ViewInvoicesPageEn> createState() => _ViewInvoicesPageEnState();
}

class _ViewInvoicesPageEnState extends State<ViewInvoicesPageEn> {
  late Future<List<Map<String, dynamic>>> _invoicesFuture;

  @override
  void initState() {
    super.initState();
    _invoicesFuture = fetchEnglishInvoicesForView();
  }

  Future<List<Map<String, dynamic>>> fetchEnglishInvoicesForView() async {
    final db = await DBHelper.database;
    return await db.query(
      'invoices',
      where: 'type IN (?, ?, ?, ?)',
      whereArgs: [
        'Quotation',
        'Cash Invoice',
        'Credit Invoice',
        'Return Invoice'
      ],
      orderBy: 'id DESC',
    );
  }

  Future<void> _deleteInvoice(int id) async {
    final db = await DBHelper.database;
    await db.delete('invoices', where: 'id = ?', whereArgs: [id]);
    setState(() {
      _invoicesFuture = fetchEnglishInvoicesForView();
    });
  }

  Future<void> openInvoicePdf(String invoiceNumber) async {
    try {
      final Directory appDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDir.path}/invoice_$invoiceNumber.pdf';
      final file = File(filePath);
      if (await file.exists()) {
        await OpenFile.open(filePath);
      } else {
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('PDF file not found')),
        );
      }
    } catch (e) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening PDF: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: const Text('Invoice List')),
        body: FutureBuilder<List<Map<String, dynamic>>>(
          future: _invoicesFuture,
          builder: (context, snapshot) {
            if (snapshot.connectionState == ConnectionState.waiting) {
              return const Center(child: CircularProgressIndicator());
            } else if (snapshot.hasError) {
              return const Center(
                  child: Text('An error occurred while loading invoices'));
            } else if (!snapshot.hasData || snapshot.data!.isEmpty) {
              return const Center(child: Text('No invoices saved'));
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
                                    fontSize: 14,
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
                                  tooltip: 'View PDF',
                                  onPressed: () {
                                    openInvoicePdf(
                                        invoice['number'].toString());
                                  },
                                ),
                                IconButton(
                                  icon: const Icon(Icons.delete,
                                      color: Colors.red),
                                  tooltip: 'Delete Invoice',
                                  onPressed: () async {
                                    final confirm = await showDialog<bool>(
                                      context: context,
                                      builder: (context) => AlertDialog(
                                        title: const Text('Confirm Delete'),
                                        content: const Text(
                                            'Are you sure you want to delete this invoice?'),
                                        actions: [
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, false),
                                            child: const Text('Cancel'),
                                          ),
                                          TextButton(
                                            onPressed: () =>
                                                Navigator.pop(context, true),
                                            child: const Text('Delete',
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
                                  tooltip: 'Edit',
                                  onPressed: () {
                                    Navigator.push(
                                      context,
                                      MaterialPageRoute(
                                        builder: (context) => EditInvoicePageEn(
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
                                    color: Colors.green),
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
