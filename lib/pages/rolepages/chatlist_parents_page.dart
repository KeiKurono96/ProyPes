import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/user_tile.dart';
import 'package:prueba_chat/pages/chat_page.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';
import 'package:prueba_chat/services/chat/chat_service.dart';

class ChatlistParentsPage extends StatefulWidget {
  final List<dynamic> aulas;

  const ChatlistParentsPage({super.key, required this.aulas});

  @override
  State<ChatlistParentsPage> createState() => _ChatlistParentsPageState();
}

class _ChatlistParentsPageState extends State<ChatlistParentsPage> {
  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      appBar: MyAppbar(title: "Chats Disponibles"),
      body: buildUserList(),
    );
  }

  Widget buildUserList(){
    return StreamBuilder(
      stream: chatService.getUsersStreamExcBloPar(widget.aulas), 
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error..");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child:  CircularProgressIndicator(
            strokeWidth: 10,
          ));
        }
        return ListView(
          padding: const EdgeInsets.only(top: 10),
          children: snapshot.data!.map<Widget>((userData) => 
            buildUserListItem(userData, context)).toList(),
        );
      }
    );
  }

  Widget buildUserListItem(Map<String, dynamic> userData, BuildContext context){
    if (userData["email"] != authService.getCurrentUser()!.email) {
      return UserTile(
        unreadMessagesCount: userData['unreadCount'],
        email: userData["email"],
        role: userData["tipo"],
        name: userData["nombres"],
        lastname: userData["apellidos"],
        onTap: () async {
          // Mark All Messages As Read
          await chatService.markMessagesAsRead(userData['uid']);
          
          // Go to Chat Page
          if(context.mounted){
            Navigator.push(context, MaterialPageRoute(
            builder: (context) => ChatPage(
              recieverEmail: userData["email"],
              receiverId: userData["uid"],
            ),
          )).then((_) => setState(() {userData['unreadCount'];}));
          }
        },
      );
    } else {
      return Container();
    }
  }
}