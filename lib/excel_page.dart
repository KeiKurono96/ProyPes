import 'dart:io';

import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';

class ExcelPage extends StatefulWidget {
  const ExcelPage({super.key});

  @override
  State<ExcelPage> createState() => _ExcelPageState();
}

class _ExcelPageState extends State<ExcelPage> {
  List<List<Data?>> dataRows = [];
  
  // Function to pick and read an Excel file
  Future<void> pickAndReadExcelFile() async {
    // Use file_picker to pick an Excel file
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xls', 'xlsx'],
    );

    if (result != null) {
      // Get the picked file
      File file = File(result.files.single.path!);

      // Read the Excel file
      var bytes = file.readAsBytesSync();
      var excel = Excel.decodeBytes(bytes);

      // Process the Excel sheets
      List<List<Data?>> rows = [];
      for (var table in excel.tables.keys) {
        var sheet = excel.tables[table];
        if (sheet != null) {
          for (var row in sheet.rows) {
            rows.add(row);
          }
        }
      }

      setState(() {
        dataRows = rows;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('Excel to DataTable'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(16.0),
        child: Column(
          children: [
            ElevatedButton(
              onPressed: pickAndReadExcelFile,
              child: Text('Pick an Excel File'),
            ),
            SizedBox(height: 20),
            if (dataRows.isNotEmpty)
              SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: DataTable(
                  columns: dataRows.isNotEmpty
                      ? dataRows[0]
                          .map((e) => DataColumn(label: Text(e?.value.toString() ?? '')))
                          .toList()
                      : [],
                  rows: dataRows
                      .skip(1) // Skip the first row as it is the header
                      .map(
                        (row) => DataRow(
                          cells: row
                              .map(
                                (e) => DataCell(Text(e?.value.toString() ?? '')),
                              )
                              .toList(),
                        ),
                      )
                      .toList(),
                ),
              ),
            if (dataRows.isEmpty)
              Center(child: Text('No data available, please pick an Excel file.')),
          ],
        ),
      ),
    );
  }
}