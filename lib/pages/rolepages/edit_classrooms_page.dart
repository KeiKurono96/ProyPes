import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/my_button.dart';

class EditClassroomsPage extends StatefulWidget {
  final String uid;
  final String email;
  final List<dynamic>? aulas;

  const EditClassroomsPage({
    super.key, 
    required this.uid, 
    required this.email,
    this.aulas,
  });

  @override
  State<EditClassroomsPage> createState() => _EditClassroomsPageState();
}

class _EditClassroomsPageState extends State<EditClassroomsPage> {
  String concat = '';

  List<String> classroomNames = [];
  String? selectedClassroom = '1A';
  final List<String> _selectedClassrooms = [];

  @override
  void initState(){
    super.initState();
    getClassroomNames();    
    concat = concatenateList(widget.aulas);
  }

  Future<void> getClassroomNames() async {
    try {
      final QuerySnapshot<Map<String, dynamic>> snapshot =
        await FirebaseFirestore.instance.collection('Classrooms').orderBy('name').get();

      setState(() {
        classroomNames = snapshot.docs.map((doc) => doc['name'] as String).toList();
      });
    } catch (e) {
      if(!mounted) return;
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text(e.toString())));
    }
  }

  String concatenateList(List<dynamic>? list) {
    if (list != null) {
      return list.map((item) => item.toString()).join(', '); 
    } else {
      return 'No hay aulas asignadas aún';
    }    
  }

  void updateClassrooms() async {
    try {
      await FirebaseFirestore.instance.collection("Users").doc(widget.uid).update({
        'aulas': _selectedClassrooms,
      });
      if(!mounted) return;
      Navigator.pop(context);
      Navigator.pop(context);
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Se actualizaron las aulas para el usuario ${widget.email}")));
    } catch (e) {
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Error actualizando las aulas: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(title: "Editar Aulas"),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        children: [
          Text("Aulas asignadas al usuario: ${widget.email} :", style: TextStyle(
            color: Theme.of(context).colorScheme.primary, fontSize: 20,
          ), textAlign: TextAlign.center,),
          SizedBox(height: 20,),
          Text(concat, style: TextStyle(
            color: Theme.of(context).colorScheme.primary, fontSize: 20
          ), textAlign: TextAlign.center,),
          SizedBox(height: 20,),
          Text("Designar nueva lista de aulas :", style: TextStyle(
            color: Theme.of(context).colorScheme.primary, fontSize: 20,
          ), textAlign: TextAlign.center,),
          SizedBox(height: 10,),
          Row(
            children: [
              const SizedBox(width: 20,),
              Text(
                "Aulas :",
                style: TextStyle(color: Theme.of(context).colorScheme.primary,),
              ),
              const SizedBox(width: 20,),
              DropdownButton<String>( 
                padding: const EdgeInsets.symmetric(vertical: 10),    
                value: selectedClassroom,
                items: classroomNames
                  .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.inversePrimary,
                    ),),
                  )).toList(),
                // onChanged: (classroomNames) => setState(() => selectedClassroom = classroomNames),
                onChanged: (String? newValue) {
                  setState(() {
                    if (newValue != null) {
                      if (_selectedClassrooms.contains(newValue)) {
                        _selectedClassrooms.remove(newValue);
                      } else {
                        _selectedClassrooms.add(newValue);
                      }                        
                    }
                  });
                },
              ),
              const SizedBox(width: 10,),
              Text(
                ': ${_selectedClassrooms.join(', ')}',
                style: TextStyle(
                  fontWeight: FontWeight.bold,
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 20,
                ),
              ),
            ],
          ),
          SizedBox(height: 20,),
          MyButton(text: "Actualizar Aulas", onTap: updateClassrooms)
        ],
      ),
    );
  }
}