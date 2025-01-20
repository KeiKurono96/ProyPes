import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';
import 'package:form_builder_validators/form_builder_validators.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/my_button.dart';
import 'package:prueba_chat/components/my_formtextfield.dart';
import 'package:prueba_chat/pages/rolepages/edit_classrooms_page.dart';
import 'package:prueba_chat/pages/rolepages/edit_password_page.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';

class EditUserPage extends StatefulWidget {
  final String id;
  final String email;
  final String role;
  final List<dynamic>? aulas;

  const EditUserPage({
    super.key, 
    required this.id, 
    required this.email, 
    required this.role, 
    this.aulas,
  });

  @override
  State<EditUserPage> createState() => _EditUserPageState();
}

class _EditUserPageState extends State<EditUserPage> {
  final _formKey = GlobalKey<FormBuilderState>();
  AuthService authService = AuthService();
  bool _isUpdating = false; // Track function updating state
  bool _isDeleting = false; // Track function deleting state

  void deleteThisUser(BuildContext context) async{
    setState(() {
      _isDeleting = true; // Show indicator
    });
    bool confirm = await showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
        title: Text(
          "Confirmar Eliminación de Usuario",
          style: TextStyle( color: Theme.of(context).colorScheme.primary),
        ),
        content: Text(
          "¿Estás seguro de eliminar al usuario ${widget.email} permanentemente?",
          style: TextStyle( color: Theme.of(context).colorScheme.primary),
        ),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.of(context).pop(false),
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              'Cancelar', 
              style: TextStyle( color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
          MaterialButton(
            onPressed: () => Navigator.of(context).pop(true),
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              'ELIMINAR', 
              style: TextStyle( color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
        ],
      );
      },
    ) ?? false;

    // If user confirmed, proceed with deletion
    if (confirm) {
      try {
        await authService.deleteUser(widget.id);  
        if(!context.mounted) return;                  
        Navigator.pop(context);
        ScaffoldMessenger.of(context)
          .showSnackBar(const SnackBar(content: Text("Usuario eliminado con éxito")));
      } catch(ex){
        if(!context.mounted) return;
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ex.toString())));
      }
    }
    setState(() {
      _isDeleting = false; // Hide indicator
    });
  }

  void updateData() async{
    setState(() {
      _isUpdating = true; // Show indicator
    });

    if(_formKey.currentState!.saveAndValidate()){
      try{
        final formData = _formKey.currentState!.value;

        await authService.changeUserEmail(
          widget.id, 
          formData['email']
        );

        await authService.updateUser(
          widget.id, 
          formData['tipo'],
        );
        
        if(!mounted) return;
        Navigator.pop(context);
        ScaffoldMessenger.of(context).showSnackBar(
          const SnackBar(content: Text("Se actualizó el usuario correctamente")),);
      } catch (e) {
        ScaffoldMessenger.of(context).showSnackBar(
          SnackBar(content: Text('Error: $e')),);
      }      
    }

    setState(() {
      _isUpdating = false; // Hide indicator
    });
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppbar(title: "Edición de Usuario"),
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
              onPressed: () { _formKey.currentState!.reset(); }, 
              child: const Text("Reiniciar")
            ),
            ElevatedButton(
              onPressed: () { _isDeleting ? null : deleteThisUser(context); } , 
              child: _isDeleting
                ? const CircularProgressIndicator()
                : const Text("Eliminar")
            ),
          ],
        ),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'id' : widget.id,
            'email' : widget.email,
            'tipo': widget.role,
          },
          child: ListView(
            children: [
              MyFormtextfield(
                enabled: false,
                name: 'id',
                labelText: 'Identificador',
              ),
              MyFormtextfield(
                name: 'email',
                labelText: 'Correo',
                autovalidateMode: AutovalidateMode.always,
                keyboardType: TextInputType.emailAddress,
                suffix: IconButton(
                  icon: Icon(Icons.replay_outlined, color: Theme.of(context).colorScheme.primary,),
                  onPressed: () {
                    _formKey.currentState!.fields['email']
                        ?.reset();
                  },
                ),                
                validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required(errorText: 'Este campo no puede estar vacío'),
                    FormBuilderValidators.email(errorText: 'Este correo no es válido')],               
                ),
              ),
              Padding(
                padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
                child: FormBuilderDropdown<String>(
                  dropdownColor: Theme.of(context).colorScheme.inversePrimary,
                  name: 'tipo',
                  decoration: InputDecoration(
                    labelText: 'Tipo',
                    labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary,),
                    suffix: IconButton(
                      icon: Icon(Icons.replay_outlined, color: Theme.of(context).colorScheme.primary,),
                      onPressed: () {
                        _formKey.currentState!.fields['tipo']
                            ?.reset();
                      },
                    ),
                    enabledBorder: UnderlineInputBorder(
                      borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),        
                    )
                  ),
                  validator: FormBuilderValidators.compose(
                    [FormBuilderValidators.required(errorText: 'Este campo no puede estar vacío')]
                  ),
                  items: [
                    DropdownMenuItem(
                      value: 'Apoderado',
                      child: Text('Apoderado', style: TextStyle(color: Theme.of(context).colorScheme.primary,),),
                    ),
                    DropdownMenuItem(
                      value: 'Docente',
                      child: Text('Docente', style: TextStyle(color: Theme.of(context).colorScheme.primary,),),
                    ),
                    DropdownMenuItem(
                      value: 'Administrador',
                      child: Text('Administrador', style: TextStyle(color: Theme.of(context).colorScheme.primary,),),
                    ),
                  ],
                ),
              ),
              SizedBox(height: 40,),
              MyButton(text: "Editar Aulas", onTap: (){
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => EditClassroomsPage(uid: widget.id, email: widget.email, aulas: widget.aulas,),
                ));
              }),
              SizedBox(height: 30,),
              MyButton(text: "Editar Contraseña", onTap: (){
                Navigator.push(context, MaterialPageRoute(
                  builder: (context) => EditPasswordPage(uid: widget.id,),
                ));
              }),
            ],
          ),
        )
      ),
    );
  }
}