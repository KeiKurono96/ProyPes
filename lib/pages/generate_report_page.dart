import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/my_button.dart';

class GenerateReportPage extends StatefulWidget {
  const GenerateReportPage({super.key});

  @override
  State<GenerateReportPage> createState() => _GenerateReportPageState();
}

class _GenerateReportPageState extends State<GenerateReportPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;

  Future<void> handleExcelImport() async {
  try {
    // Step 1: Pick the file
    FilePickerResult? result = await FilePicker.platform.pickFiles(type: FileType.any);
    if (result == null) return; // User canceled the picker
    final file = File(result.files.single.path!);

    // Step 2: Parse the Excel file
    var bytes = file.readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);

    // Check if "AppSheet" exists
    if (!excel.tables.containsKey("AppSheet")) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        const SnackBar(content: Text('No se encontró la hoja ${'"'}AppSheet${'"'}')),
      );
      return;
    }

    // Extract data from "AppSheet"
    var table = excel.tables["AppSheet"]!;
    if (table.rows.isEmpty) return;

    for (var i = 1; i < table.rows.length; i++) { // Skip header row
      var row = table.rows[i];
      String? email = row[0]?.value.toString(); // Email
      String? topic = row[1]?.value.toString(); // Topic
      String? message = row[2]?.value.toString(); // Message

      if (email != null && topic != null && message != null) {
        // Step 3: Update Firebase
        // Option 1: Add to "ExcelReports" collection
        // await firestore.collection("ExcelReports").add({
        //   'email': email,
        //   'topic': topic,
        //   'message': message,
        // });

        // Option 2: Add to user's sub-collection "Reports"
        var userDoc = await FirebaseFirestore.instance
            .collection("Users")
            .where("email", isEqualTo: email)
            .limit(1)
            .get();

        if (userDoc.docs.isNotEmpty) {
          var userId = userDoc.docs.first.id;
          await FirebaseFirestore.instance
              .collection("Users")
              .doc(userId)
              .collection("Reports")
              .add({
            'tema': topic,
            'mensaje': message,
          });
        } else {
          if(!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se encontró ese usuario')),
          );
        }
      }
    }
    if(!mounted) return;
    ScaffoldMessenger.of(context).showSnackBar(
      const SnackBar(content: Text('Reporte guardado satisfactoriamente')),
    );
  } catch (e) {
    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(content: Text('Error de guardado $e')),
    );
  }
}

  @override
  Widget build(BuildContext context) {
    String a = "Recuerda que el archivo debe tener la hoja con ";
    String b = "el nombre AppSheet y las columnas predefinidas: email, tema y mensaje";
    return Scaffold(
      appBar: const MyAppbar(title: "Generar Reporte Notas"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MyButton(
              text: 'Subir Archivo Excel', 
              onTap: handleExcelImport,
            ),
            Text(a+b,
              style: TextStyle(color: Theme.of(context).colorScheme.primary),
            )
          ],
        ),
      ),
    );
  }
}