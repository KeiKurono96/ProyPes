import 'package:flutter/material.dart';
import 'package:prueba_chat/services/chat/chat_service.dart';

class ChatBubble extends StatelessWidget {
  final String message;
  final bool isCurrentUser;
  final String messageId;
  final String userId;

  const ChatBubble({
    super.key,
    required this.message, 
    required this.isCurrentUser, 
    required this.messageId, 
    required this.userId,
  });

  // SHOW OPTIONS
  void _showOptions(BuildContext context, String messageId, String userId) {
    showModalBottomSheet(
      context: context, 
      builder: (context) {
        return SafeArea(
          child: Wrap(
            children: [
              ListTile(
                leading: Icon(Icons.flag, color: Theme.of(context).colorScheme.primary,),
                title: Text(
                  'Reportar',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary,),
                ),
                onTap: () {
                  Navigator.pop(context);
                  reportMessage(context, messageId, userId);
                },
              ),
              ListTile(
                leading: Icon(Icons.block, color: Theme.of(context).colorScheme.primary,),
                title: Text(
                  'Bloquear Usuario',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary,),
                ),
                onTap: () {
                  Navigator.pop(context);
                  blockUser(context, userId);
                },
              ),
              ListTile(
                leading: Icon(Icons.cancel, color: Theme.of(context).colorScheme.primary,),
                title: Text(
                  'Cancelar',
                  style: TextStyle(color: Theme.of(context).colorScheme.primary,),
                ),
                onTap: () => Navigator.pop(context),
              ),
            ],
          ),
        );
      },
    );
  }

  // REPORT MESSAGE
  void reportMessage(BuildContext context, String messageId, String userId){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text("Reportar Mensaje",style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),),
        content: Text("¿Estas seguro de reportar este mensaje?",style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: (){
              ChatService().reportUser(messageId, userId);
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Mensaje Reportado")));
            },
            child: const Text("Reportar"),
          )
        ],
      )
    );
  }

  // BLOCK USER
  void blockUser(BuildContext context, String userId){
    showDialog(
      context: context, 
      builder: (context) => AlertDialog(
        title: Text("Bloquear Usuario",style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),),
        content: Text("¿Estas seguro de bloquear a este usuario?",style: TextStyle(
          color: Theme.of(context).colorScheme.primary,
        ),),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text("Cancelar"),
          ),
          TextButton(
            onPressed: (){
              ChatService().blockUser(userId);
              Navigator.pop(context);
              Navigator.pop(context);
              ScaffoldMessenger.of(context)
                .showSnackBar(const SnackBar(content: Text("Usuario Bloqueado")));
            },
            child: const Text("Bloquear"),
          )
        ],
      )
    );
  }

  @override
  Widget build(BuildContext context) {

    // bool isDarkMode = Provider.of<ThemeProvider>(context,listen: false).isDarkMode;

    return GestureDetector(
      onLongPress: () {
        if (!isCurrentUser) {
          _showOptions(context, messageId, userId);
        }
      },
      child: Container(
        decoration: BoxDecoration(
          borderRadius:isCurrentUser 
            ? const BorderRadius.horizontal(left: Radius.circular(40))
            : const BorderRadius.horizontal(right: Radius.circular(40)),
          border: Border.all(
            style: BorderStyle.solid
          ),
          color: Colors.white
        ),
        padding: const EdgeInsets.all(10),
        margin: const EdgeInsets.symmetric(vertical: 2.5, horizontal: 25),
        child: Text(
          message, style: const TextStyle(
            color: Colors.black,
            fontStyle: FontStyle.italic,
            overflow: TextOverflow.ellipsis
          ),
        ),
      ),
    );
  }
}