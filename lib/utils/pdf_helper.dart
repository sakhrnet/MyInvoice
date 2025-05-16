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
    // تحميل الخط العربي
    final fontData = await rootBundle.load('assets/fonts/Almarai-Regular.ttf');
    final ttf = pw.Font.ttf(fontData);

    // تحميل صورة الترويسة من التخزين الخاص بالتطبيق
    final Directory appDir = await getApplicationDocumentsDirectory();
    final File headerFile = File('${appDir.path}/header.jpg');

    pw.MemoryImage? headerImage;
    if (await headerFile.exists()) {
      final Uint8List headerImageData = await headerFile.readAsBytes();
      headerImage = pw.MemoryImage(headerImageData);
    }

    // إنشاء مستند PDF
    final pdf = pw.Document();

    // إضافة صفحة إلى المستند
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
                  textDirection: pw.TextDirection.rtl,
                  child: pw.Column(
                    crossAxisAlignment: pw.CrossAxisAlignment.start,
                    children: [
                      // التاريخ وفاتورة رقم والعملة
                      pw.Row(
                        mainAxisAlignment: pw.MainAxisAlignment.spaceBetween,
                        children: [
                          pw.Text('التاريخ : $date',
                              style: pw.TextStyle(font: ttf, fontSize: 12)),
                          pw.Column(
                            crossAxisAlignment: pw.CrossAxisAlignment.start,
                            children: [
                              pw.Text('فاتورة رقم : $invoiceNumber',
                                  style: pw.TextStyle(font: ttf, fontSize: 12)),
                              pw.Text('العملة : $currency',
                                  style: pw.TextStyle(font: ttf, fontSize: 12)),
                            ],
                          ),
                        ],
                      ),
                      pw.SizedBox(height: 40),

                      // نوع الفاتورة في الوسط مع خط تحته
                      pw.Align(
                        alignment: pw.Alignment.center,
                        child: pw.Container(
                          decoration: pw.BoxDecoration(
                            border: pw.Border(
                              bottom: pw.BorderSide(
                                  width: 1, color: PdfColors.black),
                            ),
                          ),
                          child: pw.Text('نوع الفاتورة : $invoiceType',
                              style: pw.TextStyle(font: ttf, fontSize: 15)),
                        ),
                      ),
                      pw.SizedBox(height: 20),

                      // اسم العميل
                      pw.Text('الأخ / الأخوة  : $customerName',
                          style: pw.TextStyle(font: ttf, fontSize: 15)),
                      pw.SizedBox(height: 20),

                      // تفاصيل الفاتورة
                      pw.Table.fromTextArray(
                        headers: [
                          'التفاصيل / البيان',
                          'الكمية',
                          'السعر',
                          'الإجمالي'
                        ],
                        data: items.map((item) {
                          // تقسيم النص إلى أسطر بعد خمس كلمات
                          final String name = item['name'];
                          final List<String> words = name.split(' ');
                          String formattedName = '';
                          int wordCount = 0;

                          for (final word in words) {
                            if (wordCount == 10) {
                              formattedName +=
                                  '\n'; // إضافة سطر جديد بعد خمس كلمات
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
                              .topRight, // محاذاة النص في عمود "التفاصيل / البيان" لليمين
                          1: pw.Alignment.center, // توسيط النص في عمود "الكمية"
                          2: pw.Alignment.center, // توسيط النص في عمود "السعر"
                          3: pw.Alignment
                              .center, // توسيط النص في عمود "الإجمالي"
                        },
                      ),
                      pw.SizedBox(height: 10),

                      // الخصم والضريبة
                      pw.Text('الخصم : $discount',
                          style: pw.TextStyle(font: ttf, fontSize: 13)),
                      pw.Text('الضريبة : $tax',
                          style: pw.TextStyle(font: ttf, fontSize: 13)),

                      // خط فاصل ربع الصفحة جهة اليمين
                      pw.Container(
                        alignment: pw.Alignment.centerRight,
                        width: PdfPageFormat.a4.width / 4, // ربع الصفحة
                        child: pw.Divider(thickness: 1.5),
                      ),

                      // الإجمالي باللون الأحمر وبخط عريض
                      pw.Text('الإجمالي : $total $currency',
                          style: pw.TextStyle(
                              font: ttf,
                              fontSize: 15,
                              color: PdfColors.red,
                              fontWeight: pw.FontWeight.bold)),
                      pw.SizedBox(height: 30),

                      // الملاحظات مع خط تحتها
                      pw.Container(
                        decoration: pw.BoxDecoration(
                          border: pw.Border(
                            bottom:
                                pw.BorderSide(width: 1, color: PdfColors.black),
                          ),
                        ),
                        child: pw.Text('ملاحظات :',
                            style: pw.TextStyle(font: ttf, fontSize: 12)),
                      ),
                      pw.Text(notes,
                          style: pw.TextStyle(font: ttf, fontSize: 12)),
                    ],
                  ),
                ),
              ),
            ],
          );
        },
      ),
    );

    // حفظ المستند
    final Uint8List bytes = await pdf.save();

    // حفظ الملف في التخزين الخاص بالتطبيق مع رقم الفاتورة
    final File file = File('${appDir.path}/invoice_$invoiceNumber.pdf');
    await file.writeAsBytes(bytes);

    // فتح الملف
    print('تم حفظ ملف PDF في: ${file.path}');
    OpenFile.open(file.path);
  } catch (e) {
    print('حدث خطأ أثناء إنشاء ملف PDF: $e');
  }
}
