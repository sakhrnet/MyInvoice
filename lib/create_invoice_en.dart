import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'db_helper.dart';
import 'view_invoices_page_en.dart';
import 'utils/pdf_helper_en.dart';

class CreateInvoicePageEn extends StatefulWidget {
  const CreateInvoicePageEn({super.key});

  @override
  State<CreateInvoicePageEn> createState() => _CreateInvoicePageEnState();
}

class _CreateInvoicePageEnState extends State<CreateInvoicePageEn> {
  int invoiceNumber = 1;
  String invoiceType = 'Quotation';
  String currency = 'USD';
  double total = 0.0;
  final customerNameController = TextEditingController();
  final notesController = TextEditingController();
  final productNameController = TextEditingController();
  final quantityController = TextEditingController();
  final unitPriceController = TextEditingController();
  final discountController = TextEditingController(text: '0');
  final taxController = TextEditingController(text: '0');

  List<Map<String, dynamic>> products = [];

  @override
  void initState() {
    super.initState();
    _loadLastInvoiceNumber();
    taxController.addListener(_updateTotal);
    discountController.addListener(_updateTotal);
  }

  Future<void> _loadLastInvoiceNumber() async {
    int lastNumber = await DBHelper.getLastInvoiceNumber();
    setState(() {
      invoiceNumber = lastNumber + 1;
    });
  }

  void _updateTotal() {
    double subtotal = calculateSubtotal();
    double discount = double.tryParse(discountController.text) ?? 0.0;
    double tax = double.tryParse(taxController.text) ?? 0.0;

    if (discount < 0) discount = 0;
    if (tax < 0) tax = 0;

    double discounted = subtotal - discount;
    if (discounted < 0) discounted = 0;

    total = discounted + (discounted * tax / 100);

    setState(() {});
  }

  double calculateSubtotal() {
    double subtotal = 0.0;
    for (var item in products) {
      subtotal += item['unitPrice'] * item['quantity'];
    }
    return subtotal;
  }

  void addProduct() {
    final name = productNameController.text.trim();
    final quantity = int.tryParse(quantityController.text) ?? 0;
    final unitPrice = double.tryParse(unitPriceController.text) ?? 0;

    if (name.isEmpty || quantity <= 0 || unitPrice <= 0) return;

    setState(() {
      products.add({
        'name': name,
        'quantity': quantity,
        'unitPrice': unitPrice,
      });
      _updateTotal();
    });

    productNameController.clear();
    quantityController.clear();
    unitPriceController.clear();
  }

  void deleteProduct(int index) {
    setState(() {
      products.removeAt(index);
      _updateTotal();
    });
  }

  void updateProduct(int index) {
    final item = products[index];
    productNameController.text = item['name'];
    quantityController.text = item['quantity'].toString();
    unitPriceController.text = item['unitPrice'].toString();
    deleteProduct(index);
  }

  @override
  Widget build(BuildContext context) {
    return Directionality(
      textDirection: TextDirection.ltr,
      child: Scaffold(
        appBar: AppBar(title: const Text('Create Invoice'), centerTitle: true),
        body: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  DropdownButton<String>(
                    value: currency,
                    underline: Container(),
                    items: ['USD', 'YER', 'SAR']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => currency = value!),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                          'Invoice No: ${invoiceNumber.toString().padLeft(5, '0')}'),
                      Text(
                          'Date: ${intl.DateFormat('yyyy-MM-dd').format(DateTime.now())}'),
                    ],
                  ),
                ],
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
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => invoiceType = value!),
              ),
              TextFormField(
                controller: customerNameController,
                decoration: const InputDecoration(labelText: 'Customer Name'),
              ),
              const Divider(height: 30),
              const Text('Product Details'),
              TextFormField(
                controller: productNameController,
                decoration: const InputDecoration(labelText: 'Product Name'),
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'Quantity'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: unitPriceController,
                decoration: const InputDecoration(labelText: 'Unit Price'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(onPressed: addProduct, child: const Text('Add')),
              const SizedBox(height: 20),
              const Text('Products:'),
              Column(
                children: products.asMap().entries.map((entry) {
                  int idx = entry.key;
                  var item = entry.value;
                  return ListTile(
                    title: Text(
                        '${item['name']} - ${item['quantity']} × ${item['unitPrice']}'),
                    trailing: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        IconButton(
                            onPressed: () => updateProduct(idx),
                            icon: const Icon(Icons.edit)),
                        IconButton(
                            onPressed: () => deleteProduct(idx),
                            icon: const Icon(Icons.delete, color: Colors.red)),
                      ],
                    ),
                  );
                }).toList(),
              ),
              const SizedBox(height: 20),
              TextFormField(
                controller: taxController,
                decoration: const InputDecoration(labelText: 'Tax %'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: discountController,
                decoration: const InputDecoration(labelText: 'Discount'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Text('Total: ${total.toStringAsFixed(2)} $currency',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'Notes'),
                maxLines: 3,
              ),
              const SizedBox(height: 20),
              Wrap(
                spacing: 10,
                runSpacing: 10,
                children: [
                  ElevatedButton(
                    onPressed: () async {
                      try {
                        // Save invoice data
                        final invoiceData = {
                          'number': invoiceNumber.toString().padLeft(5, '0'),
                          'date': intl.DateFormat('yyyy-MM-dd')
                              .format(DateTime.now()),
                          'type': invoiceType,
                          'customer': customerNameController.text,
                          'currency': currency,
                          'tax': double.tryParse(taxController.text) ?? 0,
                          'discount':
                              double.tryParse(discountController.text) ?? 0,
                          'total': total,
                          'notes': notesController.text,
                        };

                        // Save the invoice in the database
                        int invoiceId =
                            await DBHelper.insertInvoice(invoiceData);
                        await DBHelper.insertInvoiceItems(invoiceId, products);

                        //Create a PDF file
                        await generateInvoicePdf(
                          invoiceNumber:
                              invoiceNumber.toString().padLeft(5, '0'),
                          date: intl.DateFormat('yyyy-MM-dd')
                              .format(DateTime.now()),
                          currency: currency,
                          invoiceType: invoiceType,
                          customerName: customerNameController.text,
                          items: products,
                          discount:
                              double.tryParse(discountController.text) ?? 0.0,
                          tax: double.tryParse(taxController.text) ?? 0.0,
                          total: total,
                          notes: notesController.text,
                        );

                        // Show success message
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content: Text(
                                  'Invoice saved and PDF file created successfully.')),
                        );

                        // Reset fields
                        setState(() {
                          invoiceNumber++;
                          products.clear();
                          customerNameController.clear();
                          notesController.clear();
                          discountController.text = '0';
                          taxController.text = '0';
                        });
                      } catch (e) {
                        // Show an error message
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text(
                                  'An error occurred while creating the PDF file.: $e')),
                        );
                      }
                    },
                    child: const Text('Save invoice and create PDF'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ViewInvoicesPageEn()));
                    },
                    child: const Text('View invoices'),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('Close')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
