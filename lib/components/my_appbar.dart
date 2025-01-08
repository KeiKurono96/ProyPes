import 'package:flutter/material.dart';

class MyAppbar extends StatelessWidget implements PreferredSizeWidget {
  final String title;
  const MyAppbar({
    super.key, required this.title
  });

  @override
  Widget build(BuildContext context) {
    return AppBar(
      backgroundColor: const Color.fromRGBO(0, 0, 0, 0),
      foregroundColor: Theme.of(context).colorScheme.primary,
      elevation: 0,
      title: Text(title),
      centerTitle: true,
    );
  }

  @override
  Size get preferredSize => const Size.fromHeight(kToolbarHeight);
}