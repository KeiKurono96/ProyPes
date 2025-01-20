import 'package:flutter/material.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/components/user_tile.dart';
import 'package:prueba_chat/pages/chat_page.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';
import 'package:prueba_chat/services/chat/chat_service.dart';

class ChatlistTeachersPage extends StatefulWidget {
  final List<dynamic> aulas;

  const ChatlistTeachersPage({super.key, required this.aulas});

  @override
  State<ChatlistTeachersPage> createState() => _ChatlistTeachersPageState();
}

class _ChatlistTeachersPageState extends State<ChatlistTeachersPage> {

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
                      labelText: "Buscar por Email",
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
      stream: chatService.getUsersStreamExcBloTea(widget.aulas), 
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return const Text("Error..");
        }
        if (snapshot.connectionState == ConnectionState.waiting) {
          return const Center(child:  CircularProgressIndicator(
            strokeWidth: 10,
          ));
        }
        // Filter data based on searchText
        final filteredData = snapshot.data!.where((userData) {
          final email = userData["email"] as String;
          return email.contains(searchText) &&
              email != authService.getCurrentUser()!.email;
        }).toList();

        if (filteredData.isEmpty) {
          return const Center(child: Text("No users found."));
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