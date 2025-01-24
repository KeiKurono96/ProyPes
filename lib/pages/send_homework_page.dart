import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/foundation.dart';
import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/my_button.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';

class SendHomeworkPage extends StatefulWidget {
  const SendHomeworkPage({super.key});

  @override
  State<SendHomeworkPage> createState() => _SendHomeworkPageState();
}

class _SendHomeworkPageState extends State<SendHomeworkPage> {
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

      // Check if "AppTar" exists
      if (!excel.tables.containsKey("AppTar")) {
        if(!mounted) return;
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text('No se encontró la hoja ${'"'}AppTar${'"'}')),
        );
        return;
      }

      // Extract data from "AppTar"
      var table = excel.tables["AppTar"]!;
      final auth = AuthService();
      final currUser = auth.getCurrentUser()!.uid;  
      if (table.rows.isEmpty) return;

      for (var i = 1; i < table.rows.length; i++) { // Skip header row
        var row = table.rows[i];
        String? classroom = row[0]?.value.toString(); // Aula
        String? homework = row[1]?.value.toString(); // Tarea

        if (isValid(classroom) && isValid(homework)) {
          var classroomDoc = await FirebaseFirestore.instance
            .collection("Classrooms")
            .where("name", isEqualTo: classroom)
            .limit(1)
            .get();

          if (classroomDoc.docs.isNotEmpty) {
            await firestore.collection("Homework").add({
              'aula': classroom,
              'homework': homework,
              'createdBy': currUser,
              'timestamp': DateTime.now(),
            });
            // excel.removeRow("AppInc", i);
            resultsText = "$resultsText \n(${i+1})Se registró la tarea para el aula $classroom";
          } else {
            resultsText = "$resultsText \n(${i+1})No se encontró el aula $classroom, revise la escritura";
          }
        } else {
          resultsText = "$resultsText \n(${i+1})Faltan llenar los campos";
        }
      }
      
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
    String a = "Recuerda que el archivo debe tener la hoja con el nombre AppTar";
    String b = " y las primeras 2 columnas predefinidas: aula y tareas";
    return Scaffold(
      appBar: const MyAppbar(title: "Generar Reporte Tareas"),
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