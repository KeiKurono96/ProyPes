import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/my_drawer.dart';
import 'package:prueba_chat/components/my_menu.dart';
import 'package:prueba_chat/pages/chatlist_page.dart';
import 'package:prueba_chat/pages/classrooms_page.dart';
import 'package:prueba_chat/pages/rolepages/list_users_page.dart';
import 'package:prueba_chat/pages/rolepages/create_user_page.dart';
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
            text: "Chat General",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ChatlistPage()
              )
            ),
          )     ,  
          MyMenu(
            text: "Creación de Usuarios",
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const CreateUserPage()
              )
            ),
          ),
          MyMenu(
            text: 'Edición de Usuarios',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ListUsersPage()
              )
            ),
          ),
          MyMenu(
            text: 'Enviar Citaciones',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const SendCitationsPage()
              )
            ),
          ),
          MyMenu(
            text: 'Aulas 2025',
            onPressed: () => Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ClassroomsPage()
              )
            ),
          ),
        ],
      ),
    );
  }
}