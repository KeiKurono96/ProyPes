import 'package:flutter/material.dart';
import 'package:prueba_chat/components/classroom_tile.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/my_drawer.dart';
import 'package:prueba_chat/components/my_textfield.dart';
import 'package:prueba_chat/services/storage/storage_service.dart';

class ClassroomsPage extends StatefulWidget {
  const ClassroomsPage({super.key});

  @override
  State<ClassroomsPage> createState() => _ClassroomsPageState();
}

class _ClassroomsPageState extends State<ClassroomsPage> {
  final StorageService storageService = StorageService();
  
  void addClassroom(BuildContext context) async{
    TextEditingController classnameController = TextEditingController();
    String name = "test";
    bool confirm = await showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
        title: Text(
          "Creación de Aula",
          style: TextStyle( color: Theme.of(context).colorScheme.primary),
        ),
        content: MyTextfield(
          hintText: "nombre", 
          controller: classnameController
        ),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.of(context).pop(false),
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              'Cancelar', 
              style: TextStyle( color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
          MaterialButton(
            onPressed: () {
              name = classnameController.text;
              Navigator.of(context).pop(true);
            },
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              'Guardar', 
              style: TextStyle( color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
        ],
      );
      },
    ) ?? false;

    // If user confirmed, proceed with creation
    if (confirm) {
      try {
        await storageService.createClassroom(name);
      } catch(ex){
        if(!context.mounted) return;
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ex.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(title: "Aulas 2025"),
      floatingActionButtonLocation: FloatingActionButtonLocation.centerFloat,
      floatingActionButton: FloatingActionButton(
        backgroundColor: Theme.of(context).colorScheme.primary,
        foregroundColor: Theme.of(context).colorScheme.inversePrimary,
        onPressed: () => addClassroom(context),
        child: const Icon(Icons.add, size: 40,),
      ),
      drawer: const MyDrawer(),
      body: buildClassroomsList(),
    );
  }

  Widget buildClassroomsList(){
    return StreamBuilder(
      stream: storageService.getClassroomsStream(), 
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error..");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child:  CircularProgressIndicator(
            strokeWidth: 10,
          ));
        }
        return ListView(
          padding: const EdgeInsets.only(top: 10),
          children: snapshot.data!.map<Widget>((classData) => 
            buildClassListItem(classData, context)).toList(),
        );
      }
    );
  }

  Widget buildClassListItem(Map<String, dynamic> classData, BuildContext context){
    return ClassroomTile(
      text: classData["name"],
      tapDelete: () {
        storageService.deleteClassroom(classData["docId"]);
      },
    );
  }
}