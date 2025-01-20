import 'package:flutter/material.dart';

class EditUserTile extends StatelessWidget {
  final String text;
  final String role;
  final void Function()? onTap;

  const EditUserTile({
    super.key, 
    required this.text,
    required this.role, 
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
            buildIconItem(Theme.of(context).colorScheme.primary),
            const SizedBox(width: 15,),
            Text(text, style: TextStyle(color: Theme.of(context).colorScheme.primary),),
          ],
        ),
      ),
    );
  }

  Widget buildIconItem(Color iconColor){
    switch (role) {
      case 'Administrador':
        return Icon(Icons.admin_panel_settings, color: iconColor);
      case 'Docente':
        return Icon(Icons.co_present_outlined, color: iconColor);
      case 'Apoderado':
        return Icon(Icons.person_4, color: iconColor);
      default:
        return Icon(Icons.not_interested_sharp, color: iconColor);
    }
  }
}