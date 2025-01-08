import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/user_tile.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';
import 'package:prueba_chat/services/chat/chat_service.dart';

class BlockedUsersPage extends StatelessWidget {
  BlockedUsersPage({super.key});

  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  void showUnblockBox(BuildContext context, String userId){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text("Desbloquear Usuariio",style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),),
        content: Text("¿Estás seguro de desbloquear a este usuario?",style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: () {
              chatService.unblockUser(userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Usuario Desbloqueado")));
            },
            child: const Text("Desbloquear"),
          ),
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {
    String userId = authService.getCurrentUser()!.uid;

    return Scaffold(
      appBar: const MyAppbar(title: "Usuarios Bloqueados"),
      body: StreamBuilder<List<Map<String,dynamic>>>(
        stream: chatService.getBlockedUsersStream(userId),
        builder: (context, snapshot) {

          if(snapshot.hasError){
            return const Center(
              child: Text("Error loading.."),
            );
          }

          final blockedUsers = snapshot.data ?? [];

          if(blockedUsers.isEmpty){
            return const Center(
              child: Text("No existen usuarios bloqueados"),
            );
          }

          return ListView.builder(
            itemCount: blockedUsers.length,
            itemBuilder: (context, index) {
              final user = blockedUsers[index];
              return UserTile(
                text: user["email"],
                role: user["tipo"],
                onTap: () => showUnblockBox(context, user['uid']),
              );
            },
          );
        },
      ),
    );
  }
}