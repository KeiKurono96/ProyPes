import 'package:flutter/material.dart';

class EditUserTile extends StatelessWidget {
  final String text;
  final String text2;
  final void Function()? onTap;

  const EditUserTile({
    super.key, 
    required this.text,
    required this.text2, 
    required this.onTap,
  });

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        decoration: BoxDecoration(
          color: Theme.of(context).colorScheme.secondary,
          borderRadius: BorderRadius.circular(12),
        ),
        margin: const EdgeInsets.symmetric(vertical: 5, horizontal: 15),
        padding: const EdgeInsets.all(10),
        child: Row(
          children: [
            buildIconItem(),
            const SizedBox(width: 15,),
            Text(text),
          ],
        ),
      ),
    );
  }

  Widget buildIconItem(){
    switch (text2) {
      case 'Administrador':
        return const Icon(Icons.admin_panel_settings);
      case 'Docente':
        return const Icon(Icons.co_present_outlined);
      case 'Apoderado':
        return const Icon(Icons.person_4);
      default:
        return const Text('SIN ROL');
    }
  }
}