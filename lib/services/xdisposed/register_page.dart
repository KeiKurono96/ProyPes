import 'package:flutter/material.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';
import 'package:prueba_chat/components/my_button.dart';
import 'package:prueba_chat/components/my_textfield.dart';

class RegisterPage extends StatefulWidget {
  final void Function()? onTap;

  const RegisterPage({super.key, required this.onTap});

  @override
  State<RegisterPage> createState() => _RegisterPageState();
}

class _RegisterPageState extends State<RegisterPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confPwController = TextEditingController();

  List<String> items = ['Apoderado', 'Docente',];

  String selectedItem = 'Apoderado';

  List<String> aulas = [];

  void register(BuildContext context) async {
    final auth = AuthService();

    if (_pwController.text == _confPwController.text) {
      try {
        await auth.signUpWithEP(
          _emailController.text, 
          _pwController.text,
          selectedItem,
          aulas
        ); 
        if (!context.mounted) return;
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
          title: Text("Las contraseñas no coinciden", style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            Padding(
              padding: const EdgeInsets.only(top: 50, bottom: 10),
              child: Image.asset(
                'assets/images/iconoajs.png',
                alignment: const Alignment(0, -0.5),            
              ),
            ),
            Text(
              "Creación de Cuenta",
              style: TextStyle(
                color: Theme.of(context).colorScheme.primary,
                fontSize: 30,
              ),
            ),
            const SizedBox(height: 30,),
            MyTextfield(
              controller: _emailController,
              keyboardType: TextInputType.emailAddress,
              obscureText: false,
              hintText: "Correo",
            ),
            const SizedBox(height: 20,),
            MyTextfield(
              controller: _pwController,
              obscureText: true,
              hintText: "Contraseña",
            ),
            const SizedBox(height: 20,),
            MyTextfield(
              controller: _confPwController,
              obscureText: true,
              hintText: "Confirmar Contraseña",
            ),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text(
                  "Tipo de usuario :",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary,),
                ),
                const SizedBox(width: 20,),
                DropdownButton<String>( 
                  padding: const EdgeInsets.symmetric(vertical: 10),    
                  value: selectedItem,
                  items: items
                    .map((item) => DropdownMenuItem(
                      value: item,
                      child: Text(item, style: TextStyle(
                        fontSize: 20,
                        color: Theme.of(context).colorScheme.inversePrimary,
                      ),),
                    )).toList(),
                  onChanged: (item) => setState(() => selectedItem = item!),
                ),
              ],
            ),
            MyButton(
              text: "Registrarse",
              onTap: ()=> register(context),
            ),
            const SizedBox(height: 25,),
            Row(
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Text("¿Ya tiene una cuenta? ",
                  style: TextStyle(color: Theme.of(context).colorScheme.primary),
                ),
                GestureDetector(
                  onTap: widget.onTap,
                  child: Text("Ingresar",
                    style: TextStyle(
                      color: Theme.of(context).colorScheme.primary,
                      fontWeight: FontWeight.bold,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }
}