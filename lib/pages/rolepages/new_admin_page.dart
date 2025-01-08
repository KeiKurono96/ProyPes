import 'package:flutter/material.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';
import 'package:prueba_chat/components/my_button.dart';
import 'package:prueba_chat/components/my_textfield.dart';

class NewAdminPage extends StatefulWidget {
  const NewAdminPage({super.key});

  @override
  State<NewAdminPage> createState() => _NewAdminPageState();
}

class _NewAdminPageState extends State<NewAdminPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confPwController = TextEditingController();

  List<String> items = ['Apoderado', 'Docente', 'Administrador'];

  String? selectedItem = 'Administrador';

  void register(BuildContext context) async {
    final auth = AuthService();

    if (_pwController.text == _confPwController.text) {
      try {
        await auth.signUpWithEP(
          _emailController.text, 
          _pwController.text,
          selectedItem,
        ); 
        if (!context.mounted) return;
      } catch (e){
        showDialog(
          context: context, 
          builder: (context) => AlertDialog(
            title: Text(e.toString()),
          ),
        );
        
      }
    } else {
      showDialog(
        context: context, 
        builder: (context) => const AlertDialog(
          title: Text("Las contraseñas no coinciden"),
        ),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: const Text("Creación de Usuarios Admin", style: TextStyle(
          fontSize: 25,
        ),),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Image.asset(
            'assets/images/iconoajs.png',
            alignment: const Alignment(0, -0.5),            
          ),
          const SizedBox(height: 30,),
          MyTextfield(
            controller: _emailController,
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
                onChanged: (item) => setState(() => selectedItem = item),
              ),
            ],
          ),
          MyButton(
            text: "Registrarse",
            onTap: ()=> register(context),
          ),          
        ],
      ),
    );
  }
}