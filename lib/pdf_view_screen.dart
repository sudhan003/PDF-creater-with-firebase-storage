import 'dart:io';

import 'package:flutter/material.dart';
import 'package:path_provider/path_provider.dart';
import 'package:http/http.dart' as http;
import 'package:pdf_viewer_plugin/pdf_viewer_plugin.dart';

class PDFViewScreen extends StatefulWidget {
  final String filename;
  final String link;
  const PDFViewScreen({Key? key, required this.filename, required this.link})
      : super(key: key);

  @override
  State<PDFViewScreen> createState() => _PDFViewScreenState();
}

class _PDFViewScreenState extends State<PDFViewScreen> {
  String pdfFilePath = "";
  downloadaAndSavePDF() async {
    final dir = await getApplicationDocumentsDirectory();
    final File file = File("${dir.path}/${widget.filename}");
    if (await file.exists()) {
      setState(() {
        pdfFilePath = file.path;
      });
      debugPrint("file exist");
    } else {
      final response = await http.get(Uri.parse(widget.link));
      await file.writeAsBytes(response.bodyBytes);
      setState(() {
        pdfFilePath = file.path;
      });
      debugPrint('file downloading');
    }
  }

  @override
  void initState() {
    downloadaAndSavePDF();
    // TODO: implement initState
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.amberAccent,
        title: Text(
          widget.filename,
          style: TextStyle(color: Colors.black),
        ),
      ),
      body: pdfFilePath.isEmpty
          ? const Center(child: CircularProgressIndicator())
          : PdfView(path: pdfFilePath),
    );
  }
}
