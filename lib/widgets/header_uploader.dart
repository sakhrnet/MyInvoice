import 'dart:io';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:path_provider/path_provider.dart';

class HeaderUploader extends StatefulWidget {
  @override
  _HeaderUploaderState createState() => _HeaderUploaderState();
}

class _HeaderUploaderState extends State<HeaderUploader> {
  File? _headerFile;

  @override
  void initState() {
    super.initState();
    _loadHeader();
  }

  Future<void> _loadHeader() async {
    final appDir = await getApplicationDocumentsDirectory();
    final file = File('${appDir.path}/header.jpg');
    if (await file.exists()) {
      setState(() {
        _headerFile = file;
      });
    }
  }

  Future<void> _pickHeader() async {
    final picker = ImagePicker();
    final pickedFile = await picker.pickImage(source: ImageSource.gallery);
    if (pickedFile == null) return;

    final appDir = await getApplicationDocumentsDirectory();
    final savedPath = '${appDir.path}/header.jpg';
    final savedFile = await File(pickedFile.path).copy(savedPath);

    setState(() {
      _headerFile = savedFile;
    });

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('تم حفظ الترويسة بنجاح')),
    );
  }

  void _showHeaderDialog() {
    if (_headerFile == null) {
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('لا توجد ترويسة محفوظة')),
      );
      return;
    }

    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text('الترويسة الحالية'),
        content: Image.file(_headerFile!),
        actions: [
          TextButton(
            child: Text('إغلاق'),
            onPressed: () => Navigator.of(context).pop(),
          ),
        ],
      ),
    );
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        ElevatedButton.icon(
          icon: Icon(Icons.upload),
          label: Text('رفع ترويسة'),
          onPressed: _pickHeader,
        ),
        SizedBox(height: 10),
        ElevatedButton.icon(
          icon: Icon(Icons.image),
          label: Text('عرض الترويسة'),
          onPressed: _showHeaderDialog,
        ),
      ],
    );
  }
}
