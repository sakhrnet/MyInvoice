import 'package:flutter/material.dart';
import 'package:intl/intl.dart' as intl;
import 'db_helper.dart';
import 'view_invoices_page.dart';
import 'utils/pdf_helper.dart';

class EditInvoicePageAr extends StatefulWidget {
  final Map<String, dynamic>? invoiceData; // استقبال بيانات الفاتورة

  const EditInvoicePageAr({super.key, this.invoiceData});

  @override
  State<EditInvoicePageAr> createState() => _EditInvoicePageArState();
}

class _EditInvoicePageArState extends State<EditInvoicePageAr> {
  int invoiceNumber = 1;
  String invoiceType = 'عرض سعر';
  String currency = 'ريال يمني';
  double total = 0.0; // تعريف متغير الإجمالي
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
    if (widget.invoiceData != null) {
      _loadInvoiceData(
          widget.invoiceData!); // تحميل بيانات الفاتورة إذا كانت موجودة
    } else {
      _loadLastInvoiceNumber();
    }
    taxController.addListener(_updateTotal);
    discountController.addListener(_updateTotal);
  }

  Future<void> _loadLastInvoiceNumber() async {
    int lastNumber = await DBHelper.getLastInvoiceNumber();
    setState(() {
      invoiceNumber = lastNumber + 1;
    });
  }

  void _loadInvoiceData(Map<String, dynamic> invoiceData) {
    setState(() {
      invoiceNumber = int.parse(invoiceData['number']);
      invoiceType = invoiceData['type'];
      currency = invoiceData['currency'];
      customerNameController.text = invoiceData['customer'];
      notesController.text = invoiceData['notes'];
      discountController.text = invoiceData['discount'].toString();
      taxController.text = invoiceData['tax'].toString();
      total = invoiceData['total'];
    });

    // تحميل المنتجات المرتبطة بالفاتورة
    DBHelper.getInvoiceItems(invoiceData['id']).then((items) {
      setState(() {
        products = List<Map<String, dynamic>>.from(items.map((item) {
          return {
            'name': item['name'] ?? '',
            'quantity': item['quantity'] ?? 0,
            'unitPrice': item['unit_price'] ?? 0.0,
          };
        }));
      });
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
      final unitPrice =
          item['unitPrice'] ?? 0.0; // إذا كانت القيمة null، اجعلها 0.0
      final quantity = item['quantity'] ?? 0; // إذا كانت القيمة null، اجعلها 0
      subtotal += unitPrice * quantity;
    }
    return subtotal;
  }

  void addProduct() {
    final name = productNameController.text.trim();
    final quantity = int.tryParse(quantityController.text) ?? 0;
    final unitPrice = double.tryParse(unitPriceController.text) ?? 0.0;

    if (name.isEmpty || quantity <= 0 || unitPrice <= 0.0) {
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('يرجى إدخال بيانات المنتج بشكل صحيح')),
      );
      return;
    }

    setState(() {
      products.add({
        'name': name,
        'quantity': quantity,
        'unitPrice': unitPrice,
      });
      _updateTotal(); // تحديث الإجمالي بعد إضافة المنتج
    });

    // إعادة تعيين الحقول
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
      textDirection: TextDirection.rtl,
      child: Scaffold(
        appBar: AppBar(title: const Text('تعديل فاتورة'), centerTitle: true),
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
                    items: ['ريال يمني', 'دولار امريكي', 'ريال سعودي']
                        .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                        .toList(),
                    onChanged: (value) => setState(() => currency = value!),
                  ),
                  Column(
                    crossAxisAlignment: CrossAxisAlignment.end,
                    children: [
                      Text(
                          'رقم الفاتورة: ${invoiceNumber.toString().padLeft(5, '0')}'),
                      Text(
                          'التاريخ: ${intl.DateFormat('yyyy-MM-dd').format(DateTime.now())}'),
                    ],
                  ),
                ],
              ),
              const SizedBox(height: 10),
              DropdownButtonFormField<String>(
                decoration: const InputDecoration(labelText: 'نوع الفاتورة'),
                value: invoiceType,
                items: [
                  'عرض سعر',
                  'فاتورة نقدية',
                  'فاتورة آجلة',
                  'فاتورة مرتجع'
                ]
                    .map((e) => DropdownMenuItem(value: e, child: Text(e)))
                    .toList(),
                onChanged: (value) => setState(() => invoiceType = value!),
              ),
              TextFormField(
                controller: customerNameController,
                decoration: const InputDecoration(labelText: 'اسم العميل'),
              ),
              const Divider(height: 30),
              const Text('تفاصيل المنتجات'),
              TextFormField(
                controller: productNameController,
                decoration: const InputDecoration(labelText: 'اسم المنتج'),
              ),
              TextFormField(
                controller: quantityController,
                decoration: const InputDecoration(labelText: 'الكمية'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: unitPriceController,
                decoration: const InputDecoration(labelText: 'سعر الوحدة'),
                keyboardType: TextInputType.number,
              ),
              ElevatedButton(
                onPressed: addProduct,
                child: const Text('إضافة'),
              ),
              const SizedBox(height: 20),
              const Text('المنتجات:'),
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
                decoration: const InputDecoration(labelText: 'الضريبة %'),
                keyboardType: TextInputType.number,
              ),
              TextFormField(
                controller: discountController,
                decoration: const InputDecoration(labelText: 'الخصم'),
                keyboardType: TextInputType.number,
              ),
              const SizedBox(height: 10),
              Text('المجموع الكلي: ${total.toStringAsFixed(2)} $currency',
                  style: const TextStyle(
                      fontWeight: FontWeight.bold, fontSize: 16)),
              TextFormField(
                controller: notesController,
                decoration: const InputDecoration(labelText: 'ملاحظات'),
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
                        // حفظ بيانات الفاتورة
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

                        if (widget.invoiceData != null) {
                          // تعديل الفاتورة الموجودة
                          await DBHelper.updateInvoice(
                              widget.invoiceData!['id'], invoiceData);
                          await DBHelper.deleteInvoiceItems(
                              widget.invoiceData!['id']);
                          await DBHelper.insertInvoiceItems(
                              widget.invoiceData!['id'], products);
                        } else {
                          // إنشاء فاتورة جديدة
                          int invoiceId =
                              await DBHelper.insertInvoice(invoiceData);
                          await DBHelper.insertInvoiceItems(
                              invoiceId, products);
                        }

                        // إنشاء ملف PDF
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

                        // عرض رسالة نجاح
                        ScaffoldMessenger.of(context).showSnackBar(
                          const SnackBar(
                              content:
                                  Text('تم حفظ الفاتورة وإنشاء ملف PDF بنجاح')),
                        );

                        // إعادة تعيين الحقول إذا كانت فاتورة جديدة
                        if (widget.invoiceData == null) {
                          setState(() {
                            invoiceNumber++;
                            products.clear();
                            customerNameController.clear();
                            notesController.clear();
                            discountController.text = '0';
                            taxController.text = '0';
                          });
                        }
                      } catch (e) {
                        // عرض رسالة خطأ
                        ScaffoldMessenger.of(context).showSnackBar(
                          SnackBar(
                              content: Text('حدث خطأ أثناء إنشاء ملف PDF: $e')),
                        );
                      }
                    },
                    child: const Text('حفظ الفاتورة وإنشاء PDF'),
                  ),
                  ElevatedButton(
                    onPressed: () {
                      Navigator.push(
                          context,
                          MaterialPageRoute(
                              builder: (_) => const ViewInvoicesPage()));
                    },
                    child: const Text('عرض الفواتير'),
                  ),
                  ElevatedButton(
                      onPressed: () {
                        Navigator.pop(context);
                      },
                      child: const Text('إغلاق')),
                ],
              )
            ],
          ),
        ),
      ),
    );
  }
}
