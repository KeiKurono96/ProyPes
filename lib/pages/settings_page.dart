import 'package:flutter/cupertino.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prueba_chat/components/my_appbar.dart';
import 'package:prueba_chat/pages/blockedusers_page.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';
import 'package:prueba_chat/themes/theme_provider.dart';

class SettingsPage extends StatelessWidget {
  const SettingsPage({super.key});

  void userDeletesAccount(BuildContext context) async {
    bool confirm = await showDialog(
      context: context, 
      builder: (context) {
        return AlertDialog(
        title: Text(
          "Confirmar Eliminación de Cuenta",
          style: TextStyle( color: Theme.of(context).colorScheme.primary),
        ),
        content: Text(
          "¿Estás seguro de eliminar tu cuenta permanentemente?",
          style: TextStyle( color: Theme.of(context).colorScheme.primary),
        ),
        actions: [
          MaterialButton(
            onPressed: () => Navigator.of(context).pop(false),
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              'Cancelar', 
              style: TextStyle( color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
          MaterialButton(
            onPressed: () => Navigator.of(context).pop(true),
            color: Theme.of(context).colorScheme.primary,
            child: Text(
              'ELIMINAR', 
              style: TextStyle( color: Theme.of(context).colorScheme.inversePrimary),
            ),
          ),
        ],
      );
      },
    ) ?? false;

    // If user confirmed, proceed with deletion
    if (confirm) {
      try {
        if (context.mounted) {
          Navigator.popUntil(context, ModalRoute.withName("/"));
          await AuthService().deleteAccount();          
        }   
      } catch(ex){
        if(!context.mounted) return;
        ScaffoldMessenger.of(context)
          .showSnackBar(SnackBar(content: Text(ex.toString())));
      }
    }
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: const MyAppbar(title: "Configuracion"),
      body: Column(
        children: [
          // DARK MODE BUTTON
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12)
            ),
            margin: const EdgeInsets.only(top: 30, right: 30, left: 30),
            padding: const EdgeInsets.only(top: 20, right: 30, left: 30, bottom: 20),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Modo Oscuro",
                  style: TextStyle(
                    fontSize: 16,
                    fontWeight: FontWeight.w700,
                    color: Theme.of(context).colorScheme.primary
                  ),
                ),
                CupertinoSwitch(
                  inactiveTrackColor: Theme.of(context).colorScheme.primary,
                  activeTrackColor: Colors.black,
                  value: Provider.of<ThemeProvider>(context, listen: false).isDarkMode, 
                  onChanged: (value) {
                    Provider.of<ThemeProvider>(context, listen: false).toogleTheme();
                  }
                )
              ],
            ),
          ),
          // BLOCKED USERS BUTTON
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.secondary,
              borderRadius: BorderRadius.circular(12)
            ),
            margin: const EdgeInsets.only(top: 40, right: 30, left: 30),
            padding: const EdgeInsets.only(top: 15, right: 40, left: 30, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Usuarios Bloqueados",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.primary
                  ),
                ),
                IconButton(
                  iconSize: 30,
                  onPressed: () => Navigator.push(
                    context,
                    MaterialPageRoute(
                      builder: (context) => BlockedUsersPage()
                    )
                  ),
                  icon: Icon(
                    Icons.arrow_forward_rounded,
                    color: Theme.of(context).colorScheme.primary,
                  )
                )
              ],
            ),
          ),
          Container(
            decoration: BoxDecoration(
              color: Theme.of(context).colorScheme.inversePrimary,
              borderRadius: BorderRadius.circular(12)
            ),
            margin: const EdgeInsets.only(top: 40, right: 30, left: 30),
            padding: const EdgeInsets.only(top: 15, right: 40, left: 30, bottom: 15),
            child: Row(
              mainAxisAlignment: MainAxisAlignment.spaceBetween,
              children: [
                Text(
                  "Borrar Cuenta",
                  style: TextStyle(
                    fontWeight: FontWeight.w700,
                    fontSize: 16,
                    color: Theme.of(context).colorScheme.tertiary
                  ),
                ),
                IconButton(
                  iconSize: 30,
                  onPressed: () => userDeletesAccount(context),
                  icon: Icon(
                    Icons.dangerous_outlined,
                    color: Theme.of(context).colorScheme.primary,
                  )
                )
              ],
            ),
          ),
        ],
      ),
    );
  }
}