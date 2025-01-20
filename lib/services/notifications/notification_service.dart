import 'dart:async';
import 'dart:io';
import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:firebase_messaging/firebase_messaging.dart';
import 'package:flutter/material.dart';
import 'package:google_api_availability/google_api_availability.dart';
import 'package:rxdart/rxdart.dart';
import 'package:prueba_chat/services/notifications/globals.dart';

class NotificationService {
  final FirebaseMessaging _firebaseMessaging = FirebaseMessaging.instance;
  final _messageStreamController = BehaviorSubject<RemoteMessage>();

  Future<bool> isUserResolvable() async {
    bool isUserResolvable;

    try {
      isUserResolvable =
          await GoogleApiAvailability.instance.isUserResolvable();
    } catch(e) {
      isUserResolvable = false;
    }

    return isUserResolvable;
  }

  // REQUEST PERMISSION: call on main or startup
  Future<void> requestPermission() async {
    NotificationSettings settings = await _firebaseMessaging.requestPermission(
      alert: true,
      badge: true,
      sound: true,
    );

    if (settings.authorizationStatus == AuthorizationStatus.authorized) {
      // print('User granted permission');
    } else if (settings.authorizationStatus == AuthorizationStatus.provisional) {
      // print('User granted provisional permission');
    } else {
      // print('User declined or has not accepted permission');
    }
  }

  // Navigate to Citations
  void navigateToCitations(){
    navigatorKey.currentState!.pushNamed('/citationsPage');
  }
 
  // Navigate to Grades
  void navigateToGrades(){
    navigatorKey.currentState!.pushNamed('/gradesPage');
  }

  // Navigate to Teacher Citations
  void navigateToTeacherCitations(){
    navigatorKey.currentState!.pushNamed('/authGate');
  }

  // Navigate to ExcelReports
  void navigateToExcelReports(){
    navigatorKey.currentState!.pushNamed('/incidencesPage');
  }

  // SETUP INTERACTIONS
  void setupInteractions(){
    // User received message
    FirebaseMessaging.onMessage.listen((event){
      // Extract the data from the notification 
      Map<String, dynamic>? data = event.data;
      // Check the notification origin
      String? notificationType = data['notificationType']; 

      switch (notificationType) {
        case 'Citations':
          final SnackBar snackBar = SnackBar(
            content: const Text("Se ha añadido una nueva citación global, por favor revisa el menú de citaciones"),
            action: SnackBarAction(
              label: "Ir a Citaciones", 
              onPressed: navigateToCitations),
          );
          snackbarKey.currentState?.showSnackBar(snackBar);
          break;
        case 'TCitations':
          final SnackBar snackBar = SnackBar(
            content: const Text("Se ha añadido una nueva citación de aula, por favor revisa el menú de citaciones de aula"),
            action: SnackBarAction(
              label: "Ir al menú principal", 
              onPressed: navigateToTeacherCitations),
          );
          snackbarKey.currentState?.showSnackBar(snackBar);
          break;
        case 'Grades':
          final SnackBar snackBar = SnackBar(
            content: const Text("Se ha añadido una nueva calificación, por favor revisa el menú de calificaciones"),
            action: SnackBarAction(
              label: "Ir a Calificaciones", 
              onPressed: navigateToGrades),
          );
          snackbarKey.currentState?.showSnackBar(snackBar);
          break;
        case 'Incidences':
          final SnackBar snackBar = SnackBar(
            content: const Text("Se ha añadido un nuevo reporte de tu hijo, por favor revisa el menú de reportes"),
            action: SnackBarAction(
              label: "Ir a Incidencias", 
              onPressed: navigateToExcelReports),
          );
          snackbarKey.currentState?.showSnackBar(snackBar);
          break;
        case 'Homework':
          final SnackBar snackBar = SnackBar(
            content: const Text("Se ha añadido una nueva tarea, por favor revisa el menú de tareas"),
            action: SnackBarAction(
              label: "Ir al menú principal", 
              onPressed: navigateToTeacherCitations),
          );
          snackbarKey.currentState?.showSnackBar(snackBar);
          break;
      }
      _messageStreamController.sink.add(event);
    });
    // User opened message
    FirebaseMessaging.onMessageOpenedApp.listen((event){
      // Extract the data from the notification 
      Map<String, dynamic>? data = event.data;
      // Check the notification origin
      String? notificationType = data['notificationType']; 

      switch (notificationType){
        case 'Citations':
          navigateToCitations(); 
          break;
        case 'TCitations':
          navigateToTeacherCitations(); 
          break;
        case 'Grades':
          navigateToGrades(); 
          break;
        case 'Incidences':
          navigateToExcelReports(); 
          break;
        case 'Homework':
          navigateToTeacherCitations(); 
          break;
      }
    });
  }

  // Dispose the controller
  void dispose() {
    _messageStreamController.close();
  }

  // SETUP TOKEN LISTENERS
  // Each device has a token, we need it to send the notification
  Future<void> setupTokenListeners() async {
    if(Platform.isAndroid){
      final resolved = await isUserResolvable();
      if (!resolved) {
        FirebaseMessaging.instance.getToken().then((token) {
          saveTokenToDatabase(token);
        });
        
        FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
      }
    }
    // FirebaseMessaging.instance.getToken().then((token) {
    //   saveTokenToDatabase(token);
    // });
    
    // FirebaseMessaging.instance.onTokenRefresh.listen(saveTokenToDatabase);
  }

  // SAVE DEVICE TOKEN
  void saveTokenToDatabase(String? token) {
    String? userId = FirebaseAuth.instance.currentUser?.uid;

    // If current user is logged in and has a device token, save it to db
    if (userId != null && token != null) {
      FirebaseFirestore.instance.collection('Users').doc(userId).set({
        'fcmToken': token,
      }, SetOptions(merge: true));
    }
  }

  // CLEAR DEVICE TOKEN
  // In case the user logs out
  Future<void> clearTokenOnLogout(String userId) async {
    try {
      await FirebaseFirestore.instance.collection('Users').doc(userId).update({
        'fcmToken': FieldValue.delete(),
      });
      // print("Token Cleared");
    } catch (e) {
      // print("Failed to clear token: $e");
    }
  }
}