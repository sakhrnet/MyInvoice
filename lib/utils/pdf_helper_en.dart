import 'dart:io';
import 'dart:typed_data';
import 'package:path_provider/path_provider.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:flutter/services.dart' show rootBundle;
import 'package:open_file/open_file.dart';

Future<void> generateInvoicePdf({
  required String invoiceNumber,
  required String date,
  required String currency,
  required String invoiceType,
  required String customerName,
  required List<Map<String, dynamic>> items,
  required double discount,
  required double tax,
  required double total,
  required String notes,
}) async {
  try {
    // Load English font
    final fontData = await rootBundle.load('assets/fonts/Roboto-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    // Load header image from app storage
    final Directory appDir = await getApplicationDocumentsDirectory();
    final File headerFile = File('${appDir.path}/header.jpg');

    pw.MemoryImage? headerImage;
    if (await headerFile.exists()) {
      final Uint8List headerImageData = await headerFile.readAsBytes();
      headerImage = pw.MemoryImage(headerImageData);
    }

    // Create PDF document
    final pdf = pw.Document();

    // Add a page to the document
    pdf.addPage(
      pw.Page(
        pageFormat: PdfPageFormat.a4.copyWith(
          marginLeft: 10,
          marginRight: 10,
          marginTop: 10,
          marginBottom: 10,
        ), // إزالة الهوامش
        build: (pw.Context context) {
          return pw.Stack(
            children: [
              // إضافة صورة الترويسة كخلفية إذا كانت موجودة
              if (headerImage != null)
                pw.Positioned.fill(
                  child: pw.Image(headerImage,
                      fit:
                          pw.BoxFit.fill), // تمديد الصورة لتغطية الورقة بالكامل
                ),
              // إضافة النصوص تحت الترويسة
              pw.Padding(
                padding:
                    const pw.EdgeInsets.only(top: 130, left: 50, right: 50),
                child: pw.Directionality(
                  textDirection: pw.TextDirection.ltr,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // Date, Invoice Number, and Currency
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('Date: $date',
                              style: pw.TextStyle(font: ttf, fontSize: 12)),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('Invoice No: $invoiceNumber',
                                  style: pw.TextStyle(font: ttf, fontSize: 12)),
                              pw.Text('Currency: $currency',
                                  style: pw.TextStyle(font: ttf, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 30),

                      // Invoice Type centered with underline
                      pw.Align(
                        alignment: pw.Alignment.center,
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(
                                  width: 1, color: PdfColors.black),
                            ),
                          ),
                          child: pw.Text('Invoice Type: $invoiceType',
                              style: pw.TextStyle(font: ttf, fontSize: 14)),
                        ),
                      ),
                      pw.SizedBox(height: 20),

                      // Customer Name
                      pw.Text('Customer: $customerName',
                          style: pw.TextStyle(font: ttf, fontSize: 13)),
                      pw.SizedBox(height: 20),

                      // Invoice Details
                      pw.Text('Invoice Details',
                          style: pw.TextStyle(font: ttf, fontSize: 12)),
                      pw.Table.fromTextArray(
                        headers: ['Details', 'Quantity', 'Price', 'Total'],
                        data: items.map((item) {
                          // Split text into lines after five words
                          final String name = item['name'];
                          final List<String> words = name.split(' ');
                          String formattedName = '';
                          int wordCount = 0;

                          for (final word in words) {
                            if (wordCount == 10) {
                              formattedName +=
                                  '\n'; // Add a new line after five words
                              wordCount = 0;
                            }
                            formattedName += '$word ';
                            wordCount++;
                          }

                          return [
                            formattedName.trim(),
                            item['quantity'].toString(),
                            item['unitPrice'].toStringAsFixed(2),
                            (item['quantity'] * item['unitPrice'])
                                .toStringAsFixed(2),
                          ];
                        }).toList(),
                        headerStyle: pw.TextStyle(font: ttf, fontSize: 13),
                        cellStyle: pw.TextStyle(font: ttf, fontSize: 12),
                        cellAlignments: {
                          0: pw.Alignment
                              .topLeft, // Align "Details" column to the left
                          1: pw.Alignment.center, // Center align "Quantity"
                          2: pw.Alignment.center, // Center align "Price"
                          3: pw.Alignment.center, // Center align "Total"
                        },
                      ),
                      pw.SizedBox(height: 10),

// Discount and Tax
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text('Discount: $discount',
                            style: pw.TextStyle(font: ttf, fontSize: 12)),
                      ),
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text('Tax: $tax',
                            style: pw.TextStyle(font: ttf, fontSize: 12)),
                      ),

// Divider (Quarter page width, right-aligned)
                      pw.Row(
                        children: [
                          pw.Spacer(), // يدفع الخط لليمين
                          pw.Container(
                            width: PdfPageFormat.a4.width / 4,
                            child: pw.Divider(thickness: 1.5),
                          ),
                        ],
                      ),

// Total in bold red
                      pw.Align(
                        alignment: pw.Alignment.centerRight,
                        child: pw.Text('Total: $total $currency',
                            style: pw.TextStyle(
                                font: ttf,
                                fontSize: 14,
                                color: PdfColors.red,
                                fontWeight: pw.FontWeight.bold)),
                      ),
                      pw.SizedBox(height: 30),

// Notes with underline
                      pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(
                                  width: 1, color: PdfColors.black),
                            ),
                          ),
                          child: pw.Text('Notes:',
                              style: pw.TextStyle(font: ttf, fontSize: 12)),
                        ),
                      ),
                      pw.Align(
                        alignment: pw.Alignment.centerLeft,
                        child: pw.Text(notes,
                            style: pw.TextStyle(font: ttf, fontSize: 12)),
                      ),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // Save the document
    final Uint8List bytes = await pdf.save();

    // Save the file in app storage with the invoice number
    final File file = File('${appDir.path}/invoice_$invoiceNumber.pdf');
    await file.writeAsBytes(bytes);

    // Open the file
    print('PDF saved at: ${file.path}');
    OpenFile.open(file.path);
  } catch (e) {
    print('Error generating PDF: $e');
  }
}
