import 'package:flutter/material.dart';
import 'package:prueba_chat/models/user.dart';
import 'package:prueba_chat/pages/rolepages/profile_page.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';
import 'package:prueba_chat/pages/settings_page.dart';

class MyDrawer extends StatelessWidget {
  const MyDrawer({super.key});

  void logout(BuildContext context) async {
    final auth = AuthService();
    // Provider.of<UserRoleProvider>(context, listen: false).clearRole();     
    await auth.signOut()
      .whenComplete(
      () {
        if(context.mounted){          
          Navigator.popUntil(context, ModalRoute.withName("/"));
        }        
      }
    );
  }

  @override
  Widget build(BuildContext context) {
    UserProfile? user;
    return Drawer(
      width: 250,
      backgroundColor: Theme.of(context).colorScheme.surface,
      child: Column(
        mainAxisAlignment: MainAxisAlignment.spaceBetween,
        children: [
          Column(            
            children: [
              DrawerHeader(
                padding: const EdgeInsets.symmetric(vertical: 15),
                child: Center(
                  child: Image.asset(
                    'assets/images/iconoajs.png',
                    alignment: const Alignment(0, -0.5),            
                  ),
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ListTile(
                  title: Text("INICIO", style: TextStyle(
                    color: Theme.of(context).colorScheme.primary
                  ),),
                  leading: Icon(
                    Icons.home_outlined,
                    color: Theme.of(context).colorScheme.primary
                  ),
                  onTap: () {
                    Navigator.pop(context);
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ListTile(
                  title: Text("AJUSTES", style: TextStyle(
                    color: Theme.of(context).colorScheme.primary
                  ),),
                  leading: Icon(
                    Icons.settings,
                    color: Theme.of(context).colorScheme.primary
                  ),
                  onTap: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                        builder: (context) => const SettingsPage(),
                      ),
                    );
                  },
                ),
              ),
              Padding(
                padding: const EdgeInsets.only(left: 10),
                child: ListTile(
                  title: Text("PERFIL", style: TextStyle(
                    color: Theme.of(context).colorScheme.primary
                  ),),
                  leading: Icon(
                    Icons.person_pin_outlined,
                    color: Theme.of(context).colorScheme.primary
                  ),
                  onTap: () async {
                    final auth = AuthService();
                    user = await auth.getCurrentUserProfile();
                    if(context.mounted){
                      Navigator.push(
                        context,
                        MaterialPageRoute(
                          builder: (context) => ProfilePage(user: user!,),
                        ),
                      );
                    }     
                  },
                ),
              ),
            ],
          ),
          Padding(
            padding: const EdgeInsets.only(left: 10, bottom: 20),
            child: ListTile(
              title: Text("LOG OUT", style: TextStyle(
                color: Theme.of(context).colorScheme.primary
              ),),
              leading: Icon(
                Icons.login_outlined,
                color: Theme.of(context).colorScheme.primary
                ),
              onTap: () => logout(context),
            ),
          ),
        ],
      ),
    );
  }
}