import 'package:flutter/material.dart';
import 'package:flutter_application_2/api_handler.dart';
import 'package:flutter_application_2/main_page.dart';
import 'package:flutter_application_2/model.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class LoginPage extends StatefulWidget {
  const LoginPage({super.key});

  @override
  State<LoginPage> createState() => _LoginPageState();
}

class _LoginPageState extends State<LoginPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  ApiHandler apiHandler = ApiHandler();
  late List<User> data = [];
  var txtEmail = TextEditingController();
  var txtPassword = TextEditingController();

  void getData() async {
    data = await apiHandler.getUserData();
    setState(() {});
  }

  @override
  void initState() {
    getData();
    super.initState();
  }

  @override
  Widget build(BuildContext context) {
    final size = MediaQuery.of(context).size;
    return Scaffold(
      body: SizedBox(
        width: double.infinity,
        height: double.infinity,
        child: Stack(
          children: [
            Container(
              decoration: const BoxDecoration(
                  gradient: RadialGradient(colors: [
                Color.fromRGBO(224, 222, 231, 1),
                Color.fromRGBO(22, 32, 175, 1)
              ])),
              width: double.infinity,
              height: size.height * 0.4,
              child: Image.asset(
                'assets/images/iconoajs.png',
                alignment: const Alignment(0, -0.5),
              ),
            ),
            SingleChildScrollView(
              child: Column(
                children: [
                  const SizedBox(height: 250),
                  Container(
                    padding: const EdgeInsets.all(20),
                    margin: const EdgeInsets.symmetric(horizontal: 30),
                    width: double.infinity,
                    decoration: BoxDecoration(
                        color: Colors.white,
                        borderRadius: BorderRadius.circular(25),
                        boxShadow: const [
                          BoxShadow(
                            color: Colors.black12,
                            blurRadius: 15,
                            offset: Offset(0, 5),
                          )
                        ]),
                    child: Column(
                      children: [
                        const SizedBox(
                          height: 10,
                        ),
                        Text(
                          'Login',
                          style: Theme.of(context).textTheme.headlineMedium,
                        ),
                        const SizedBox(height: 30),
                        Container(
                          child: Form(
                            autovalidateMode:
                                AutovalidateMode.onUserInteraction,
                            child: Column(
                              children: [
                                TextFormField(
                                  key: _formKey,
                                  keyboardType: TextInputType.emailAddress,
                                  autocorrect: false,
                                  controller: txtEmail,
                                  decoration: const InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.deepPurple)),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.deepPurple,
                                              width: 2)),
                                      hintText: 'ejemplo@hotmail.com',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      labelText: 'Correo Electronico',
                                      prefixIcon:
                                          Icon(Icons.alternate_email_rounded)),
                                  validator: (value) {
                                    String pattern =
                                        r'^[a-zA-Z0-9.]+@[a-zA-Z0-9]+\.[a-zA-Z]+';
                                    RegExp regExp = RegExp(pattern);
                                    return regExp.hasMatch(value ?? '')
                                        ? null
                                        : 'El valor ingresado no es un correo';
                                  },
                                ),
                                const SizedBox(height: 30),
                                TextFormField(
                                  autocorrect: false,
                                  controller: txtPassword,
                                  decoration: const InputDecoration(
                                      enabledBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.deepPurple)),
                                      focusedBorder: UnderlineInputBorder(
                                          borderSide: BorderSide(
                                              color: Colors.deepPurple,
                                              width: 2)),
                                      hintText: '**********',
                                      hintStyle: TextStyle(color: Colors.grey),
                                      labelText: 'Contraseña',
                                      prefixIcon:
                                          Icon(Icons.lock_outline_rounded)),
                                  obscureText: true,
                                  // validator: (value) {
                                  //   return (value != null && value.length >= 6)
                                  //   ? null
                                  //   : 'La contraseña debe ser mayor o igual a los 6 caracteres';
                                  // },
                                ),
                                const SizedBox(height: 30),
                                MaterialButton(
                                  shape: RoundedRectangleBorder(
                                      borderRadius: BorderRadius.circular(10)),
                                  disabledColor: Colors.grey,
                                  color: Colors.yellow,
                                  child: Container(
                                    padding: const EdgeInsets.symmetric(
                                        horizontal: 80, vertical: 15),
                                    child: const Text(
                                      'Ingresar',
                                      style: TextStyle(color: Colors.black),
                                    ),
                                  ),
                                  onPressed: () {
                                    if (_formKey.currentState!.saveAndValidate()) {
                                      if (data.where((e) => e.email == txtEmail.text && e.password == txtPassword.text).isNotEmpty) 
                                      {
                                        Navigator.push(
                                          context,
                                          MaterialPageRoute(
                                              builder: (context) =>
                                                  const MainPage()),
                                        );
                                      } else {
                                        ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          content: Text('No existe ese usuario')));
                                      }
                                    } else {
                                      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
                                          content: Text('Datos inválidos')));
                                    }
                                  },
                                )
                              ],
                            ),
                          ),
                        )
                      ],
                    ),
                  ),
                  const SizedBox(height: 30),
                  const Text('Crear una nueva cuenta',
                      style:
                          TextStyle(fontSize: 15, fontWeight: FontWeight.bold))
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }
}
