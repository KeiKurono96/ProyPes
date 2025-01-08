import 'package:flutter/material.dart';
import 'package:prueba_chat/components/edit_user_tile.dart';
import 'package:prueba_chat/components/my_drawer.dart';
import 'package:prueba_chat/pages/rolepages/edit_user_page.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';
import 'package:prueba_chat/services/chat/chat_service.dart';

class ListUsersPage extends StatefulWidget {
  const ListUsersPage({super.key});

  @override
  State<ListUsersPage> createState() => _ListUsersPageState();
}

class _ListUsersPageState extends State<ListUsersPage> {
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
        title: const Text("Lista de Usuarios"),
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
      stream: chatService.getUsersStream(), 
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
      return EditUserTile(
        text: userData["email"],
        text2: userData["tipo"],
        onTap: () {
          // say uid in snackbar
          if(context.mounted){
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => EditUserPage(
                id: userData["uid"],
                email: userData["email"],
                role: userData["tipo"],
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