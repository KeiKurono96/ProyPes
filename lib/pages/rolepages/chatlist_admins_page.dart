import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/user_tile.dart';
import 'package:prueba_chat/pages/chat_page.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';
import 'package:prueba_chat/services/chat/chat_service.dart';

class ChatlistAdminsPage extends StatefulWidget {
  const ChatlistAdminsPage({super.key});

  @override
  State<ChatlistAdminsPage> createState() => _ChatlistAdminsPageState();
}

class _ChatlistAdminsPageState extends State<ChatlistAdminsPage> {

  final ChatService chatService = ChatService();
  final AuthService authService = AuthService();
  final TextEditingController searchController = TextEditingController();
  String searchText = "";

  @override
  Widget build(BuildContext context) {
    return Scaffold(      
      appBar: MyAppbar(title: "Chats Disponibles"),
      body: Column(
        children: [
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: 15, vertical: 5),
            child: Row(
              children: [
                Expanded(
                  child: TextField(
                    style: TextStyle(color: Theme.of(context).colorScheme.tertiary),
                    controller: searchController,
                    decoration: InputDecoration(
                      labelStyle: TextStyle(color: Theme.of(context).colorScheme.primary),
                      labelText: "Buscar Email, Nombres o Apellidos",
                      enabledBorder: OutlineInputBorder(
                        borderSide: BorderSide(color: Theme.of(context).colorScheme.primary)
                      ),
                    ),
                    // onChanged: (value) {
                    //   setState(() {
                    //     searchText = value.toLowerCase();
                    //   });
                    // },
                  ),
                ),
                const SizedBox(width: 5),
                IconButton(
                  icon: Icon(Icons.search, color: Theme.of(context).colorScheme.primary,),
                  onPressed: () {
                    setState(() {
                      searchText = searchController.text.toLowerCase();
                    });
                  },
                ),
              ],
            ),
          ),
          Expanded(child: buildUserList()),
        ],
      ),
    );
  }

  Widget buildUserList(){
    return StreamBuilder(
      stream: chatService.getUsersStreamExcBloAdm(), 
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error..", style: TextStyle(
            color: Theme.of(context).colorScheme.primary,
          ),);
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child:  CircularProgressIndicator(
            strokeWidth: 10,
          ));
        }

        // Filter data based on searchText
        final filteredData = snapshot.data!.where((userData) {
          final email = userData["email"] as String;

          // Convert searchText to lowercase for case-insensitive comparison
          final lowerSearchText = searchText.toLowerCase();

          // Ensure email doesn't match the current user's email
          if (email != authService.getCurrentUser()!.email) {
            // Check if "nombres" or "apellidos" contain the searchText
            final nombresMatch = userData["nombres"] != null &&
                userData["nombres"].toString().toLowerCase().contains(lowerSearchText);
            final apellidosMatch = userData["apellidos"] != null &&
                userData["apellidos"].toString().toLowerCase().contains(lowerSearchText);

            // Return true if either "nombres" or "apellidos" match the searchText
            return nombresMatch || apellidosMatch || email.toLowerCase().contains(lowerSearchText);
          }

          return false;
        }).toList();

        if (filteredData.isEmpty) {
          return Center(
            child: Text("No se encontraron usuarios.", style: TextStyle(
              color: Theme.of(context).colorScheme.primary,
            ),),
          );
        }

        return ListView(
          padding: const EdgeInsets.only(top: 10),
          children: filteredData
            .map<Widget>((userData) => buildUserListItem(userData, context))
            .toList(),
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