import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/my_drawer.dart';
import 'package:prueba_chat/components/my_menu.dart';
import 'package:prueba_chat/pages/chatlist_page.dart';
import 'package:prueba_chat/pages/citations_page.dart';
import 'package:prueba_chat/pages/reports_page.dart';
import 'package:prueba_chat/services/auth/role_provider.dart';

class ParentsPage extends StatelessWidget {
  const ParentsPage({super.key});

  @override
  Widget build(BuildContext context) {    
    final userRole = Provider.of<UserRoleProvider>(context).role!;
    
    return Scaffold(
      appBar: const MyAppbar(title: "MODO APODERADO"),
      drawer: const MyDrawer(),
      body: Column(
        children: [ 
          MyMenu(
            text: "Ir al Modo Chateo",
            onPressed: () => 
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const ChatlistPage()
                )
              ),
          ),
          MyMenu(
            text: "Ir a Seguimiento de Reportes",
            onPressed: () => 
              Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => const ReportsPage()
              )
            ),
          ),
          MyMenu(
            text: "Ir a Seguimiento de Citaciones",
            onPressed: () => 
              Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => CitationsPage(userRole: userRole,)
              )
            ),
          ),  
        ],
      ),
    );
  }
}