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
  final TextEditingController searchController = TextEditingController();
  String searchText = "";

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
      stream: chatService.getUsersStream(), 
      builder: (context, snapshot) {
        if (snapshot.hasError) {
          return Text("Error..", style: TextStyle(
            color: Theme.of(context).colorScheme.primary
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
            // Return true if either "email" match the searchText
            return email.toLowerCase().contains(lowerSearchText);
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
          children: filteredData.map<Widget>((userData) => 
            buildUserListItem(userData, context)).toList(),
          // children: snapshot.data!.map<Widget>((userData) => 
          //   buildUserListItem(userData, context)).toList(),
        );
      }
    );
  }

  Widget buildUserListItem(Map<String, dynamic> userData, BuildContext context){
    if (userData["email"] != authService.getCurrentUser()!.email) {
      return EditUserTile(
        text: userData["email"],
        role: userData["tipo"],
        onTap: () {
          // say uid in snackbar
          if(context.mounted){
            Navigator.push(context, MaterialPageRoute(
              builder: (context) => EditUserPage(
                id: userData["uid"],
                email: userData["email"],
                role: userData["tipo"],
                aulas: userData["aulas"],
              ),
            ));
          }
        },
      );
    } else {
      return Container();
    }
  }
}