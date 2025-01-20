import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/my_drawer.dart';
import 'package:prueba_chat/components/my_menu.dart';
import 'package:prueba_chat/pages/rolepages/chatlist_parents_page.dart';
import 'package:prueba_chat/pages/citations_page.dart';
import 'package:prueba_chat/pages/grades_page.dart';
import 'package:prueba_chat/pages/homework_page.dart';
import 'package:prueba_chat/pages/incidences_page.dart';
import 'package:prueba_chat/pages/rolepages/teacher_citations_page.dart';
import 'package:prueba_chat/services/auth/role_provider.dart';
import 'package:prueba_chat/services/storage/storage_service.dart';

class ParentsPage extends StatelessWidget {
  const ParentsPage({super.key});

  @override
  Widget build(BuildContext context) {    
    final userRole = Provider.of<UserRoleProvider>(context).role!;
    final StorageService storageService = StorageService();
    List<dynamic> userClassrooms = [];
    
    return Scaffold(
      appBar: const MyAppbar(title: "MODO APODERADO"),
      drawer: const MyDrawer(),
      body: ListView(
        children: [ 
          MyMenu(
            text: "Chat Aulas",
            onPressed: () async {
              userClassrooms = await storageService.getUserClassrooms();
              if(!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatlistParentsPage(aulas: userClassrooms,)
                )
              );
            }
          ), 
          MyMenu(
            text: "Seguimiento de Calificaciones",
            onPressed: () => 
              Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => GradesPage()
              )
            ),
          ),
          MyMenu(
            text: "Seguimiento de Incidencias",
            onPressed: () => 
              Navigator.push(
              context,
              MaterialPageRoute(
                builder: (context) => IncidencesPage()
              )
            ),
          ),
          MyMenu(
            text: "Seguimiento de Tareas",
            onPressed: () async {
              userClassrooms = await storageService.getUserClassrooms();
              if(!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => HomeworkPage(aulas: userClassrooms,)
                )
              );
            }
          ),
          MyMenu(
            text: "Citaciones de Aula",
            onPressed: () async {
              userClassrooms = await storageService.getUserClassrooms();
              if(!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => TeacherCitationsPage(aulas: userClassrooms,)
                )
              );
            }
          ),
          MyMenu(
            text: "Citaciones de I.E.",
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