import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/my_button.dart';
import 'package:prueba_chat/components/my_textfield.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';

class EditPasswordPage extends StatefulWidget {
  final String uid;  

  const EditPasswordPage({super.key, required this.uid});

  @override
  State<EditPasswordPage> createState() => _EditPasswordPageState();
}

class _EditPasswordPageState extends State<EditPasswordPage> {
  TextEditingController pwController = TextEditingController();
  AuthService authService = AuthService();

  void updatePassword() async {
    try {
      if (pwController.text.length >= 6){
        await authService.changeUserPassword(
        widget.uid, 
        pwController.text
        );
        if(!mounted) return;
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("Se actualizó la contraseña correctamente")));
      } else {
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text("La contraseña debe tener al menos 6 caracteres")));
      }      
    } on Exception catch (e) {
      ScaffoldMessenger.of(context)
        .showSnackBar(SnackBar(content: Text("Error actualizando la contraseña: $e")));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: MyAppbar(title: "Editar Contraseña"),
      body: ListView(
        padding: EdgeInsets.symmetric(horizontal: 15, vertical: 20),
        children: [
          Text("Nota: Solo usar esta opción en casos extremos como cuando el usuario perdió acceso a su correo", style: TextStyle(
            color: Theme.of(context).colorScheme.primary, fontSize: 20,
          ), textAlign: TextAlign.center,),
          SizedBox(height: 30,),
          MyTextfield(hintText: 'Nueva Contraseña', controller: pwController),
          SizedBox(height: 30,),
          MyButton(text: "Actualizar Contraseña", onTap: updatePassword),
        ]
      )
    );
  }
}