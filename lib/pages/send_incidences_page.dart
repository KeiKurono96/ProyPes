import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
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
  String resultsText = "";

  bool isValid(String? value) {
    return value != null && value != "null";
  }

  Future<void> handleExcelImport() async {
    setState(() {
      _isLoading = true;
    });
    try {
      // Step 1: Pick the file
      FilePickerResult? result = await FilePicker.platform.pickFiles(
        type: FileType.custom,
        allowedExtensions: ['xls', 'xlsx', 'xlsm'],
      );
      if (result == null) return; // User canceled the picker

      // Step 2: Determine the platform and handle file path/byte
      String? filePath;
      List<int>? bytes;

      if (kIsWeb) {
        bytes = result.files.single.bytes!;
      } else if (Platform.isAndroid || Platform.isWindows) {
        filePath = result.files.single.path!;
        bytes = File(filePath).readAsBytesSync();
      } else {
        throw Exception("Unsupported platform");
      }

      // Step 3: Parse the Excel file
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

        if (isValid(email) && isValid(topic) && isValid(message)) {
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
            // excel.removeRow("AppInc", i);
            resultsText = "$resultsText \n(${i+1})Reporte guardado para el usuario $email";
          } else {
            resultsText = "$resultsText \n(${i+1})No se encontró el usuario $email";
          }
        } else {
          resultsText = "$resultsText \n(${i+1})Faltan llenar los campos";
        }
      }

      // Save the updated Excel file
      // var fileBytes = excel.save();
      // try{
      //   if (fileBytes != null) {
      //     if (kIsWeb) {
      //       // For web: Download the file
      //       // Use a package like `universal_html` or `flutter_download` to provide download functionality.
      //       print("File updated for web download.");
      //     } else if (filePath != null) {
      //       // For Android/desktop: Overwrite the original file
      //       File(filePath).writeAsBytesSync(fileBytes);
      //     }
      //   }
      //   print("File updated");
      // } catch (e) {
      //   print("Error, file not updated: $e");
      // }

    } catch (e) {
      resultsText = "$resultsText \nError de Guardado: $e";
    } finally {
      setState(() {
        _isLoading = false;
        resultsText;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    String a = "Recuerda que el archivo debe tener la hoja con el nombre AppInc";
    String b = " y las primeras 3 columnas predefinidas: correo del apoderado, alumno y la incidencia";
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
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 25),
              child: Text("Resultados :\n$resultsText",
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