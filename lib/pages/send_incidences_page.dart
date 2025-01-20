import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/my_button.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';

class SendIncidencesPage extends StatefulWidget {
  const SendIncidencesPage({super.key});

  @override
  State<SendIncidencesPage> createState() => _SendIncidencesPageState();
}

class _SendIncidencesPageState extends State<SendIncidencesPage> {
  final FirebaseFirestore firestore = FirebaseFirestore.instance;
  bool _isLoading = false; // To track loading state

  Future<void> handleExcelImport() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Step 1: Pick the file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xls', 'xlsx'],
      );
      if (result == null) return; // User canceled the picker
      // final file = File(result.files.single.path!);

      // Step 2: Parse the Excel file
      // final bytes = file.readAsBytesSync();
      final bytes = result.files.single.bytes ?? File(result.files.single.path!).readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // Check if "AppInc" exists
      if (!excel.tables.containsKey("AppInc")) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró la hoja ${'"'}AppInc${'"'}')),
        );
        return;
      }

      // Extract data from "AppInc"
      var table = excel.tables["AppInc"]!;
      final auth = AuthService();
      final currUser = auth.getCurrentUser()!.uid;  
      if (table.rows.isEmpty) return;

      for (var i = 1; i < table.rows.length; i++) { // Skip header row
        var row = table.rows[i];
        String? email = row[0]?.value.toString(); // Email
        String? topic = row[1]?.value.toString(); // Topic
        String? message = row[2]?.value.toString(); // Message

        if (email != null && topic != null && message != null) {
          // Step 3: Update Firebase
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
                .collection("Incidences")
                .add({
              'alumno': topic,
              'mensaje': message,
              'createdBy': currUser,
              'timestamp': DateTime.now(),
            });
            if(!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds:2), 
                content: Text('Reporte guardado para el usuario $email')),
            );
          } else {
            if(!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(
                duration: const Duration(seconds:2), 
                content: Text('No se encontró el usuario $email')),
            );
          }
        }
      }
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de guardado $e')),
      );
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String a = "Recuerda que el archivo debe tener la hoja con ";
    String b = "el nombre AppInc y las columnas predefinidas: email, alumno y mensaje";
    return Scaffold(
      appBar: const MyAppbar(title: "Enviar Incidencias"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            _isLoading 
            ? CircularProgressIndicator()
            : MyButton(
                text: 'Subir Archivo Excel', 
                onTap: handleExcelImport,
              ),
            Padding(
              padding: const EdgeInsets.all(25),
              child: Text(a+b,
                style: TextStyle(color: Theme.of(context).colorScheme.primary),
                textAlign: TextAlign.center,
              ),
            ),
          ]
        ),
      ),
    );
  }
}