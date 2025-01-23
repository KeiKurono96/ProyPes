import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/my_button.dart';
import 'package:prueba_chat/components/my_textfield.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';

class ForgotPass extends StatelessWidget {
  final TextEditingController _emailController = TextEditingController();

  ForgotPass({super.key});

  void sendResetPassLink(BuildContext context) async {
    final authService = AuthService();

    try{      
      await authService.sendPasswordResetLink(_emailController.text); 
      if (!context.mounted) return;   
      ScaffoldMessenger.of(context).showSnackBar(
        SnackBar(content: Text('Correo de Recuperación Enviado a ${_emailController.text}')),
      );
      Navigator.pop(context);
    } catch(e){
      showDialog(      
        context: context, 
        builder: (context) => AlertDialog(
          title: Text(e.toString()),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppbar(title: "Olvide mi Contraseña"),
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text("Ingresa tu correo para mandarte el correo de reinicio",
            style: TextStyle(color: Theme.of(context).colorScheme.primary),),
          const SizedBox(height: 20,),
          MyTextfield(hintText: "Ingresa tu correo", obscureText: false, 
            controller: _emailController, keyboardType: TextInputType.emailAddress,),
          const SizedBox(height: 20,),
          MyButton(text: "Enviar Correo de Reinicio", onTap: () {
            sendResetPassLink(context);
          }),
        ],
      ),
    );
  }
}