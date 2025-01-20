import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';
import 'package:prueba_chat/components/my_button.dart';
import 'package:prueba_chat/components/my_textfield.dart';

class CreateUserPage extends StatefulWidget {
  const CreateUserPage({super.key});

  @override
  State<CreateUserPage> createState() => _CreateUserPageState();
}

class _CreateUserPageState extends State<CreateUserPage> {
  final TextEditingController _emailController = TextEditingController();
  final TextEditingController _pwController = TextEditingController();
  final TextEditingController _confPwController = TextEditingController();

  List<String> items = ['Apoderado', 'Docente', 'Administrador'];
  String selectedItem = 'Apoderado';

  List<String> classroomNames = [];
  String? selectedClassroom = '1A';
  List<String> _selectedClassrooms = [];

  @override
  void initState() {
    super.initState();
    _getClassroomNames();
  }

  Future<void> _getClassroomNames() async {
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

  void register(BuildContext context) async {
    final auth = AuthService();

    if (_pwController.text == _confPwController.text) {
      try {
        String mailTrimmed = _emailController.text.trim();
        await auth.signUpWithEP(
          mailTrimmed, 
          _pwController.text,
          selectedItem,
          _selectedClassrooms,
        ); 
        if (!context.mounted) return;
        showDialog(
          context: context, 
          builder: (context) => AlertDialog(
            title: Text("Usuario creado, se ha iniciado sesion con ese usuario"),
          ),
        );
        _emailController.text = "";
        _pwController.text = "";
        _confPwController.text = "";
        _selectedClassrooms = [];
        setState(() { _selectedClassrooms; });
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
        title: const Text("Creación de Usuarios", style: TextStyle(
          fontSize: 25,
        ),),
        centerTitle: true,
      ),
      backgroundColor: Theme.of(context).colorScheme.surface,
      body: SingleChildScrollView(
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            const SizedBox(height: 20,),
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
              children: [
                const SizedBox(width: 30,),
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
            Row(
              children: [
                const SizedBox(width: 30,),
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
                Flexible(
                  child: Text(
                    ': ${_selectedClassrooms.join(', ')}',
                    style: TextStyle(
                      fontWeight: FontWeight.bold,
                      color: Theme.of(context).colorScheme.primary,
                      fontSize: 20,
                    ),
                  ),
                ),
              ],
            ),
            const SizedBox(height: 10,),
            MyButton(
              text: "Registrar Usuario",
              onTap: ()=> register(context),
            ),          
          ],
        ),
      ),
    );
  }
}