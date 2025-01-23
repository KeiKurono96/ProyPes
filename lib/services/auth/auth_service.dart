import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:cloud_functions/cloud_functions.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prueba_chat/models/user.dart';
import 'package:prueba_chat/services/notifications/notification_service.dart';

class AuthService {

  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  User? getCurrentUser(){
    return _auth.currentUser;
  }

  // Get Current User's Role
  Future<String?> getUserRole() async {
  try {
    // Get the current user's UID
    final userId = _auth.currentUser!.uid;

    // Reference the Users collection
    final userDoc = await _firestore
        .collection('Users')
        .doc(userId)
        .get();

    // Check if the document exists
    if (userDoc.exists) {
      // Extract the role field
      final role = userDoc.data()?['tipo'];
      return role;
    } else {
      // print("User document not found");
      return null;
    }
  } catch (e) {
    // print("Error fetching user role: $e");
    return null;
  }
}

  // Get Current User's Profile
  Future<UserProfile?> getCurrentUserProfile() async {
    try {
      final userId = getCurrentUser()!.uid;
      DocumentSnapshot<Map<String, dynamic>> snapshot = 
        await FirebaseFirestore.instance.collection('Users').doc(userId).get();

      if (snapshot.exists) {
        return UserProfile(
          uid: userId, 
          email: snapshot.data()!['email'],
          tipo: snapshot.data()!['tipo'], 
          nombres: snapshot.data()?['nombres'],
          apellidos: snapshot.data()?['apellidos'],
          sexo: snapshot.data()?['sexo'],
          direccion: snapshot.data()?['direccion'],
          telefono: snapshot.data()?['telefono'],
        );
      } else {
        return null; 
      }
    } catch (e) {
      // print('Error getting user profile: $e');
      return null; 
    }
  }

  // Sign In
  Future<UserCredential> signInWithEP(String email, password) async {
    try{
      UserCredential userCredential = await _auth.signInWithEmailAndPassword(
        email: email,
        password: password,
      );

      // save user information on doc
      // _firestore.collection("Users").doc(userCredential.user!.uid).set({
      //   'uid': userCredential.user!.uid,
      //   'email': email,
      // }, SetOptions(merge: true));

      // Save Device Token
      NotificationService().setupTokenListeners();
      
      return userCredential;
    } on FirebaseAuthException catch (e) {
      // throw Exception(e.code);
      switch (e.code) {
        case "ERROR_EMAIL_ALREADY_IN_USE":
        case "account-exists-with-different-credential":
        case "email-already-in-use":
          throw Exception("Este correo ya se está usando");
        case "ERROR_WRONG_PASSWORD":
        case "wrong-password":
          throw Exception("El correo o la contraseña no son correctos");
        case "ERROR_USER_NOT_FOUND":
        case "user-not-found":
          throw Exception("No se encontró un usuario con ese correo");
        case "ERROR_USER_DISABLED":
        case "user-disabled":
          throw Exception("Esta usuario se encuentra deshabilitado");
        case "ERROR_TOO_MANY_REQUESTS":
        case "operation-not-allowed":
          throw Exception("Demasiados intentos para entrar en esta cuenta");
        case "ERROR_OPERATION_NOT_ALLOWED":
          throw Exception("Error del servidor, por favor inténtalo más tarde.");
        case "ERROR_INVALID_CREDENTIAL":
        case "invalid-credential":
          throw Exception("Datos inválidos");
        case "ERROR_INVALID_EMAIL":
        case "invalid-email":
          throw Exception("Por favor ingresa un correo válido");
        case "missing-password":
          throw Exception("Falta la contraseña");
        default:
          throw Exception("Error desconocido, inicio de sesión falló");
      }
    }
  }

