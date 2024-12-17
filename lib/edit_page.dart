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
        id: widget.user.id,
        email: data['email'],
        password: data['password'],
      );
      
      response = await apiHandler.updateUser(id: widget.user.id, user: user);
    }
    if(!mounted) return;
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text("Edit Page"),
        centerTitle: true,
        backgroundColor: Colors.teal,
        foregroundColor: Colors.white,
      ),
      bottomNavigationBar: MaterialButton(
        color: Colors.teal,
        textColor: Colors.white,
        padding: const EdgeInsets.all(10),
        onPressed: updateData,
        child: const Text('Update'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(10),
        child: FormBuilder(
          key: _formKey,
          initialValue: {
            'email' : widget.user.email,
            'password' : widget.user.password
          },
          child: Column(
            children: [
              FormBuilderTextField(
                name: 'email',
                decoration: const InputDecoration(labelText: 'Email'),
                validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required()]
                ),
              ),
              const SizedBox(height: 10,),
              FormBuilderTextField(
                name: 'password',
                decoration: const InputDecoration(labelText: 'Password'),
                validator: FormBuilderValidators.compose(
                  [FormBuilderValidators.required()]
                ),
              )
            ],
          ),
        )
      )
    );
  }
}