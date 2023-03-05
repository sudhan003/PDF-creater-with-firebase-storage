
import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:flutter_document_picker/flutter_document_picker.dart';
import 'package:flutter_pdf_demo/create_pdf.dart';
import 'package:flutter_pdf_demo/pdf_view_screen.dart';
import 'package:path/path.dart';
import 'package:flutter_pdf_demo/firebase_options.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({Key? key}) : super(key: key);

  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      title: 'Flutter Demo',
      theme: ThemeData(
        primarySwatch: Colors.blue,
      ),
      home: const MyHomePage(title: 'Flutter Demo Home Page'),
    );
  }
}

class MyHomePage extends StatefulWidget {
  const MyHomePage({Key? key, required this.title}) : super(key: key);
  final String title;

  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

class _MyHomePageState extends State<MyHomePage> {
  bool isLoading = false;
  uploadFile(File file) async {
    setState(() {
      isLoading = true;
    });
    final ref =
        await FirebaseStorage.instance.ref('pdf_files').child(basename(file.path));
    await ref
        .putFile(file)
        .whenComplete(() => debugPrint('upload successfully completed'));
    final uri = await ref.getDownloadURL();

    await FirebaseFirestore.instance.collection('pdf_files').add({
      "pdf_file_name": basename(file.path),
      "pdf_path": uri,
      "date_time": DateTime.now().toString()
    });
    setState(() {
      isLoading = false;
    });
  }
 CreatePdf createPdf = CreatePdf();
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text(
          "PDF",
          style: TextStyle(color: Colors.black),
        ),
        backgroundColor: Colors.amberAccent,
        actions: [
          IconButton(onPressed: () async{
            final data = await createPdf.createPdfView();
            createPdf.savePDFfile(DateTime.now().toString(), data);
          }, icon: const Icon(Icons.add,color: Colors.black,))
        ],
      ),
      body: Stack(
        children: [
          StreamBuilder<QuerySnapshot>(
            builder: (context, snapshot) {
              return snapshot.hasData
                  ? ListView.builder(
                      itemBuilder: (context, index) => Card(
                        child: ListTile(
                          onTap: () {
                            Navigator.of(context).push(MaterialPageRoute(
                                builder: (_) => PDFViewScreen(
                                      link: snapshot.data!.docs[index]
                                          ["pdf_path"],
                                      filename: snapshot.data!.docs[index]
                                          ["pdf_file_name"],
                                    )));
                          },
                          title:
                              Text(snapshot.data!.docs[index]["pdf_file_name"]),
                          subtitle:
                              Text(snapshot.data!.docs[index]["date_time"]),
                          trailing: TextButton(
                            child: const Text(
                              'View file',
                              style: TextStyle(color: Colors.amber),
                            ),
                            onPressed: () {
                              Navigator.of(context).push(MaterialPageRoute(
                                  builder: (_) => PDFViewScreen(
                                        link: snapshot.data!.docs[index]
                                            ["pdf_path"],
                                        filename: snapshot.data!.docs[index]
                                            ["pdf_file_name"],
                                      )));
                            },
                          ),
                        ),
                      ),
                      itemCount: snapshot.data!.docs.length,
                    )
                  : const Center(
                      child: Text('PDF file loading'),
                    );
            },
            stream:
                FirebaseFirestore.instance.collection("pdf_files").orderBy("date_time",descending: true).snapshots(),
          ),
          if (isLoading)
            Container(
              width: MediaQuery.of(context).size.width,
              height: MediaQuery.of(context).size.height,
              child: Center(
                  child: Column(
                      mainAxisAlignment: MainAxisAlignment.center,
                      children: const [
                    Text('File uploading...'),
                    CircularProgressIndicator()
                  ])),
            )
        ],
      ),
      floatingActionButton: FloatingActionButton(
        backgroundColor: Colors.amber,
        onPressed: () async {
          final path = await FlutterDocumentPicker.openDocument();
          print(path);
          File file = File(path!);
          if (file.path.isNotEmpty) {
            uploadFile(file);
          }
        },
        child: const Icon(
          Icons.add,
          color: Colors.black,
        ),
      ), // This trailing comma makes auto-formatting nicer for build methods.
    );
  }
}
