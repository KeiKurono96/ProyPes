import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/my_drawer.dart';
import 'package:prueba_chat/components/my_menu.dart';
import 'package:prueba_chat/pages/chatlist_page.dart';
import 'package:prueba_chat/pages/citations_page.dart';
import 'package:prueba_chat/pages/rolepages/send_teacher_citations_page.dart';
import 'package:prueba_chat/pages/send_grades_page.dart';
import 'package:prueba_chat/pages/send_homework_page.dart';
import 'package:prueba_chat/pages/send_incidences_page.dart';
import 'package:prueba_chat/services/auth/role_provider.dart';
import 'package:prueba_chat/services/storage/storage_service.dart';

class TeachersPage extends StatelessWidget {
  const TeachersPage({super.key});

  @override
  Widget build(BuildContext context) {
    final userRole = Provider.of<UserRoleProvider>(context).role!;
    StorageService storageService = StorageService();
    List<String> aulas;
    String primerAula;
    
    return Scaffold(
      appBar: const MyAppbar(title: "MODO DOCENTE"),
      drawer: const MyDrawer(),
      body: ListView(
        children: [    
          MyMenu(
            text: "Chat General",
            onPressed: () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => ChatlistPage()
                )
              ),
          ),     
          MyMenu(
            text: "Enviar Calificaciones",
            onPressed: () =>
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SendGradesPage()
                )
              ),
          ),
          MyMenu(
            text: "Enviar Incidencias",
            onPressed: () => 
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SendIncidencesPage()
                )
              ),
          ),
          MyMenu(
            text: "Enviar Tareas",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => const SendHomeworkPage()
                )
              );
            }
          ),
          MyMenu(
            text: "Enviar Citaciones",
            onPressed: () async {
              aulas = await storageService.getUserStringClassrooms();
              primerAula = aulas[0];
              if (!context.mounted) return;
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => SendTeacherCitationsPage(aulas: aulas, primerAula: primerAula,)
                )
              );
            }
          ),
          MyMenu(
            text: "Seguimiento de Citaciones",
            onPressed: () {
              Navigator.push(
                context,
                MaterialPageRoute(
                  builder: (context) => CitationsPage(userRole: userRole,)
                )
              );
            },
          ),
        ],
      ),
    );
  }
}