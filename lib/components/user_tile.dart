import 'package:flutter/material.dart';

class UserTile extends StatelessWidget {
  final String text;
  final String role;
  final void Function()? onTap;
  final int unreadMessagesCount;

  const UserTile({
    super.key, 
    required this.text, 
    required this.role,
    required this.onTap, 
    this.unreadMessagesCount = 0,     
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
          mainAxisAlignment: MainAxisAlignment.spaceBetween,
          children: [
            Row(
              children: [
                buildIconItem(),
                const SizedBox(width: 15,),
                Text(text),
              ],
            ),
            unreadMessagesCount > 0 ? Padding(
              padding: const EdgeInsets.only(right: 20),
              child: Container(
                decoration: BoxDecoration(
                  shape: BoxShape.circle,
                  color: Theme.of(context).colorScheme.tertiary,
                ),
                padding: const EdgeInsets.all(10),
                child: Text(
                  unreadMessagesCount.toString(),
                  style: TextStyle(
                    color: Theme.of(context).colorScheme.inversePrimary,
                    fontWeight: FontWeight.bold
                  ),
                ),
              ),
            ) : Container(),
          ],
        ),
      ),
    );
  }

  Widget buildIconItem(){
    switch (role) {
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