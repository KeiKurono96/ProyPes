import 'package:cloud_firestore/cloud_firestore.dart';
import 'package:firebase_auth/firebase_auth.dart';
import 'package:prueba_chat/models/message.dart';

class ChatService{
  
  final FirebaseFirestore _firestore = FirebaseFirestore.instance;
  final FirebaseAuth _auth = FirebaseAuth.instance;

  // GET ALL USERS
  Stream<List<Map<String,dynamic>>> getUsersStream() {
    return _firestore.collection("Users").snapshots().map((snapshot) {
      return snapshot.docs.map((doc) {
        final user = doc.data();
        return user;
      }).toList();
    });
  }

  // GET ALL USERS EXCEPT BLOCKED USERS (FOR ADMINS)
  Stream<List<Map<String,dynamic>>> getUsersStreamExcBloAdm() {
    final currentUser = _auth.currentUser;

    return _firestore
      .collection('Users')
      .doc(currentUser!.uid)
      .collection('BlockedUsers')
      .snapshots()
      .asyncMap((snapshot) async {
        final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();
        final usersSnapshot = await _firestore.collection('Users')
          .where('tipo', whereIn: ['Docente','Administrador'])
          .get();

        // REPLACING CODE BELOW
        final usersData = await Future.wait(
          usersSnapshot.docs
            .where((doc) => 
              doc.data()['email'] != currentUser.email &&            
              !blockedUserIds.contains(doc.id))
            .map((doc) async {
              final userData = doc.data();
              final chatRoomId = [currentUser.uid, doc.id]..sort();
              final unreadMessagesSnapshot = await _firestore
                .collection("chat_rooms")
                .doc(chatRoomId.join('_'))
                .collection("messages")
                .where('receiverId', isEqualTo: currentUser.uid)
                .where('isRead', isEqualTo: false)
                .get();

              userData['unreadCount'] = unreadMessagesSnapshot.docs.length;
              return userData;
            }).toList(),
        );

        // Sort usersData by unreadCount in descending order
        usersData.sort((a, b) => b['unreadCount'].compareTo(a['unreadCount']));
        
        return usersData;
        // return usersSnapshot.docs
        //   .where((doc) => 
        //     doc.data()['email'] != currentUser.email &&            
        //     !blockedUserIds.contains(doc.id))
        //   .map((doc) => doc.data())
        //   .toList();
      });
  }

  // GET CLASSROOM USERS EXCEPT BLOCKED USERS (FOR PARENTS)
  Stream<List<Map<String,dynamic>>> getUsersStreamExcBloPar(List<dynamic> aulas) {
    final currentUser = _auth.currentUser;

    return _firestore
      .collection('Users')
      .doc(currentUser!.uid)
      .collection('BlockedUsers')
      .snapshots()
      .asyncMap((snapshot) async {
        final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();
        final usersSnapshot = await _firestore.collection('Users')
          .where('aulas', arrayContainsAny: aulas)
          .where('tipo', isEqualTo: 'Docente')
          .get();

        // REPLACING CODE BELOW
        final usersData = await Future.wait(
          usersSnapshot.docs
            .where((doc) => 
              doc.data()['email'] != currentUser.email &&            
              !blockedUserIds.contains(doc.id))
            .map((doc) async {
              final userData = doc.data();
              final chatRoomId = [currentUser.uid, doc.id]..sort();
              final unreadMessagesSnapshot = await _firestore
                .collection("chat_rooms")
                .doc(chatRoomId.join('_'))
                .collection("messages")
                .where('receiverId', isEqualTo: currentUser.uid)
                .where('isRead', isEqualTo: false)
                .get();

              userData['unreadCount'] = unreadMessagesSnapshot.docs.length;
              return userData;
            }).toList(),
        );

        // Sort usersData by unreadCount in descending order
        usersData.sort((a, b) => b['unreadCount'].compareTo(a['unreadCount']));

        return usersData;
      });
  }

