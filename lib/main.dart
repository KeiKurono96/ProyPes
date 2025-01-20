import 'package:firebase_core/firebase_core.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:prueba_chat/pages/citations_page.dart';
import 'package:prueba_chat/pages/grades_page.dart';
import 'package:prueba_chat/pages/incidences_page.dart';
import 'package:prueba_chat/services/auth/auth_gate.dart';
import 'package:prueba_chat/firebase_options.dart';
import 'package:prueba_chat/services/auth/role_provider.dart';
import 'package:prueba_chat/services/notifications/globals.dart';
import 'package:prueba_chat/services/notifications/notification_service.dart';
import 'package:prueba_chat/themes/theme_provider.dart';

void main() async{
  // SETUP FIREBASE
  WidgetsFlutterBinding.ensureInitialized();
  await Firebase.initializeApp(options: DefaultFirebaseOptions.currentPlatform);
  
  // SETUP NOTIFICATION BACKGROUND HANDLER
  FirebaseMessaging.onBackgroundMessage(firebaseMessagingBackgroundHandler);

  // REQUEST NOTIFICATION PERMISSION
  final noti = NotificationService();
  await noti.requestPermission();
  noti.setupInteractions();

  // RUN APP
  runApp(
    MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (context) => ThemeProvider(),
        ),
        ChangeNotifierProvider(
          create: (_) => UserRoleProvider(),
        ),
      ],
      child: const MainApp(),
    )
  );
}

// NOTIFICATION BACKGROUND HANDLER
Future<void> firebaseMessagingBackgroundHandler(RemoteMessage message) async {
  await Firebase.initializeApp();
  // print("Handling a background message: ${message.messageId}");
  // print("Message data: ${message.data}");
  // print("Message notification: ${message.notification?.title}");
  // print("Message notification: ${message.notification?.body}");
}

class MainApp extends StatelessWidget {
  const MainApp({super.key});

  @override
  Widget build(BuildContext context) {
    final roleProvider = Provider.of<UserRoleProvider>(context);

    return MaterialApp(
      scaffoldMessengerKey: snackbarKey,
      navigatorKey: navigatorKey,
      debugShowCheckedModeBanner: false,
      home: const AuthGate(),
      theme: Provider.of<ThemeProvider>(context).themeData,
      // initialRoute: '/',
      routes: {
        '/incidencesPage':(context) => IncidencesPage(),
        '/citationsPage':(context) => CitationsPage(userRole: roleProvider.role!),
        '/gradesPage':(context) => GradesPage(),
        '/authGate':(context) => const AuthGate(),
      },
    );
  }
}