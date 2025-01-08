import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/services/storage/storage_service.dart';

class CitationsPage extends StatelessWidget {
  final String userRole;

  const CitationsPage({super.key, required this.userRole});

  @override
  Widget build(BuildContext context) {
    final StorageService storageService = StorageService();
    
    return Scaffold(
      appBar: const MyAppbar(title: "Citaciones"),
      body: StreamBuilder(
        stream: storageService.getCitations(userRole),
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
            return Center(child: Text('No hay citaciones por el momento.', style: TextStyle(
              color: Theme.of(context).colorScheme.primary
            ),));
          }

          final citations = snapshot.data!.docs;

          return ListView.builder(
            itemCount: citations.length,
            itemBuilder: (context, index) {
              var citation = citations[index];
              String title = citation['title'];
              String message = citation['text'];
              Timestamp timestamp = citation['createdAt'];
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
                      title: Text(title, style: TextStyle(
                        color: Theme.of(context).colorScheme.primary
                      ),),
                      subtitle: Text(message, style: TextStyle(
                        color: Theme.of(context).colorScheme.primary
                      ),),
                      trailing: Text(
                        '${createdAt.day}-${createdAt.month}-${createdAt.year}',
                        style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                      ),
                      onTap: () {
                        // Handle tap on citation (optional)
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