import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prueba_chat/components/my_button.dart';
import 'package:prueba_chat/pages/rolepages/admins_page.dart';
import 'package:prueba_chat/pages/rolepages/parents_page.dart';
import 'package:prueba_chat/pages/rolepages/teachers_page.dart';
import 'package:prueba_chat/services/auth/role_provider.dart';

class RoleGate extends StatefulWidget {
  const RoleGate({super.key});

  @override
  State<RoleGate> createState() => _RoleGateState();
}

class _RoleGateState extends State<RoleGate> {
  @override
  Widget build(BuildContext context) {
    final roleProvider = Provider.of<UserRoleProvider>(context);

    if (roleProvider.isLoading) {
      // Show loading indicator while fetching the role
      return const Scaffold(
        body: Center(
          child: CircularProgressIndicator(),
        ),
      );
    }

    if (roleProvider.role == null && !roleProvider.isLoading) {
      // Trigger fetch if role is not set and not already loading
      WidgetsBinding.instance.addPostFrameCallback((_) {
        roleProvider.fetchUserRole();
      });
    }

    if (roleProvider.role == null) {
      // Trigger fetch if role is not set and not already loading
      // WidgetsBinding.instance.addPostFrameCallback((_) {
      //   roleProvider.fetchUserRole();
      // });
      return Scaffold(
        body: Center(
          child: Column(
            children: [
              const Text("No se encontró el rol. Contacte a soporte.",),
              MyButton(
                text: "Reintentar",
                onTap: () {
                  roleProvider.fetchUserRole();
                },
                ),
            ],
          )
        ),
      );
    }

    // Redirect to specific pages based on the role
    switch (roleProvider.role) {
      case 'Administrador':
        return const AdminsPage();
      case 'Docente':
        return const TeachersPage();
      case 'Apoderado':
        return const ParentsPage();
      default:
        return const Scaffold(
          body: Center(
            child: Text("Error desconocido. Porfavor contacte a soporte."),
          ),
        );
    }
  }
}
