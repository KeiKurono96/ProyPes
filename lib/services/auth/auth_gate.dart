import 'package:firebase_auth/firebase_auth.dart';
import 'package:flutter/material.dart';
import 'package:prueba_chat/services/auth/login_or_register.dart';
import 'package:prueba_chat/services/auth/role_gate.dart';

class AuthGate extends StatefulWidget {
  const AuthGate({super.key});

  @override
  State<AuthGate> createState() => _AuthGateState();
}

class _AuthGateState extends State<AuthGate> {
  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: StreamBuilder(
        stream: FirebaseAuth.instance.authStateChanges(),
        builder: (context, snapshot) {
          if (snapshot.hasData) {
            return const RoleGate();
            // return ChangeNotifierProvider(
            //   create: (_) => UserRoleProvider(),
            //   child: const RoleGate(),
            // );
          } else {
            // Ensure clear() is called after the current frame
            // WidgetsBinding.instance.addPostFrameCallback((_) {
              // Provider.of<UserRoleProvider>(context, listen: false).clearRole();
            // });
            return const LoginOrRegister();
          }
        }
      )
    );
  }
}