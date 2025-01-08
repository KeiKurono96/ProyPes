import 'dart:io';
import 'dart:typed_data';
import 'dart:ui';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';
import 'package:flutter/rendering.dart';
import 'package:intl/intl.dart';
import 'package:path_provider/path_provider.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/my_button.dart';
import 'package:prueba_chat/services/storage/storage_service.dart';

class ExcelPage extends StatefulWidget {
  const ExcelPage({super.key});

  @override
  State<ExcelPage> createState() => _ExcelPageState();
}

class _ExcelPageState extends State<ExcelPage> {
  List<List<Data?>> dataRows = [];
  List<String> sheetNames = [];
  String? selectedSheetName;
  String predefinedSheetName = "RepsAjsApp"; // Set the predefined sheet name here

  final GlobalKey repaintBoundaryKey = GlobalKey();

  // Function to pick and read an Excel file
  Future<void> pickAndReadExcelFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );

    if (result != null) {
      File file = File(result.files.single.path!);
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      //Get Sheet Names
      setState((){
        sheetNames = excel.tables.keys.toList();
      });

      if (sheetNames.isEmpty) {
        setState(() {
          dataRows = [];
        });
        return;
      }

      // Automatically load the predefined sheet if it exists
      if (excel.tables.containsKey(predefinedSheetName)) {
        loadSheetData(excel, predefinedSheetName);
      } else {
        // Prompt user to select a sheet if predefined sheet is unavailable
        showSheetSelectionDialog(excel);
      }
    }
  }

  // Function to load data from the selected sheet
  void loadSheetData(Excel excel, String sheetName) {
    var sheet = excel.tables[sheetName];
    if (sheet != null) {
      List<List<Data?>> rows = [];
      for (var row in sheet.rows) {
        rows.add(row);
      }
      setState(() {
        selectedSheetName = sheetName;
        dataRows = rows;
      });
    }
  }

  // Function to show a dialog for sheet selection
  void showSheetSelectionDialog(Excel excel) {
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: Text("Selecciona una Hoja", style: TextStyle(
          color: Theme.of(context).colorScheme.primary
        ),),
        content: SizedBox(
          width: double.maxFinite,
          child: ListView.builder(
            shrinkWrap: true,
            itemCount: sheetNames.length,
            itemBuilder: (context, index) {
              return ListTile(
                title: Text(sheetNames[index], style: TextStyle(
                color: Theme.of(context).colorScheme.primary),),
                onTap: () {
                  loadSheetData(excel, sheetNames[index]);
                  Navigator.of(context).pop();
                },
              );
            },
          ),
        ),
      ),
    );
  }

  // Function to save DataTable as an image
  Future<void> saveDataTableAsImage() async {
    RenderRepaintBoundary boundary =
      repaintBoundaryKey.currentContext!.findRenderObject() as RenderRepaintBoundary;
    var image = await boundary.toImage();
    ByteData? byteData = await image.toByteData(format: ImageByteFormat.png);
    StorageService storageService = StorageService();

    try {            
      if (byteData != null) {
        Uint8List pngBytes = byteData.buffer.asUint8List();
        final now = DateTime.now();
        final formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now); // e.g., 2024-12-27_15-45-10
        Directory? directory;
        File file;

        if (Platform.isAndroid){
          directory = await getExternalStorageDirectory();          
        } else {
          directory = await getApplicationDocumentsDirectory();
        }

        if (directory != null) {
          file = File('${directory.path}/$formattedDate.png');
          await file.writeAsBytes(pngBytes);
          if(!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            SnackBar(content: Text('Reporte guardado en ${file.path}')),
          );

          // Uploading the report to firebase storage
          try{
            await storageService.uploadImageFromPath(file.path, formattedDate);
            if(!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              const SnackBar(content: Text('Reporte enviado a la base de datos correctamente')),
            );
          } catch (e) {
            if(!mounted) return;
            ScaffoldMessenger.of(context).showSnackBar(
              SnackBar(content: Text('No se pudo enviar el reporte a la base de datos, error: $e')),
            );
          }
          
        } else {
          if(!mounted) return;
          ScaffoldMessenger.of(context).showSnackBar(
            const SnackBar(content: Text('No se pudo acceder al directorio')),
          );
        }
      }
    } on Exception catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Error de guardado: $e')),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppbar(title: "GENERACIÓN DE REPORTES"),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            MyButton(
              text: 'Subir Archivo Excel', 
              onTap: pickAndReadExcelFile,
            ),
            const SizedBox(height: 20),
            if (selectedSheetName != null)
              Text(
                "Mostrando Datos de la hoja: $selectedSheetName",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                ),
              ),
            const SizedBox(height: 20),
            if (dataRows.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: RepaintBoundary(
                  key: repaintBoundaryKey,
                  child: DataTable(
                    dataRowColor:  WidgetStateColor.resolveWith((states) => Colors.blue),
                    headingRowColor:
                      WidgetStateColor.resolveWith((states) => Colors.blue),
                    columns: dataRows.isNotEmpty
                        ? dataRows[0]
                            .map((e) =>
                                DataColumn(label: Text(e?.value.toString() ?? '')))
                            .toList()
                        : [],
                    rows: dataRows
                        .skip(1) // Skip the first row (header)
                        .map(
                          (row) => DataRow(
                            cells: row
                                .map(
                                  (e) =>
                                      DataCell(Text(e?.value.toString() ?? '')),
                                )
                                .toList(),
                          ),
                        )
                        .toList(),
                  ),
                ),
              )
            else
              Center(
                child: Column(
                  children: [
                    Text(
                      'No hay datos disponibles, por favor sube una hoja de cálculo',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                    const SizedBox(height: 30,),
                    Text(
                      '(...recuerda que la hoja debe tener la tabla en la celda A1)',
                      style: TextStyle(color: Theme.of(context).colorScheme.primary),
                    ),
                  ],
                ),
              ),
          ],
        ),
      ),
      bottomNavigationBar: BottomAppBar(
        padding: const EdgeInsets.only(bottom: 20),
        child: Row(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            MyButton(
              onTap: dataRows.isNotEmpty
                  ? saveDataTableAsImage
                  : null, // Disable button if no data
              text: 'Generar Reporte',
            ),
          ],
        ),
      ),
    );
  }
}
