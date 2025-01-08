import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/my_drawer.dart';
import 'package:prueba_chat/components/my_menu.dart';
import 'package:prueba_chat/pages/chatlist_page.dart';
import 'package:prueba_chat/pages/rolepages/list_users_page.dart';
import 'package:prueba_chat/pages/rolepages/new_admin_page.dart';
import 'package:prueba_chat/pages/send_citations_page.dart';

class AdminsPage extends StatefulWidget {
  const AdminsPage({super.key});

  @override
  State<AdminsPage> createState() => _AdminsPageState();
}

class _AdminsPageState extends State<AdminsPage> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppbar(title: "MODO ADMINISTRADOR"),
      drawer: const MyDrawer(),
      body: ListView(
        children: [                    
          MyMenu(
            text: "Ir al Modo Chateo",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatlistPage()
              )
            ),
          )     ,  
          MyMenu(
            text: "Ir a Creación de Usuarios",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const NewAdminPage()
              )
            ),
          ),
          MyMenu(
            text: 'Ir a Edición de Usuarios',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ListUsersPage()
              )
            ),
          ),
          MyMenu(
            text: 'Ir a Envío de Citaciones',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SendCitationsPage()
              )
            ),
          ),
        ],
      ),
    );
  }
}