import 'package:flutter/material.dart';
import 'db_helper.dart';

class EditInvoicePageEn extends StatefulWidget {
  final Map<String, dynamic> invoiceData;

  const EditInvoicePageEn({super.key, required this.invoiceData});

  @override
  State<EditInvoicePageEn> createState() => _EditInvoicePageEnState();
}

class _EditInvoicePageEnState extends State<EditInvoicePageEn> {
  final TextEditingController customerController = TextEditingController();
  final TextEditingController totalController = TextEditingController();
  final TextEditingController notesController = TextEditingController();
  final TextEditingController taxController = TextEditingController();
  final TextEditingController discountController = TextEditingController();

  String invoiceType = 'Quotation';
  String currency = 'USD';
  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    _loadInvoiceData();
  }

  void _loadInvoiceData() {
    final invoice = widget.invoiceData;
    customerController.text = invoice['customer'];
    totalController.text = invoice['total'].toString();
    notesController.text = invoice['notes'];
    taxController.text = invoice['tax'].toString();
    discountController.text = invoice['discount'].toString();
    invoiceType = invoice['type'];
    currency = invoice['currency'];

    DBHelper.getInvoiceItems(invoice['id']).then((items) {
      setState(() {
        products = List<Map<String, dynamic>>.from(items.map((item) {
          return {
            'name': item['name'] ?? '',
            'quantity': item['quantity'] ?? 1,
            'unitPrice': item['unit_price'] ?? 0.0,
            'nameController': TextEditingController(text: item['name'] ?? ''),
            'quantityController':
                TextEditingController(text: (item['quantity'] ?? 1).toString()),
            'unitPriceController': TextEditingController(
                text: (item['unit_price'] ?? 0.0).toString()),
          };
        }));
      });
    });
  }

  void _recalculateTotal() {
    double subtotal = 0.0;

    for (var product in products) {
      final quantity = int.tryParse(product['quantityController'].text) ?? 0;
      final unitPrice =
          double.tryParse(product['unitPriceController'].text) ?? 0.0;
      subtotal += quantity * unitPrice;
    }

    final tax = double.tryParse(taxController.text) ?? 0.0;
    final discount = double.tryParse(discountController.text) ?? 0.0;
    final total = subtotal + (subtotal * (tax / 100)) - discount;

    setState(() {
      totalController.text = total.toStringAsFixed(2);
    });
  }

  void _updateInvoiceEn() async {
    try {
      final updateInvoiceEn = {
        'customer': customerController.text,
        'total': double.tryParse(totalController.text) ?? 0.0,
        'notes': notesController.text,
        'tax': double.tryParse(taxController.text) ?? 0.0,
        'discount': double.tryParse(discountController.text) ?? 0.0,
        'type': invoiceType,
        'currency': currency,
      };

      print(
          'Updating invoice with data: $updateInvoiceEn'); // طباعة بيانات الفاتورة

      await DBHelper.updateInvoiceEn(widget.invoiceData['id'], updateInvoiceEn);

      final updatedProducts = products.map((product) {
        return {
          'name': product['nameController'].text,
          'quantity': int.tryParse(product['quantityController'].text) ?? 1,
          'unitPrice':
              double.tryParse(product['unitPriceController'].text) ?? 0.0,
        };
      }).toList();

      print(
          'Updating products with data: $updatedProducts'); // طباعة بيانات المنتجات

      await DBHelper.deleteInvoiceItems(widget.invoiceData['id']);
      await DBHelper.insertInvoiceItems(
          widget.invoiceData['id'], updatedProducts);

      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('Invoice updated successfully')),
      );

      Navigator.pop(context);
    } catch (e) {
      print('Error updating invoice: $e'); // طباعة الخطأ
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error updating invoice: $e')),
      );
    }
  }

  void _addProduct() {
    setState(() {
      products.add({
        'name': '',
        'quantity': 1,
        'unitPrice': 0.0,
        'nameController': TextEditingController(),
        'quantityController': TextEditingController(text: '1'),
        'unitPriceController': TextEditingController(text: '0.0'),
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Edit Invoice'),
        actions: [
          IconButton(
            icon: const Icon(Icons.save),
            onPressed: _updateInvoiceEn,
          ),
        ],
      ),
      body: SingleChildScrollView(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            TextField(
              controller: customerController,
              decoration: const InputDecoration(labelText: 'Customer Name'),
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Invoice Type'),
              value: invoiceType,
              items: [
                'Quotation',
                'Cash Invoice',
                'Credit Invoice',
                'Return Invoice'
              ]
                  .map((type) => DropdownMenuItem(
                        value: type,
                        child: Text(type),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  invoiceType = value!;
                });
              },
            ),
            const SizedBox(height: 10),
            DropdownButtonFormField<String>(
              decoration: const InputDecoration(labelText: 'Currency'),
              value: currency,
              items: ['USD', 'EUR', 'GBP', 'YER']
                  .map((curr) => DropdownMenuItem(
                        value: curr,
                        child: Text(curr),
                      ))
                  .toList(),
              onChanged: (value) {
                setState(() {
                  currency = value!;
                });
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: totalController,
              decoration: const InputDecoration(labelText: 'Total'),
              keyboardType: TextInputType.number,
              readOnly: true, // إجمالي القراءة فقط
            ),
            const SizedBox(height: 10),
            TextField(
              controller: taxController,
              decoration: const InputDecoration(labelText: 'Tax (%)'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _recalculateTotal();
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: discountController,
              decoration: const InputDecoration(labelText: 'Discount'),
              keyboardType: TextInputType.number,
              onChanged: (value) {
                _recalculateTotal();
              },
            ),
            const SizedBox(height: 10),
            TextField(
              controller: notesController,
              decoration: const InputDecoration(labelText: 'Notes'),
              maxLines: 3,
            ),
            const SizedBox(height: 20),
            const Text(
              'Products',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            ListView.builder(
              shrinkWrap: true,
              physics: const NeverScrollableScrollPhysics(),
              itemCount: products.length,
              itemBuilder: (context, index) {
                final product = products[index];
                return Card(
                  margin: const EdgeInsets.symmetric(vertical: 8.0),
                  child: ListTile(
                    title: TextField(
                      decoration:
                          const InputDecoration(labelText: 'Product Name'),
                      controller: product['nameController'],
                    ),
                    subtitle: Row(
                      children: [
                        Expanded(
                          child: TextField(
                            decoration:
                                const InputDecoration(labelText: 'Quantity'),
                            keyboardType: TextInputType.number,
                            controller: product['quantityController'],
                            onChanged: (value) {
                              _recalculateTotal();
                            },
                          ),
                        ),
                        const SizedBox(width: 10),
                        Expanded(
                          child: TextField(
                            decoration:
                                const InputDecoration(labelText: 'Unit Price'),
                            keyboardType: TextInputType.number,
                            controller: product['unitPriceController'],
                            onChanged: (value) {
                              _recalculateTotal();
                            },
                          ),
                        ),
                      ],
                    ),
                    trailing: IconButton(
                      icon: const Icon(Icons.delete, color: Colors.red),
                      onPressed: () {
                        setState(() {
                          products.removeAt(index);
                          _recalculateTotal();
                        });
                      },
                    ),
                  ),
                );
              },
            ),
            const SizedBox(height: 10),
            ElevatedButton(
              onPressed: _addProduct,
              child: const Text('Add Product'),
            ),
          ],
        ),
      ),
    );
  }
}
