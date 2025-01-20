import 'package:flutter/material.dart';

class MyMenu extends StatelessWidget {
  final void Function()? onPressed;
  final String text;

  const MyMenu({
    super.key, 
    this.onPressed, 
    required this.text
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onPressed,
      child: Container(
        alignment: Alignment.center,
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12)
        ),
        margin: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 30),
        child: Text(          
          text,
          textAlign: TextAlign.center,
          style: TextStyle(
            fontWeight: FontWeight.w700,
            fontSize: 16,
            color: Theme.of(context).colorScheme.primary
          ),
        ),
      ),
    );
  }
}