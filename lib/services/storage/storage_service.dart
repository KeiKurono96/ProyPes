import 'dart:io';

import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:file_picker/file_picker.dart';
import 'package:firebase_storage/firebase_storage.dart';
import 'package:flutter/material.dart';
import 'package:image_picker/image_picker.dart';
import 'package:intl/intl.dart';
import 'package:prueba_chat/services/auth/auth_service.dart';

class StorageService with ChangeNotifier {
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final AuthService _authService = AuthService();
  // Firebase Storage
  final firebaseStorage = FirebaseStorage.instance;

  // Images are stored in firebase as download URLs
  List<String> _imageUrls = [];
  List<String> _imageNames = [];

  // Loading status
  bool _isLoading = false;
  // Uploading status
  bool _isUploading = false;

  // Getters
  List<String> get imageUrls => _imageUrls;
  List<String> get imageNames => _imageNames;
  bool get isLoading => _isLoading;
  bool get isUploading => _isUploading;

  // Read Images
  Future<void> fetchImages() async {
    _isLoading = true;

    // Get the list under the durectory: uploaded_images/
    final ListResult result = 
        await firebaseStorage.ref('uploaded_images/').listAll();

    // Get the download URLs for each image
    final urls = 
        await Future.wait(result.items.map((ref) => ref.getDownloadURL()));

    final names = result.items.map((ref) => ref.name).toList();

    _imageUrls = urls;
    _imageNames = names;
    _isLoading = false;
    notifyListeners();
  }

  // Delete Image
  Future<void> deleteImages(String imageUrl) async {
    try{
        // Remove from local list
        _imageUrls.remove(imageUrl);

        // Get path name and delete from friebase
        final String path = extractPathFromUrl(imageUrl);
        await firebaseStorage.ref(path).delete();
    } catch (e) {
        // print("Error deleting image: $e");
    }
    notifyListeners();
  }

  String extractPathFromUrl(String url) {
    Uri uri = Uri.parse(url);
    // Extract the part of the url we need
    String encodedPath = uri.pathSegments.last;
    // Url decoding the path
    return Uri.decodeComponent(encodedPath);
  }

  // Upload Image
  Future<void> uploadImage() async {
    _isUploading = true;
    notifyListeners();
    File file;

    if (Platform.isAndroid) {
      final ImagePicker picker = ImagePicker();
      final XFile? image = await picker.pickImage(source: ImageSource.gallery);
      
      if (image == null) return;
      file = File(image.path);
    } else {
      FilePickerResult? image = await FilePicker.platform.pickFiles(
      type: FileType.image,
        // allowedExtensions: ['xls', 'xlsx'],
      );
      
      if (image == null) return;
      file = File(image.files.single.path!);    
    }

    try{
      final now = DateTime.now();
      final formattedDate = DateFormat('yyyy-MM-dd_HH-mm-ss').format(now); // e.g., 2024-12-27_15-45-10
      // Define the path in storage
      String filePath = 'uploaded_images/$formattedDate.png';
      // Upload the file to firebase storage
      await firebaseStorage.ref(filePath).putFile(file);
      // After uploading, fetch the download URL
      String downloadUrl = await firebaseStorage.ref(filePath).getDownloadURL();
      // Update the image urls list and UI
      _imageUrls.add(downloadUrl);
      notifyListeners();
    } catch (e) {
      // print("Error uploading..$e");
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // Upload Image from Path
  Future<void> uploadImageFromPath(String path, String name) async {
    _isUploading = true;
    notifyListeners();
    File file = File(path);

    try{
      // Define the path in storage
      String filePath = 'uploaded_images/$name.png';
      // Upload the file to firebase storage
      await firebaseStorage.ref(filePath).putFile(file);
      // After uploading, fetch the download URL
      String downloadUrl = await firebaseStorage.ref(filePath).getDownloadURL();
      // Update the image urls list and UI
      _imageUrls.add(downloadUrl);
      notifyListeners();
    } catch (e) {
      // print("Error uploading..$e");
    } finally {
      _isUploading = false;
      notifyListeners();
    }
  }

  // Create Collection of Reports by Admin
  Future<void> createCitation(String title, String text, String targetRole) async {
    final currentUser = _authService.getCurrentUser();
    await _firestore.collection('Citations').add({
      'title': title,
      'text': text,
      'targetRole': targetRole,
      'createdAt': FieldValue.serverTimestamp(),
      'createdBy': currentUser!.uid,
      'isArchived': false,
    });
  }

  // Get Citations for Parent/Teacher
  Stream<QuerySnapshot> getCitations(String userRole) {
    final citationsRef = _firestore.collection('Citations');
    
    final citationsSnapshot = citationsRef
      .where('targetRole', isEqualTo: userRole)
      .where('isArchived', isEqualTo: false)
      .orderBy('createdAt', descending: true)
      .snapshots();
    return citationsSnapshot;
  }
}