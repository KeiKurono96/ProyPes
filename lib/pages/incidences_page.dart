import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';
import 'package:prueba_chat/services/storage/storage_service.dart';

class IncidencesPage extends StatelessWidget {
  IncidencesPage({super.key});

  final StorageService storageService = StorageService();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {    
    return Scaffold(
      appBar: MyAppbar(title: "Incidencias Hijos"),
      body: StreamBuilder(
        stream: storageService.getIncidences(authService.getCurrentUser()!.uid),
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
            return Center(child: Text('Felicidades, no hay incidencias por el momento.', style: TextStyle(
              color: Theme.of(context).colorScheme.primary
            ),));
          }

          final excelReps = snapshot.data!.docs;

          return ListView.builder(
            itemCount: excelReps.length,
            itemBuilder: (context, index) {
              var excelRep = excelReps[index];
              String alumno = excelRep['alumno'];
              String mensaje = excelRep['mensaje'];
              Timestamp timestamp = excelRep['timestamp'];
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
                      title: Text(alumno, style: TextStyle(
                        color: Theme.of(context).colorScheme.primary
                      ),),
                      subtitle: Text(mensaje, style: TextStyle(
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