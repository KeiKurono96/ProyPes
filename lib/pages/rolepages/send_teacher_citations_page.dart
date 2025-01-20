import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/my_button.dart';
import 'package:prueba_chat/components/my_textfield.dart';
import 'package:prueba_chat/services/storage/storage_service.dart';

class SendTeacherCitationsPage extends StatefulWidget {
  final List<String> aulas;
  final String primerAula;

  const SendTeacherCitationsPage({super.key, required this.aulas, required this.primerAula});

  @override
  State<SendTeacherCitationsPage> createState() => _SendTeacherCitationsPageState();
}

class _SendTeacherCitationsPageState extends State<SendTeacherCitationsPage> {
  StorageService storageService = StorageService();

  TextEditingController titleController = TextEditingController();
  TextEditingController citationController = TextEditingController();

  String selectedItem = '';
  
  @override
  void initState() {
    super.initState();
    selectedItem = widget.primerAula;
  }

  void generateCitation(BuildContext context) async {

    if (titleController.text != "" && citationController.text != "") {
      try {
        await storageService.createTeacherCitation(
          titleController.text, 
          citationController.text, 
          selectedItem,
        );
        if (!context.mounted) return;
        Navigator.pop(context);
      } catch (e){
        showDialog(
          context: context, 
          builder: (context) => AlertDialog(
            title: Text(e.toString(), style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),),
          ),
        );        
      }
    } else {
      showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          title: Text("Debe llenar el título y el mensaje", style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),),
        ),
      );
    }    
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppbar(title: "Enviar Citaciones"),
      body: ListView(
        children: [
          const SizedBox(height: 30,),
          MyTextfield(hintText: "Título", controller: titleController,),
          const SizedBox(height: 20,),
          MyTextfield(hintText: "Citación", 
            controller: citationController, maxLines: null,),
          const SizedBox(height: 20,),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              Text(
                "Citar aula :",
                style: TextStyle(color: Theme.of(context).colorScheme.primary,),
              ),
              const SizedBox(width: 20,),
              DropdownButton<String>( 
                padding: const EdgeInsets.symmetric(vertical: 10),    
                value: selectedItem,
                items: widget.aulas
                  .map((item) => DropdownMenuItem(
                    value: item,
                    child: Text(item, style: TextStyle(
                      fontSize: 20,
                      color: Theme.of(context).colorScheme.primary,
                    ),),
                  )).toList(),
                onChanged: (item) => setState(() => selectedItem = item!),
              ),
            ],
          ),
          const SizedBox(height: 20,),
          MyButton(text: "Generar", onTap: ()=> generateCitation(context)),
        ]
      ),
    );
  }
}