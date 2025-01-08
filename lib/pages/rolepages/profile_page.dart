import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/my_formtextfield.dart';
import 'package:prueba_chat/models/user.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';

class ProfilePage extends StatefulWidget {
  final UserProfile user;

  const ProfilePage({super.key, required this.user});

  @override
  State<ProfilePage> createState() => _ProfilePageState();
}

class _ProfilePageState extends State<ProfilePage> {
  final _formKey = GlobalKey<FormBuilderState>();
  final AuthService authService = AuthService();
  bool _isUpdating = false;
  bool isFormCleared = false;
  
  void updateData() async{
    setState(() {
      _isUpdating = true; // Show indicator
    });

    if (_formKey.currentState!.saveAndValidate()) {
      final data = _formKey.currentState!.value;

      final userToUpload = UserProfile(
        uid: widget.user.uid,
        email: widget.user.email,
        tipo: widget.user.tipo,
        nombres: data['nombres'],
        apellidos: data['apellidos'],
        sexo: data['sexo'],
        direccion: data['direccion'],
        telefono: data['telefono'],
      );

      try{
        await authService.updateSelfUser(widget.user.uid, userToUpload,);
        if(!mounted) return;
        Navigator.pop(context);
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Se actualizó tu perfil correctamente")),);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error de actualización de perfil: $e')),);
      }
    }

    setState(() {
      _isUpdating = false; // Hide indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppbar(title: "Perfil"),
      bottomNavigationBar: BottomAppBar(
        child: Wrap(
          alignment: WrapAlignment.spaceBetween,
          children: [
            ElevatedButton(
              onPressed: _isUpdating ? null : updateData, 
              child: _isUpdating 
                ? const CircularProgressIndicator()
                : const Text("Guardar")
            ),
            ElevatedButton(
              onPressed: isFormCleared ? null : () {
                setState(() { isFormCleared = !isFormCleared; });
                _formKey.currentState!.reset();
              },
              child: const Text("Reiniciar")
            ),
            ElevatedButton(
              onPressed: !isFormCleared ? null : () { 
                setState(() { isFormCleared = !isFormCleared; });
                _formKey.currentState!.reset();
              }, 
              child: const Text("Limpiar")
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FormBuilder(
          key: _formKey,
          initialValue: isFormCleared 
            ? {
              'email' : widget.user.email,
            } 
            : {
              'email' : widget.user.email,
              'nombres' : widget.user.nombres,
              'apellidos' : widget.user.apellidos,
              'sexo' : widget.user.sexo,
              'direccion' : widget.user.direccion,
              'telefono' : widget.user.telefono,
          },
          child: ListView(
            children: [
              MyFormtextfield(
                enabled: false,
                name: 'email',
                labelText: 'Correo',
              ),
              MyFormtextfield(                
                name: 'nombres',
                labelText: 'Nombres',
                suffix: IconButton(
                  icon: Icon(Icons.replay_outlined, color: Theme.of(context).colorScheme.primary,),
                  onPressed: () {
                    _formKey.currentState!.fields['email']?.reset();
                  },
                ),
              ),
              MyFormtextfield(
                name: 'apellidos',
                labelText: 'Apellidos',
                suffix: IconButton(
                  icon: Icon(Icons.replay_outlined, color: Theme.of(context).colorScheme.primary,),
                  onPressed: () {
                    _formKey.currentState!.fields['email']?.reset();
                  },
                ),
              ),
              FormBuilderRadioGroup(             
                name: 'sexo',
                decoration: InputDecoration(
                  labelText: 'Sexo',
                  labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                  enabledBorder: UnderlineInputBorder( borderSide: BorderSide(
                    color: Theme.of(context).colorScheme.primary),
                  ),
                ),
                // validator: FormBuilderValidators.compose(
                //   [FormBuilderValidators.required(errorText: 'Este campo no puede estar vacío')]
                // ),
                options: [
                  FormBuilderFieldOption( 
                    value: 'masculino', 
                    child: Text( 'masculino', style: TextStyle(color: Theme.of(context).colorScheme.primary),)
                  ),
                  FormBuilderFieldOption( 
                    value: 'femenino', 
                    child: Text( 'femenino', style: TextStyle(color: Theme.of(context).colorScheme.primary),)
                  )
                ]
              ),              
              MyFormtextfield(
                name: 'direccion',
                labelText: 'Direccion',
                suffix: IconButton(
                  icon: Icon(Icons.replay_outlined, color: Theme.of(context).colorScheme.primary,),
                  onPressed: () {
                    _formKey.currentState!.fields['email']?.reset();
                  },
                ),
              ),
              MyFormtextfield(
                name: 'telefono',
                labelText: 'Telefono',
                suffix: IconButton(
                  icon: Icon(Icons.replay_outlined, color: Theme.of(context).colorScheme.primary,),
                  onPressed: () {
                    _formKey.currentState!.fields['email']?.reset();
                  },
                ),
              ),
            ],
          ),
        )
      ),
    );
  }
}