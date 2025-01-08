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
    return Container(
      decoration: BoxDecoration(
        color: Theme.of(context).colorScheme.secondary,
        borderRadius: BorderRadius.circular(12)
      ),
      margin: const EdgeInsets.symmetric(vertical: 20, horizontal: 40),
      padding: const EdgeInsets.symmetric(vertical: 15, horizontal: 40),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Flexible(
            child: Text(
              text,
              style: TextStyle(
                fontWeight: FontWeight.w700,
                fontSize: 16,
                color: Theme.of(context).colorScheme.primary
              ),
            ),
          ),
          IconButton(
            iconSize: 30,
            onPressed: onPressed,
            icon: Icon(
              Icons.arrow_forward_rounded,
              color: Theme.of(context).colorScheme.primary,
            )
          )
        ],
      ),
    );
  }
}