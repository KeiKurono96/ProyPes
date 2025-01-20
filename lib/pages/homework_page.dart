import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';
import 'package:prueba_chat/services/storage/storage_service.dart';

class HomeworkPage extends StatelessWidget {
  final List<dynamic>? aulas;

  const HomeworkPage({super.key, this.aulas});

  @override
  Widget build(BuildContext context) {
    final StorageService storageService = StorageService();
    final AuthService authService = AuthService();

    return Scaffold(
      appBar: MyAppbar(title: "Tareas por Aula"),
      body: StreamBuilder(
        stream: storageService.getHomework(authService.getCurrentUser()!.uid, aulas),
        builder: (context, snapshot) {

          if (snapshot.connectionState == ConnectionState.waiting) {
            return const Center(child: CircularProgressIndicator());
          }

          if (snapshot.hasError) {
            return Center(child: Text('Error: ${snapshot.error}', style: TextStyle(
              color: Theme.of(context).colorScheme.primary
            ),));
          }

          if (!snapshot.hasData || snapshot.data!.docs.isEmpty) {
            return Center(child: Text('No se han dejado tareas por el momento.', style: TextStyle(
              color: Theme.of(context).colorScheme.primary
            ),));
          }

          final excelHomework = snapshot.data!.docs;

          return ListView.builder(
            itemCount: excelHomework.length,
            itemBuilder: (context, index) {
              var excelHw = excelHomework[index];
              String aula = excelHw['aula'];
              String homework = excelHw['homework'];
              Timestamp timestamp = excelHw['timestamp'];
              DateTime createdAt = timestamp.toDate();

              return Column(
                children: [
                  Container(
                    decoration: BoxDecoration(
                      color: Theme.of(context).colorScheme.secondary,
                      borderRadius: BorderRadius.circular(4),
                      border: Border.all(
                      color: Theme.of(context).colorScheme.tertiary, 
                      style: BorderStyle.solid
                      ),
                    ),
                    child: ListTile(
                      title: Text(aula, style: TextStyle(
                        color: Theme.of(context).colorScheme.primary
                      ),),
                      subtitle: Text(homework, style: TextStyle(
                        color: Theme.of(context).colorScheme.primary
                      ),),
                      trailing: Text(
                        '${createdAt.day}-${createdAt.month}-${createdAt.year}',
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                      ),
                      onTap: () {
                        // Handle tap on report (optional)
                      },
                    ),
                  ),
                  const SizedBox(height: 10,)
                ],
              );
            },
          );
        },
      ),
    );
  }
}