  // Sign Up
  Future<UserCredential> signUpWithEP(String email, String password, String tipo, List<String> aulas) async {
    try{
      UserCredential userCredential = await _auth.createUserWithEmailAndPassword(
        email: email,
        password: password,
      );

      // save user information on doc
      _firestore.collection("Users").doc(userCredential.user!.uid).set({
        'uid': userCredential.user!.uid,
        'email': email,
        'tipo': tipo,
        'aulas': aulas,
      });

      // Save Device Token
      NotificationService().setupTokenListeners();

      return userCredential;
    } on FirebaseAuthException catch (e) {
      // throw Exception(e.code);
      switch (e.code) {
        case "ERROR_EMAIL_ALREADY_IN_USE":
        case "account-exists-with-different-credential":
        case "email-already-in-use":
          throw Exception("Este correo ya se está usando");
        case "ERROR_WRONG_PASSWORD":
        case "wrong-password":
          throw Exception("El correo o la contraseña no son correctos");
        case "ERROR_USER_NOT_FOUND":
        case "user-not-found":
          throw Exception("No se encontró un usuario con ese correo");
        case "ERROR_USER_DISABLED":
        case "user-disabled":
          throw Exception("Esta usuario se encuentra deshabilitado");
        case "ERROR_TOO_MANY_REQUESTS":
        case "operation-not-allowed":
          throw Exception("Demasiados intentos para entrar en esta cuenta");
        case "ERROR_OPERATION_NOT_ALLOWED":
          throw Exception("Error del servidor, por favor inténtalo más tarde.");
        case "ERROR_INVALID_CREDENTIAL":
        case "invalid-credential":
          throw Exception("Datos inválidos");
        case "ERROR_INVALID_EMAIL":
        case "invalid-email":
          throw Exception("Por favor ingresa un correo válido");
        case "missing-password":
          throw Exception("Falta la contraseña");
        default:
          throw Exception("Error desconocido, inicio de sesión falló");
      }
    }
  }

  // Sign Out
  Future<void> signOut() async {

    // Clear Device Token
    String? userId = _auth.currentUser?.uid;
    if(userId!=null){
      await NotificationService().clearTokenOnLogout(userId);
    }

    try{
      return await _auth.signOut();    
    } catch (e) {
    // print("Error logging out: $e");
    }
    
  }

  // Delete Self Account
  Future<void> deleteAccount() async {
    User? user = getCurrentUser();

    if(user != null){
      await _firestore.collection('Users').doc(user.uid).delete();
      await user.delete();
    }
  }

  // Delete User (For Admins Only)
  Future<void> deleteUser(String uidToDelete) async {
    final HttpsCallable callable =
        FirebaseFunctions.instance.httpsCallable('deleteUser');
        
    await callable.call({'uidToDelete': uidToDelete});
    // try {
    //   final result = await callable.call({'uidToDelete': uidToDelete});
    //   print(result.data['message']);
    // } catch (e) {
    //   print('Error deleting user: $e');
    // }
  }

  // Update User email (For Admins Only)
  Future<void> changeUserEmail(String uid, String newEmail) async {
  // try {
    final functions = FirebaseFunctions.instance;
    await functions.httpsCallable('updateUserEmail').call({
      'uid': uid,
      'newEmail': newEmail,
    });
    // print(result.data); // Handle the result
  // } catch(e){}
  //  on FirebaseFunctionsException catch (e) {
  //   // print('Error: ${e.message}');
  // }
  }

  // Update User password (For Admins Only)
  Future<void> changeUserPassword(String uid, String newPassword) async {
  // try {
    final functions = FirebaseFunctions.instance;
    await functions.httpsCallable('updateUserPassword').call({
      'uid': uid,
      'newPassword': newPassword,
    });
    // print(result.data); // Handle the result
  // } catch(e){}
  //  on FirebaseFunctionsException catch (e) {
  //   // print('Error: ${e.message}');
  // }
  }

  // Update other User fields (For Admins)
  Future<void> updateUser(String uid, String tipo) async {
    await _firestore.collection("Users").doc(uid).update({"tipo": tipo});
  }

  // Update self User fields (For Users)
  Future<void> updateSelfUser(String uid, UserProfile user) async {
    try {
      await _firestore
        .collection('Users')
        .doc(uid)
        .update({
          'nombres': user.nombres, 
          'apellidos': user.apellidos,
          'sexo': user.sexo,
          'direccion': user.direccion,
          'telefono': user.telefono,
        });
      // print('User updated successfully!');
    } catch (e) {
      // print('Error updating user: $e');
    }
  }

  // Reset Password
  Future<void> sendPasswordResetLink(String email) async {
    try{
      await _auth.sendPasswordResetEmail(email: email);
    }catch(e){
      // print(e.toString());
    }
  }

  // Errors
  // String getErrorMessage(String errorCode) {
  //   switch(errorCode){
  //     case 'Exception: wrong-password':
  //       return 'La contraseña es incorrecta. Intentalo de nuevo';
  //     case 'Exception: user-not-found':
  //       return 'No existe ese usuario';
  //     case 'Exception: invalid-email':
  //       return 'Este correo no existe';
  //     default:
  //       return 'Ocurrió un error inesperado. Inténtalo de nuevo más tarde';
  //   }
  // }
}