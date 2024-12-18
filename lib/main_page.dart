import 'dart:io';
import 'package:excel/excel.dart';
import 'package:file_picker/file_picker.dart';
import 'package:flutter/material.dart';


class MainPage extends StatefulWidget {
  const MainPage({super.key});

  @override
  State<MainPage> createState() => _MainPageState();
}

class _MainPageState extends State<MainPage> {
  String _fileText = "";

  void _pickFile() async {
    FilePickerResult? result = await FilePicker.platform.pickFiles(
      type: FileType.custom,
      allowedExtensions: ['xlsx'],
      allowMultiple: false,
    );
    if (result != null && result.files.single.path != null) {
      PlatformFile file = result.files.first;
        
        print(file.name);
        print(file.bytes);
        print(file.size);
        print(file.extension);
        print(file.path);
        
        /// Normal file
        File file0 = File(result.files.single.path!);
        setState(() {
          _fileText = file0.path;     
        });                
    } else {
      /// User canceled the picker
    }
  }

  void _readExcel() async {
    var file = _fileText;
    var bytes = File(file).readAsBytesSync();
    var excel = Excel.decodeBytes(bytes);
    for (var table in excel.tables.keys) {
      print(table); //sheet Name
      print(excel.tables[table]!.maxColumns);
      print(excel.tables[table]!.maxRows);
      for (var row in excel.tables[table]!.rows) {
        for (var cell in row) {
          print('cell ${cell!.rowIndex}/${cell.columnIndex}');
          final value = cell.value;
          switch(value){
            case null:
              print('  empty cell');
            case TextCellValue():
              print('  text: ${value.value}');
            case FormulaCellValue():
              print('  formula: ${value.formula}');
            case IntCellValue():
              print('  int: ${value.value}');
            case BoolCellValue():
              print('  bool: ${value.value ? 'YES!!' : 'NO..' }');
            case DoubleCellValue():
              print('  double: ${value.value}');
            case DateCellValue():
              print('  date: ${value.year} ${value.month} ${value.day} (${value.asDateTimeLocal()})');
            case TimeCellValue():
              print('  time: ${value.hour} ${value.minute} ... (${value.asDuration()})');
            case DateTimeCellValue():
              print('  date with time: ${value.year} ${value.month} ${value.day} ${value.hour} ... (${value.asDateTimeLocal()})');
          }
        }
      }
    }
  }
  

  @override
  Widget build(BuildContext context) {
    return Scaffold(
        body: Center(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.center,
            mainAxisSize: MainAxisSize.min,
            children: [              
              ElevatedButton(
                onPressed: _pickFile,
                child: const Text("Seleccionar Excel"),
              ),
              const SizedBox(height: 20,),
              const Text('La ruta del archivo es:'),
              const SizedBox(height: 10,),
              Text(_fileText),
              const SizedBox(height: 20,),
              ElevatedButton(
                onPressed: _readExcel,
                child: const Text("Leer Excel"),
              ),
            ],
          ),
        ),
        
      );
  }
}