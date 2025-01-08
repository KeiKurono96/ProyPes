import 'package:flutter/material.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:cloud_firestore/cloud_firestore.dart';

class UserRoleProvider extends ChangeNotifier {
  final FirebaseAuth _auth = FirebaseAuth.instance;
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;

  String? _role;
  bool _isLoading = true;

  String? get role => _role;
  bool get isLoading => _isLoading;

  UserRoleProvider() {
    // Listen for authentication state changes
    _auth.authStateChanges().listen((user) {
      if (user != null) {
        _fetchUserRole(user.uid);
      } else {
        clearRole(); // Clear role if user logs out
      }
    });
  }

  Future<void> fetchUserRole() async {
    _isLoading = true;
    notifyListeners();
    try {
      // Simulate fetching role from Firebase or API
      await _fetchUserRole(_auth.currentUser!.uid); // Replace with actual method
    } catch (e) {
      _role = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  Future<void> _fetchUserRole(String uid) async {
    try {
      // Fetch the user's role from Firestore
      final userDoc = await _firestore
          .collection('Users')
          .doc(uid)
          .get();

      if (userDoc.exists) {
        _role = userDoc.data()?['tipo'];
      } else {
        _role = null;
      }
    } catch (e) {
      // print("Error fetching user role: $e");
      _role = null;
    } finally {
      _isLoading = false;
      notifyListeners();
    }
  }

  void clearRole() {
    _role = null;
    _isLoading = true;
    notifyListeners();
  }
}
