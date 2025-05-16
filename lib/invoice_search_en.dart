import 'package:flutter/material.dart';
import 'dart:io'; // For dart:io library
import 'package:open_file/open_file.dart'; // For open_file library
import 'db_helper.dart';
import 'package:path_provider/path_provider.dart'; // For path_provider library

class InvoiceSearchPageEn extends StatefulWidget {
  @override
  _InvoiceSearchPageEnState createState() => _InvoiceSearchPageEnState();
}

class _InvoiceSearchPageEnState extends State<InvoiceSearchPageEn> {
  final TextEditingController customerNameController = TextEditingController();
  final TextEditingController invoiceNumberController = TextEditingController();
  String selectedInvoiceType = 'All';
  List<Map<String, dynamic>> searchResults = [];

  final List<String> invoiceTypes = [
    'All',
    'Quotation',
    'Cash',
    'Credit',
    'Return'
  ];

  @override
  void initState() {
    super.initState();
    _fetchEnglishInvoices();
  }

  Future<void> _fetchEnglishInvoices() async {
    try {
      final results = await DBHelper.fetchEnglishInvoices();
      setState(() {
        searchResults = results;
      });
    } catch (e) {
      print('Error fetching invoices: $e');
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

      // Determine the full file path
      final Directory appDir = await getApplicationDocumentsDirectory();
      final filePath = '${appDir.path}/invoice_$invoiceNumber.pdf';

      // Check if the file exists
      final file = File(filePath);
      if (await file.exists()) {
        // Open the file using open_file library
        await OpenFile.open(filePath);
      } else {
        // Show a message if the file does not exist
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('File not found')),
        );
      }
    } catch (e) {
      print('Error opening PDF: $e');
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error opening file: $e')),
      );
    }
  }

  Future<void> deleteInvoice(int invoiceId) async {
    try {
      await DBHelper.deleteInvoice(invoiceId);
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice deleted successfully')),
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
        title: const Text('Invoice Search'),
      ),
      body: Directionality(
        textDirection: TextDirection.ltr, // Set text direction to left-to-right
        child: Padding(
          padding: const EdgeInsets.all(16.0),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              // Search fields
              TextField(
                controller: customerNameController,
                decoration: const InputDecoration(
                  labelText: 'Customer Name',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 10),
              TextField(
                controller: invoiceNumberController,
                decoration: const InputDecoration(
                  labelText: 'Invoice Number',
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
                  labelText: 'Invoice Type',
                  border: OutlineInputBorder(),
                ),
              ),
              const SizedBox(height: 20),
              // Search and clear buttons
              Row(
                children: [
                  ElevatedButton(
                    onPressed: searchInvoices,
                    child: const Text('Search'),
                  ),
                  const SizedBox(width: 10),
                  ElevatedButton(
                    onPressed: clearResults,
                    child: const Text('Clear Results'),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              // Display results
              Expanded(
                child: searchResults.isEmpty
                    ? const Center(child: Text('No results found'))
                    : ListView.builder(
                        itemCount: searchResults.length,
                        itemBuilder: (context, index) {
                          final invoice = searchResults[index];
                          return Card(
                            child: ListTile(
                              title: Column(
                                crossAxisAlignment: CrossAxisAlignment.start,
                                children: [
                                  // Display invoice number in green
                                  Text(
                                    '${invoice['number']}',
                                    style: const TextStyle(
                                      color: Colors.green,
                                      fontWeight: FontWeight.bold,
                                      fontSize: 16,
                                    ),
                                  ),
                                  // Display invoice type
                                  Text(
                                    '${invoice['type']}', // Invoice type
                                    style: const TextStyle(
                                      fontSize: 14,
                                      color: Colors.black,
                                    ),
                                  ),
                                ],
                              ),
                              subtitle: Text(
                                // Display customer name, date, and total with currency
                                'Customer: ${invoice['customer']} \nDate: ${invoice['date']} - Total: ${invoice['total']} ${invoice['currency']}',
                                style: const TextStyle(fontSize: 14),
                              ),
                              trailing: PopupMenuButton<String>(
                                onSelected: (value) {
                                  if (value == 'View') {
                                    openInvoicePdf(invoice['number']);
                                  } else if (value == 'Delete') {
                                    deleteInvoice(invoice['id']);
                                  }
                                },
                                itemBuilder: (context) => [
                                  const PopupMenuItem(
                                    value: 'View',
                                    child: Text('View Invoice'),
                                  ),
                                  const PopupMenuItem(
                                    value: 'Delete',
                                    child: Text('Delete Invoice'),
                                  ),
                                ],
                              ),
                            ),
                          );
                        },
                      ),
              ),
              // Close button
              Align(
                alignment: Alignment.center,
                child: ElevatedButton(
                  onPressed: () => Navigator.pop(context),
                  child: const Text('Close'),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
