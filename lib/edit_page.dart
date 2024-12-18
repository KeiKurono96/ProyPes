import 'package:flutter/material.dart';
import 'package:flutter_application_2/api_handler.dart';
import 'package:flutter_application_2/model.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:http/http.dart' as http2;

class EditPage extends StatefulWidget {
  final User user;
  const EditPage({super.key, required this.user});

  @override
  State<EditPage> createState() => _EditPageState();
}

class _EditPageState extends State<EditPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  ApiHandler apiHandler = ApiHandler();
  late http2.Response response;

  void updateData() async{
    if(_formKey.currentState!.saveAndValidate()){
      final data = _formKey.currentState!.value;

      final user = User(
        userId: widget.user.userId,
        email: data['email'],
        password: data['password'],
        nombres: data['nombres'],
        apellidos: data["apellidos"],
        sexo: data['sexo'],
        direccion: data['direccion'],
        telefono: data['telefono'],
        tipo: data['tipo'],
      );
      
      response = await apiHandler.updateUser(id: widget.user.userId, user: user);

      if(!mounted) return;
      Navigator.pop(context);
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Modificar Usuario"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: MaterialButton(
        color: Colors.teal,
        textColor: Colors.white,
        padding: const EdgeInsets.all(10),
        onPressed: updateData,
        child: const Text('Modificar'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'email' : widget.user.email,
            'password' : widget.user.password,
            "nombres": widget.user.nombres,
            "apellidos": widget.user.apellidos,
            "sexo": widget.user.sexo,
            "direccion": widget.user.direccion,
            "telefono": widget.user.telefono,
            "tipo": widget.user.tipo,
          },
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
                decoration: const InputDecoration(labelText: 'Password'),
                obscureText: true,
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
      )
    );
  }
}