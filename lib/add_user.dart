import 'package:flutter/material.dart';
import 'package:flutter_application_2/api_handler.dart';
import 'package:flutter_application_2/model.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';

class AddUser extends StatefulWidget {
  const AddUser({super.key});

  @override
  State<AddUser> createState() => _AddUserState();
}

class _AddUserState extends State<AddUser> {
  final _formKey = GlobalKey<FormBuilderState>();
  ApiHandler apiHandler = ApiHandler();

  void addUser() async {
    if(_formKey.currentState!.saveAndValidate()){
      
      final data = _formKey.currentState!.value;
      final user = User(
        userId: 0, 
        email: data['email'], 
        password: data['password'],
        nombres: data['nombres'],
        apellidos: data["apellidos"],
        sexo: data['sexo'],
        direccion: data['direccion'],
        telefono: data['telefono'],
        tipo: data['tipo'],
      );

      await apiHandler.addUser(user: user);

      if (!mounted) return;
    Navigator.pop(context);
    } else {
      ScaffoldMessenger.of(context).showSnackBar(const SnackBar(
        content: Text('El formulario no es válido')));
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Crear Nuevo Usuario"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: MaterialButton(
        color: Colors.teal,
        textColor: Colors.white,
        padding: const EdgeInsets.all(10),
        onPressed: addUser,
        child: const Text('Agregar Usuario'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FormBuilder(
          key: _formKey,
          child: ListView(
            children: [
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(labelText: 'Email'),
                keyboardType: TextInputType.emailAddress,
                autovalidateMode: AutovalidateMode.onUserInteraction,
                validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.email(errorText: 'Este correo no es válido'), 
                    FormBuilderValidators.required()]
                ),
              ),
              const SizedBox(height: 10,),
              FormBuilderTextField(
                name: 'password',
                obscureText: true,
                decoration: const InputDecoration(labelText: 'Password'),
                validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required(errorText: 'Este campo no puede estar vacío')]
                ),
              ),
              const SizedBox(height: 10,),
              FormBuilderTextField(
                name: 'nombres',
                decoration: const InputDecoration(labelText: 'Nombres'),
                validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required(errorText: 'Este campo no puede estar vacío')]
                ),
              ),
              const SizedBox(height: 10,),
              FormBuilderTextField(
                name: 'apellidos',
                decoration: const InputDecoration(labelText: 'Apellidos'),
                validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required(errorText: 'Este campo no puede estar vacío')]
                ),
              ),
              const SizedBox(height: 10,),
              FormBuilderRadioGroup(
                name: 'sexo',
                decoration: const InputDecoration(labelText: 'Sexo'),
                validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required(errorText: 'Este campo no puede estar vacío')]
                ),
                options: const [
                  FormBuilderFieldOption(
                    value: 'f',
                    child: Text('Femenino'),
                  ),
                  FormBuilderFieldOption(
                    value: 'm',
                    child: Text('Masculino'),
                  ),
                ],
              ),              
              const SizedBox(height: 10,),
              FormBuilderDropdown<String>(
                name: 'tipo',
                decoration: InputDecoration(
                  labelText: 'Tipo',
                  suffix: IconButton(
                    icon: const Icon(Icons.close),
                    onPressed: () {
                      _formKey.currentState!.fields['tipo']
                          ?.reset();
                    },
                  ),
                ),
                validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required(errorText: 'Este campo no puede estar vacío')]
                ),
                items: const [
                  DropdownMenuItem(
                    value: 'apo',
                    child: Text('Apoderado'),
                  ),
                  DropdownMenuItem(
                    value: 'doc',
                    child: Text('Docente'),
                  ),
                  DropdownMenuItem(
                    value: 'adm',
                    child: Text('Administrador'),
                  ),
                ],
              ),
              const SizedBox(height: 10,),
              FormBuilderTextField(
                name: 'direccion',
                decoration: const InputDecoration(labelText: 'Direccion'),
              ),
              const SizedBox(height: 10,),
              FormBuilderTextField(
                name: 'telefono',
                decoration: const InputDecoration(labelText: 'Telefono'),
              ),
            ],
          ),
        )
      ),
    );
  }
}