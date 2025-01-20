import 'package:flutter/material.dart';
import 'package:prueba_chat/services/auth/forgot_pass.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';
import 'package:prueba_chat/components/my_button.dart';
import 'package:prueba_chat/components/my_textfield.dart';

class LoginPage extends StatelessWidget {

  // final void Function()? onTap;

  LoginPage({super.key});

  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();

  void login(BuildContext context) async {
    final authService = AuthService();

    try{
      await authService.signInWithEP(
        _emailController.text,
        _pwController.text
      );
      if (!context.mounted) return;
    } catch(e){
      showDialog(
        context: context, 
        builder: (context) => AlertDialog(
          title: Text(e.toString(), style: TextStyle(
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
            Padding(
              padding: const EdgeInsets.all(10),
              child: Text(
                "Bienvenido a la aplicación del colegio Antonio José de Sucre",
                style: TextStyle(
                  color: Theme.of(context).colorScheme.primary,
                  fontSize: 25,
                ),
                textAlign: TextAlign.center,
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
            const SizedBox(height: 15,),
            Padding(
              padding: const EdgeInsets.only(right: 25),
              child: Align(
                alignment: Alignment.centerRight,
                child: InkWell(
                  onTap: () {
                    Navigator.push(context, MaterialPageRoute(
                      builder: (context) => ForgotPass()));
                  },
                  child: Text("Olvide mi contraseña", style: TextStyle(
                    color: Theme.of(context).colorScheme.primary),),
                ),
              ),
            ),
            const SizedBox(height: 15,),          
            MyButton(
              text: "Ingresar",
              onTap: ()=> login(context),
            ),
            // const SizedBox(height: 25,),
            // Row(
            //   mainAxisAlignment: MainAxisAlignment.center,
            //   children: [
            //     Text("¿Aún no tiene una cuenta? ",
            //       style: TextStyle(color: Theme.of(context).colorScheme.primary),
            //     ),
            //     GestureDetector(
            //       onTap: onTap,
            //       child: Text("Registrese",
            //         style: TextStyle(
            //           color: Theme.of(context).colorScheme.primary,
            //           fontWeight: FontWeight.bold,
            //         ),
            //       ),
            //     ),
            //   ],
            // ),
          ],
        ),
      ),
    );
  }
}