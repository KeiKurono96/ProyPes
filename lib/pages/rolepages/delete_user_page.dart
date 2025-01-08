import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';

class DeleteUserPage extends StatelessWidget {
  const DeleteUserPage({super.key});

  @override
  Widget build(BuildContext context) {
    return const Scaffold(
      appBar: MyAppbar(title: "Eliminar Usuarios"),
      body: Center(child: Text("Eliminar"),),
    );
  }
}