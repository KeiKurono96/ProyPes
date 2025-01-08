import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_drawer.dart';
import 'package:prueba_chat/components/user_tile.dart';
import 'package:prueba_chat/pages/chat_page.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';
import 'package:prueba_chat/services/chat/chat_service.dart';

class ChatlistPage extends StatefulWidget {
  const ChatlistPage({super.key});

  @override
  State<ChatlistPage> createState() => _ChatlistPageState();
}

class _ChatlistPageState extends State<ChatlistPage> {

  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();

  void goBack(){
    Navigator.pop(context);
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      appBar: AppBar(
        backgroundColor: Colors.transparent,
        foregroundColor: Theme.of(context).colorScheme.primary,
        elevation: 0,
        title: const Text("Lista de Chats Disponibles"),
        centerTitle: true,
        actions: [IconButton(
          onPressed: goBack, 
          icon: const Icon(Icons.backspace_rounded)
          ),
          const SizedBox(width: 20,)
        ]
      ),
      drawer: const MyDrawer(),
      body: buildUserList(),
    );
  }

  Widget buildUserList(){
    return StreamBuilder(
      stream: chatService.getUsersStreamExcludingBlocked(), 
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
        text: userData["email"],
        role: userData["tipo"],
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