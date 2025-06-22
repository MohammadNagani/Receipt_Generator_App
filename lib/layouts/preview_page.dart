import 'package:flutter/material.dart';
import 'package:printing/printing.dart';
import 'dart:io';

class PdfPreviewPage extends StatelessWidget {
  final File pdfFile;

  PdfPreviewPage({required this.pdfFile, });//required Map<String, dynamic> metadata

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: Text("PDF Preview")),
      body: PdfPreview(
        build: (format) async => pdfFile.readAsBytes(),
      ),
    );
  }
}
