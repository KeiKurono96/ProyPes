import 'package:flutter/material.dart';

class MyTextfield extends StatelessWidget {
  final String hintText;
  final bool obscureText;
  final TextEditingController controller;
  final FocusNode? focusNode;
  final TextInputType? keyboardType;
  final int? maxLines;

  const MyTextfield({
    super.key, 
    required this.hintText, 
    required this.controller,
    this.obscureText = false, 
    this.focusNode, 
    this.keyboardType,
    this.maxLines = 1,
  });

  @override
  Widget build(BuildContext context) {    
    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 25),
      child: TextField(
        style: TextStyle(
          color: Theme.of(context).colorScheme.tertiary
        ),
        keyboardType: keyboardType,
        focusNode: focusNode,
        controller: controller,
        obscureText: obscureText,
        maxLines: maxLines,
        decoration: InputDecoration(
          enabledBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.tertiary),
          ),
          focusedBorder: OutlineInputBorder(
            borderSide: BorderSide(color: Theme.of(context).colorScheme.primary),
          ),
          fillColor: Theme.of(context).colorScheme.secondary,
          filled: true,
          hintText: hintText,
          hintStyle: TextStyle(
            color: Theme.of(context).colorScheme.primary,            
          ),
        ),
      ),
    );
  }
}