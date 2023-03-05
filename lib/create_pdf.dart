import 'dart:io';
import 'dart:typed_data';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/cupertino.dart';
import 'package:path_provider/path_provider.dart';
import 'package:path/path.dart';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;

class CreatePdf {
  //Uint8List represent the type of the function return
  Future<Uint8List> createPdfView() async {
    //used to create pdf
    final pdf = pw.Document();
    // addPage is used to add a page or create a page
    pdf.addPage(
      pw.Page(build: (pw.Context context) {
        return pw.Center(child: pw.Text("PDF created successfully"));
      }),
    );
    pdf.addPage(pw.Page(build: (pw.Context context) {
      return pw.Center(child: pw.Text("PDF created successfully"));
    }));
    //this is used to save the pdf
    return pdf.save();
  }

  //this function used to save...save Uint8List data in the filename
  savePDFfile(String fileName, Uint8List data) async {
    //use this to get the document directory path
    //bellow three lines are used   define the file path
    Directory directory = await getApplicationDocumentsDirectory();
    final filePath = "${directory.path}$fileName.pdf";
    File file = File(filePath);
    //used to write data inside to file
    file.writeAsBytes(data);

    final ref =
        FirebaseStorage.instance.ref('pdf_files').child(basename(file.path));
    await ref
        .putFile(file)
        .whenComplete(() => debugPrint('upload successfully completed'));
    final uri = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('pdf_files').add({
      "pdf_file_name": basename(file.path),
      "pdf_path": uri,
      "date_time": DateTime.now().toString()
    });
  }
}