  // GET CLASSROOM USERS EXCEPT BLOCKED USERS (FOR TEACHERS)
  Stream<List<Map<String,dynamic>>> getUsersStreamExcBloTea(List<dynamic> aulas) {
    final currentUser = _auth.currentUser;

    return _firestore
      .collection('Users')
      .doc(currentUser!.uid)
      .collection('BlockedUsers')
      .snapshots()
      .asyncMap((snapshot) async {
        final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();

        // Query for Parents
        final parentSnapshot = await _firestore
            .collection('Users')
            .where('aulas', arrayContainsAny: aulas)
            .where('tipo', isEqualTo: 'Apoderado')
            .get();

        // Query for Admins and Teachers
        final adminTeacherSnapshot = await _firestore
            .collection('Users')
            .where('tipo', whereIn: ['Administrador', 'Docente'])
            .get();

        // Combine results from both queries
        final combinedDocs = [...parentSnapshot.docs, ...adminTeacherSnapshot.docs];

        // REPLACING CODE BELOW
        final usersData = await Future.wait(
          combinedDocs
            .where((doc) => 
              doc.data()['email'] != currentUser.email &&            
              !blockedUserIds.contains(doc.id))
            .map((doc) async {
              final userData = doc.data();
              final chatRoomId = [currentUser.uid, doc.id]..sort();
              final unreadMessagesSnapshot = await _firestore
                .collection("chat_rooms")
                .doc(chatRoomId.join('_'))
                .collection("messages")
                .where('receiverId', isEqualTo: currentUser.uid)
                .where('isRead', isEqualTo: false)
                .get();

              userData['unreadCount'] = unreadMessagesSnapshot.docs.length;
              return userData;
            }).toList(),
        );

        // Sort usersData by unreadCount in descending order
        usersData.sort((a, b) => b['unreadCount'].compareTo(a['unreadCount']));

        return usersData;
      });
  }

  // SEND MESSAGE METHOD
  Future<void> sendMessage(String receiverId, message) async {
    // get user info
    final String currentUserId = _auth.currentUser!.uid;
    final String currentUserEmail = _auth.currentUser!.email!;
    final Timestamp timestamp = Timestamp.now();

    // create new message
    Message newMessage = Message(
      senderId: currentUserId, 
      senderEmail: currentUserEmail, 
      receiverId: receiverId, 
      message: message, 
      timestamp: timestamp,
      isRead: false,
    );

    // chat room ID for thr two users (sorted to ensure uniqueness)
    List<String> ids = [currentUserId, receiverId];
    ids.sort(); // to ensure the chatroomID is the same for the two people
    String chatRoomId = ids.join('_');

    // add new message to database
    await _firestore
      .collection("chat_rooms")
      .doc(chatRoomId)
      .collection("messages")
      .add(newMessage.toMap());
  }

  // GET MESSAGES
  Stream<QuerySnapshot> getMessages(String userId, otherUserId) {
    List<String> ids = [userId, otherUserId];
    ids.sort();
    String chatRoomId = ids.join('_');

    // add new message to database
    return _firestore
      .collection("chat_rooms")
      .doc(chatRoomId)
      .collection("messages")
      .orderBy("timestamp", descending: false)
      .snapshots();
  }

  // MARK MESSAGES AS READ
  Future<void> markMessagesAsRead(String receiverId) async {
    final currentUserId = _auth.currentUser!.uid;

    List<String> ids = [currentUserId, receiverId];
    ids.sort();
    String chatRoomId = ids.join('_');

    final unreadMessagesQuery = _firestore
      .collection("chat_rooms")
      .doc(chatRoomId)
      .collection("messages")
      .where('receiverId', isEqualTo: currentUserId)
      .where('isRead', isEqualTo: false);
    
    final unreadMessagesSnapshot = await unreadMessagesQuery.get();

    for (var doc in unreadMessagesSnapshot.docs) {
      await doc.reference.update({'isRead':true});
    }
  }

  // REPORT USER
  Future<void> reportUser(String messageId, String userId) async {
    final currentUser = _auth.currentUser;
    final report = {
      'reportedBy': currentUser!.uid,
      'messageId': messageId,
      'messageOwnerId': userId,
      'timestamp': FieldValue.serverTimestamp(),
    };

    await _firestore.collection('Reports').add(report);
  }

  // BLOCK USER
  Future<void> blockUser(String userId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(userId)
        .set({});
  }

  // UNBLOCK USER
  Future<void> unblockUser(String blockUserId) async {
    final currentUser = _auth.currentUser;
    await _firestore
        .collection('Users')
        .doc(currentUser!.uid)
        .collection('BlockedUsers')
        .doc(blockUserId)
        .delete();
  }

  // GET BLOCKED USERS STREAM
  Stream<List<Map<String, dynamic>>> getBlockedUsersStream(String userId){
    return _firestore
      .collection('Users')
      .doc(userId)
      .collection('BlockedUsers')
      .snapshots()
      .asyncMap((snapshot) async {
        final blockedUserIds = snapshot.docs.map((doc) => doc.id).toList();
        final userDocs = await Future.wait(
          blockedUserIds
            .map((id) => _firestore.collection('Users').doc(id).get()),
        );

        return userDocs.map((doc) => doc.data() as Map<String, dynamic>).toList();
      });
  }
}