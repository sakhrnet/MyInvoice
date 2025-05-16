import 'package:sqflite/sqflite.dart';
import 'package:path/path.dart';

class DBHelper {
  static Database? _db;

  static Future<Database> get database async {
    if (_db != null) return _db!;
    _db = await _initDB();
    return _db!;
  }

  static Future<Database> _initDB() async {
    final path = join(await getDatabasesPath(), 'invoices.db');
    return await openDatabase(
      path,
      version: 1,
      onCreate: (db, version) async {
        await db.execute('''
          CREATE TABLE invoices (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            number TEXT,
            date TEXT,
            type TEXT,
            customer TEXT,
            currency TEXT,
            tax REAL,
            discount REAL,
            total REAL,
            notes TEXT
          )
        ''');

        await db.execute('''
          CREATE TABLE invoice_items (
            id INTEGER PRIMARY KEY AUTOINCREMENT,
            invoice_id INTEGER,
            name TEXT,
            quantity INTEGER,
            unit_price REAL
          )
        ''');
      },
    );
  }

  static Future<int> insertInvoice(Map<String, dynamic> invoice) async {
    final db = await database;
    return await db.insert('invoices', invoice);
  }

  static Future<void> insertInvoiceItems(
      int invoiceId, List<Map<String, dynamic>> items) async {
    final db = await database;
    for (var item in items) {
      await db.insert('invoice_items', {
        'invoice_id': invoiceId,
        'name': item['name'],
        'quantity': item['quantity'],
        'unit_price': item['unitPrice'],
      });
    }
  }

  static Future<int> getLastInvoiceNumber() async {
    final db = await database;
    final result = await db
        .rawQuery('SELECT MAX(CAST(number AS INTEGER)) as max FROM invoices');
    return result.first['max'] != null
        ? int.parse(result.first['max'].toString())
        : 0;
  }

  Future<List<Map<String, dynamic>>> fetchArabicInvoicesForView() async {
    final db = await DBHelper.database;
    final results = await db.query(
      'invoices',
      where: 'type IN (?, ?, ?, ?)', // تصفية بناءً على الأنواع المختلفة
      whereArgs: ['عرض سعر', 'فاتورة نقدية', 'فاتورة آجلة', 'فاتورة مرتجع'],
      orderBy: 'id DESC',
    );
    print('Fetched Arabic Invoices for View: $results'); // طباعة النتائج
    return results;
  }

  Future<List<Map<String, dynamic>>> fetchEnglishInvoicesForView() async {
    final db = await DBHelper.database;
    final results = await db.query(
      'invoices',
      where: 'type IN (?, ?, ?, ?)', // تصفية بناءً على الأنواع المختلفة
      whereArgs: [
        'Quotation',
        'Cash Invoice',
        'Credit Invoice',
        'Return Invoice'
      ],
      orderBy: 'id DESC',
    );
    print(
        'Fetched English Invoices for View: $results'); // طباعة النتائج للتحقق
    return results;
  }

  static Future<List<Map<String, dynamic>>> fetchArabicInvoices() async {
    final db = await DBHelper.database;
    final results = await db.query(
      'invoices',
      where: 'type IN (?, ?, ?, ?)', // تصفية بناءً على الأنواع المختلفة
      whereArgs: ['عرض سعر', 'فاتورة نقدية', 'فاتورة آجلة', 'فاتورة مرتجع'],
      orderBy: 'id DESC',
    );
    print('Fetched Arabic Invoices: $results'); // طباعة النتائج للتحقق
    return results;
  }

  static Future<List<Map<String, dynamic>>> fetchEnglishInvoices() async {
    final db = await DBHelper.database;
    return await db.query(
      'invoices',
      where: 'type = ?', // تصفية الفواتير الإنجليزية
      whereArgs: ['Quotation'],
      orderBy: 'id DESC',
    );
  }

  // Search invoices
  static Future<List<Map<String, dynamic>>> searchInvoices({
    required String customerName,
    required String invoiceNumber,
    required String invoiceType,
  }) async {
    final db = await database;
    return await db.query(
      'invoices',
      where: '''
        (customer LIKE ? OR ? = '') AND
        (number LIKE ? OR ? = '') AND
        (type = ? OR ? = 'الكل')
      ''',
      whereArgs: [
        '%$customerName%',
        customerName,
        '%$invoiceNumber%',
        invoiceNumber,
        invoiceType,
        invoiceType,
      ],
    );
  }

  // Delete invoice and its items
  static Future<void> deleteInvoice(int invoiceId) async {
    final db = await database;

    // حذف العناصر المرتبطة بالفاتورة
    await db.delete(
      'invoice_items',
      where: 'invoice_id = ?',
      whereArgs: [invoiceId],
    );

    // حذف الفاتورة
    await db.delete(
      'invoices',
      where: 'id = ?',
      whereArgs: [invoiceId],
    );
  }

  // Fetch items for a specific invoice
  static Future<List<Map<String, dynamic>>> getInvoiceItems(
      int invoiceId) async {
    final db = await database;
    return await db.query(
      'invoice_items', // اسم جدول المنتجات المرتبطة بالفواتير
      where: 'invoice_id = ?', // شرط لجلب المنتجات المرتبطة برقم الفاتورة
      whereArgs: [invoiceId],
    );
  }

  // تحديث بيانات الفاتورة
  static Future<void> updateInvoice(
      int invoiceId, Map<String, dynamic> invoiceData) async {
    final db = await database;
    await db.update(
      'invoices', // اسم جدول الفواتير
      invoiceData, // البيانات الجديدة
      where: 'id = ?', // شرط التحديث
      whereArgs: [invoiceId], // تمرير رقم الفاتورة
    );
  }

  static Future<void> updateInvoiceEn(
      int invoiceId, Map<String, dynamic> invoiceData) async {
    final db = await database;
    await db.update(
      'invoices', // اسم جدول الفواتير
      invoiceData, // البيانات الجديدة
      where: 'id = ?', // شرط التحديث
      whereArgs: [invoiceId], // تمرير رقم الفاتورة
    );
  }

  // حذف المنتجات المرتبطة بالفاتورة
  static Future<void> deleteInvoiceItems(int invoiceId) async {
    final db = await database;
    await db.delete(
      'invoice_items', // اسم جدول المنتجات
      where: 'invoice_id = ?', // شرط الحذف
      whereArgs: [invoiceId], // تمرير رقم الفاتورة
    );
  }
}
