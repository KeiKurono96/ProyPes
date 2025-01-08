// ignore_for_file: must_be_immutable

import 'package:flutter/material.dart';
import 'package:flutter_form_builder/flutter_form_builder.dart';

class MyFormtextfield extends StatefulWidget {
  Widget? suffix;
  bool enabled;
  bool obscureText;
  final String name;
  final String labelText;
  final TextInputType? keyboardType;
  final String? Function(String?)? validator;
  final TextEditingController? controller;
  AutovalidateMode? autovalidateMode = AutovalidateMode.disabled;

  MyFormtextfield({
    super.key,
    required this.name, 
    required this.labelText,
    this.controller,
    this.validator, 
    this.keyboardType, 
    this.autovalidateMode,
    this.obscureText = false,
    this.suffix,
    this.enabled = true,
  });

  @override
  State<MyFormtextfield> createState() => _MyFormtextfieldState();
}

class _MyFormtextfieldState extends State<MyFormtextfield> {

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
      child: FormBuilderTextField( 
        controller: widget.controller,   
        enabled: widget.enabled,     
        obscureText: widget.obscureText,    
        style: TextStyle(color: Theme.of(context).colorScheme.primary,),         
        name: widget.name,
        keyboardType: widget.keyboardType,
        autovalidateMode: widget.autovalidateMode,
        decoration: InputDecoration(
          suffix: widget.suffix,
          labelText: widget.labelText,
          labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary,),
          enabledBorder: UnderlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),        
          ),
        ),
        validator: widget.validator,
      ),
    );
  }
}